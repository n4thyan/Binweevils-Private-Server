#!/usr/bin/env python3
"""Create fresh local-only accounts for the clean database path.

This tool is intentionally narrow. It only supports `local_` usernames and only
creates the minimum runtime rows needed for login/bootstrap review:

- users
- buddylist

It does not import old users, old moderator names, nest state, inventory state,
progress state, sessions, or production data.
"""

from __future__ import annotations

import argparse
import os
import re
import secrets
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass
from urllib.parse import unquote, urlparse

USERNAME_PATTERN = re.compile(r"^local_[A-Za-z0-9_]{3,24}$")
MIN_PASSWORD_LENGTH = 8


@dataclass(frozen=True)
class DatabaseUrl:
    scheme: str
    username: str
    password: str
    host: str
    port: int | None
    database: str


@dataclass(frozen=True)
class LocalAccountPlan:
    database_url: str
    username: str
    password_env: str
    is_moderator: bool
    execute: bool
    output_sql: str | None


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Create a fresh local-only Binweevils account for a disposable/local database."
    )
    parser.add_argument("--database-url", required=True, help="MySQL/MariaDB URL for a disposable/local database.")
    parser.add_argument("--username", required=True, help="Fresh local account username, e.g. local_admin.")
    parser.add_argument("--password-from-env", required=True, help="Environment variable containing the local password.")
    parser.add_argument("--moderator", action="store_true", help="Create the account as a local moderator/admin account.")
    parser.add_argument("--output-sql", help="Write generated SQL to a file for review instead of only printing a plan.")
    parser.add_argument("--execute", action="store_true", help="Execute the generated SQL through the local mysql CLI.")
    return parser


def parse_database_url(raw_url: str) -> DatabaseUrl:
    parsed = urlparse(raw_url)
    if parsed.scheme not in {"mysql", "mariadb"}:
        raise ValueError("database URL scheme must be mysql:// or mariadb://")

    if not parsed.username:
        raise ValueError("database URL must include a username")

    if not parsed.hostname:
        raise ValueError("database URL must include a host")

    database = parsed.path.lstrip("/")
    if not database:
        raise ValueError("database URL must include a database name")

    return DatabaseUrl(
        scheme=parsed.scheme,
        username=unquote(parsed.username),
        password=unquote(parsed.password or ""),
        host=parsed.hostname,
        port=parsed.port,
        database=database,
    )


def masked_database_url(db: DatabaseUrl) -> str:
    port = f":{db.port}" if db.port else ""
    return f"{db.scheme}://{db.username}:***@{db.host}{port}/{db.database}"


def validate_plan(plan: LocalAccountPlan) -> list[str]:
    errors: list[str] = []

    if not USERNAME_PATTERN.match(plan.username):
        errors.append("Username must start with local_ and contain only letters, numbers, or underscores.")

    if plan.password_env not in os.environ:
        errors.append(f"Missing required password environment variable: {plan.password_env}")
    else:
        password = os.environ[plan.password_env]
        if len(password) < MIN_PASSWORD_LENGTH:
            errors.append(f"Password in {plan.password_env} must be at least {MIN_PASSWORD_LENGTH} characters long.")

    try:
        parse_database_url(plan.database_url)
    except ValueError as exc:
        errors.append(str(exc))

    if plan.execute and not shutil.which("mysql"):
        errors.append("--execute requires the mysql CLI to be installed and available on PATH.")

    if plan.execute and not shutil.which("php"):
        errors.append("--execute requires the php CLI to be installed and available on PATH for password_hash().")

    if plan.output_sql and not shutil.which("php"):
        errors.append("--output-sql requires the php CLI to be installed and available on PATH for password_hash().")

    return errors


def sql_quote(value: str) -> str:
    return "'" + value.replace("\\", "\\\\").replace("'", "''") + "'"


