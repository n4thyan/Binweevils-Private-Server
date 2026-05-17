#!/usr/bin/env python3
"""Build a MySQL 8 import copy of the clean base schema.

The checked-in base schema intentionally preserves legacy table shape.
This helper creates a temporary import copy for smoke tests by removing
legacy defaults that modern MySQL rejects on large value and temporal columns.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path

LARGE_VALUE_TYPES = (
    "tinytext",
    "text",
    "mediumtext",
    "longtext",
    "tinyblob",
    "blob",
    "mediumblob",
    "longblob",
    "json",
    "geometry",
)

TEMPORAL_VALUE_TYPES = (
    "date",
    "datetime",
    "timestamp",
    "time",
    "year",
)

DEFAULT_PATTERN = re.compile(
    r"\s+DEFAULT\s+(?:NULL|CURRENT_TIMESTAMP(?:\(\))?|'(?:[^'\\]|\\.)*'|-?\d+(?:\.\d+)?)",
    re.IGNORECASE,
)


def column_pattern(types: tuple[str, ...]) -> re.Pattern[str]:
    return re.compile(
        r"^\s*`[^`]+`\s+(?:" + "|".join(types) + r")\b",
        re.IGNORECASE,
    )


def build_mysql8_schema_copy(source_path: Path, target_path: Path) -> int:
    large_column_pattern = column_pattern(LARGE_VALUE_TYPES)
    temporal_column_pattern = column_pattern(TEMPORAL_VALUE_TYPES)

    changed = 0
    output_lines: list[str] = []

    for line in source_path.read_text(encoding="utf-8").splitlines():
        original = line

        if large_column_pattern.search(line):
            line = DEFAULT_PATTERN.sub("", line)

        if temporal_column_pattern.search(line):
            line = DEFAULT_PATTERN.sub("", line)

        if line != original:
            changed += 1

        output_lines.append(line)

    target_path.parent.mkdir(parents=True, exist_ok=True)
    target_path.write_text("\n".join(output_lines) + "\n", encoding="utf-8")
    return changed


def main() -> int:
    parser = argparse.ArgumentParser(description="Build a MySQL 8-compatible schema import copy.")
    parser.add_argument("--source", default="database/schema/001_base_schema.sql")
    parser.add_argument("--target", default="tmp/001_base_schema.mysql8.sql")
    args = parser.parse_args()

    source_path = Path(args.source)
    target_path = Path(args.target)

    if not source_path.exists():
        print(f"ERROR: source schema not found: {source_path}")
        return 1

    changed = build_mysql8_schema_copy(source_path, target_path)
    print(f"Wrote {target_path} with {changed} compatibility edit(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
