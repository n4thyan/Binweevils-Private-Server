#!/usr/bin/env python3
"""Check generated seed SQL files for blocked legacy runtime/player data."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

BLOCKED_TABLES = {
    "users",
    "buddyalerts",
    "buddylist",
    "nest",
    "nestinfo",
    "weevilitems",
    "weevilhats",
    "gardeninventory",
    "taskscompletedbyusers",
    "achievementcounters",
    "game-logs",
    "game-rewards",
    "redeemedcodes",
}

HELD_BACK_TABLES = {
    "tycoonbusinesses",
}

SENSITIVE_COLUMN_NAMES = {
    "password",
    "sessionkey",
    "loginkey",
    "loginip",
    "regip",
    "email",
}

INSERT_RE = re.compile(
    r"INSERT\s+INTO\s+`?([A-Za-z0-9_\-]+)`?\s*(?:\((.*?)\))?\s+VALUES",
    re.IGNORECASE | re.DOTALL,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Scan seed SQL files for blocked legacy runtime/player data.")
    parser.add_argument(
        "paths",
        nargs="*",
        default=["database/seeds"],
        help="Seed SQL files or directories to scan. Defaults to database/seeds.",
    )
    parser.add_argument(
        "--allow-held-back",
        action="store_true",
        help="Allow held-back optional tables. Blocked runtime/player tables are still refused.",
    )
    return parser.parse_args()


def iter_sql_files(paths: list[str]) -> list[Path]:
    files: list[Path] = []

    for raw_path in paths:
        path = Path(raw_path)
        if path.is_dir():
            files.extend(sorted(path.rglob("*.sql")))
        elif path.is_file() and path.suffix.lower() == ".sql":
            files.append(path)
        elif path.exists():
            print(f"Skipping non-SQL path: {path}")
        else:
            raise FileNotFoundError(f"Path does not exist: {path}")

    return files


def normalise_columns(raw_columns: str | None) -> set[str]:
    if not raw_columns:
        return set()

    columns = set()
    for raw in raw_columns.split(","):
        column = raw.strip().strip("`").lower()
        if column:
            columns.add(column)
    return columns


def scan_file(path: Path, allow_held_back: bool) -> list[str]:
    errors: list[str] = []
    content = path.read_text(encoding="utf-8", errors="replace")

    for match in INSERT_RE.finditer(content):
        table = match.group(1).lower()
        columns = normalise_columns(match.group(2))

        if table in BLOCKED_TABLES:
            errors.append(f"{path}: blocked table INSERT detected: {table}")

        if not allow_held_back and table in HELD_BACK_TABLES:
            errors.append(f"{path}: held-back table INSERT detected: {table}")

        risky_columns = sorted(columns & SENSITIVE_COLUMN_NAMES)
        if risky_columns:
            joined = ", ".join(risky_columns)
            errors.append(f"{path}: sensitive column(s) in seed INSERT for {table}: {joined}")

    return errors


def main() -> int:
    args = parse_args()
    files = iter_sql_files(args.paths)

    if not files:
        print("No seed SQL files found to scan.")
        return 0

    errors: list[str] = []
    for path in files:
        print(f"Scanning {path}")
        errors.extend(scan_file(path, args.allow_held_back))

    if errors:
        print("Seed safety scan failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print("Seed safety scan passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