def build_modern_hash(password: str) -> str:
    php_code = """
$plain = stream_get_contents(STDIN);
$plain = preg_replace('/\r?\n$/', '', $plain);
echo password_hash($plain, PASSWORD_DEFAULT);
""".strip()

    result = subprocess.run(
        ["php", "-r", php_code],
        input=password,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )

    if result.returncode != 0:
        raise RuntimeError(f"php password_hash() failed: {result.stderr.strip()}")

    stored_value = result.stdout.strip()
    if not stored_value:
        raise RuntimeError("php password_hash() returned an empty value")
    return stored_value


def build_account_sql(plan: LocalAccountPlan, stored_password: str) -> str:
    timestamp = int(time.time())
    session_key = secrets.token_hex(32)
    login_key = secrets.token_hex(32)
    moderator = 1 if plan.is_moderator else 0

    username_sql = sql_quote(plan.username)

    return f"""-- Local-only account bootstrap generated by tools/create_local_account.py
-- Username: {plan.username}
-- Runtime rows created: users, buddylist
-- No nest, inventory, progress, old user, or production data is imported.

START TRANSACTION;

SET @local_username = {username_sql};
SET @existing_users = (SELECT COUNT(*) FROM `users` WHERE `username` = @local_username);

INSERT INTO `users` (
  `username`,
  `password`,
  `email`,
  `isModerator`,
  `sessionKey`,
  `loginKey`,
  `lastLogin`,
  `createdAt`,
  `regIP`,
  `loginIP`
)
SELECT
  @local_username,
  {sql_quote(stored_password)},
  '',
  {moderator},
  {sql_quote(session_key)},
  {sql_quote(login_key)},
  {timestamp},
  {timestamp},
  'local-bootstrap',
  'local-bootstrap'
WHERE @existing_users = 0;

INSERT INTO `buddylist` (`ownerName`, `namesList`, `blockList`, `requestList`)
SELECT @local_username, '', '', ''
WHERE NOT EXISTS (
  SELECT 1 FROM `buddylist` WHERE `ownerName` = @local_username
);

SELECT
  @local_username AS username,
  @existing_users AS existing_user_count,
  CASE WHEN @existing_users = 0 THEN 'created' ELSE 'skipped_existing_user' END AS local_account_status;

COMMIT;
"""


def run_mysql(db: DatabaseUrl, sql: str) -> int:
    command = [
        "mysql",
        "--host",
        db.host,
        "--user",
        db.username,
        "--database",
        db.database,
    ]

    if db.port:
        command.extend(["--port", str(db.port)])

    env = os.environ.copy()
    if db.password:
        env["MYSQL_PWD"] = db.password

    result = subprocess.run(command, input=sql, text=True, env=env, check=False)
    return result.returncode


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    plan = LocalAccountPlan(
        database_url=args.database_url,
        username=args.username,
        password_env=args.password_from_env,
        is_moderator=args.moderator,
        execute=args.execute,
        output_sql=args.output_sql,
    )

    errors = validate_plan(plan)
    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 2

    db = parse_database_url(plan.database_url)
    print("Local account setup plan validated.")
    print(f"Username: {plan.username}")
    print(f"Moderator: {1 if plan.is_moderator else 0}")
    print(f"Password env var: {plan.password_env}")
    print(f"Database URL: {masked_database_url(db)}")

    if not plan.execute and not plan.output_sql:
        print("No database writes were performed. Pass --output-sql or --execute to generate/apply SQL.")
        return 0

    stored_password = build_modern_hash(os.environ[plan.password_env])
    sql = build_account_sql(plan, stored_password)

    if plan.output_sql:
        with open(plan.output_sql, "w", encoding="utf-8", newline="\n") as handle:
            handle.write(sql)
        print(f"Wrote local account SQL to {plan.output_sql}")

    if plan.execute:
        print("Executing local account bootstrap SQL through mysql CLI...")
        return_code = run_mysql(db, sql)
        if return_code != 0:
            print("ERROR: mysql CLI execution failed", file=sys.stderr)
            return return_code
        print("Local account bootstrap SQL executed.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
