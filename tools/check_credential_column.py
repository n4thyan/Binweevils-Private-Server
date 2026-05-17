#!/usr/bin/env python3
"""Check that the clean users credential column can hold modern hashes."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

DEFAULT_SCHEMA = Path("database/schema/001_base_schema.sql")
DEFAULT_MIN_LENGTH = 255


def extract_users_table(schema_text: str) -> str | None:
    match = re.search(
        r"CREATE\s+TABLE\s+`users`\s*\((?P<body>.*?)\)\s*ENGINE\s*=",
        schema_text,
        flags=re.IGNORECASE | re.DOTALL,
    )
    if not match:
        return None
    return match.group("body")


def extract_password_column_length(users_table_body: str) -> int | None:
    for line in users_table_body.splitlines():
        if "`password`" not in line:
            continue
        match = re.search(r"varchar\s*\(\s*(\d+)\s*\)", line, flags=re.IGNORECASE)
        if match:
            return int(match.group(1))
        return None
    return None


def main() -> int:
    parser = argparse.ArgumentParser(description="Check users.password capacity in the clean schema.")
    parser.add_argument("--schema", default=str(DEFAULT_SCHEMA), help="Schema file to inspect.")
    parser.add_argument(
        "--min-length",
        type=int,
        default=DEFAULT_MIN_LENGTH,
        help="Minimum varchar length required for modern password_hash values.",
    )
    args = parser.parse_args()

    schema_path = Path(args.schema)
    if not schema_path.exists():
        print(f"ERROR: schema file not found: {schema_path}")
        return 1

    schema_text = schema_path.read_text(encoding="utf-8", errors="replace")
    users_table = extract_users_table(schema_text)
    if users_table is None:
        print("ERROR: users table not found in schema")
        return 1

    password_length = extract_password_column_length(users_table)
    if password_length is None:
        print("ERROR: users.password varchar length not found")
        return 1

    if password_length < args.min_length:
        print(
            f"ERROR: users.password is varchar({password_length}), "
            f"expected at least varchar({args.min_length})"
        )
        return 1

    print(
        f"OK: users.password is varchar({password_length}); "
        f"minimum required length is {args.min_length}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
