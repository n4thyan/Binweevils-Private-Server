#!/usr/bin/env python3
"""
Extract allowlisted INSERT statements from the legacy bwps.sql dump.

This is a Phase 4 helper for splitting safe catalogue/reference seed data
away from old account/player state.

By default, run with --dry-run first and review the manifest before writing SQL.
"""

from __future__ import annotations

import argparse
import re
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path


DEFAULT_CATALOGUE_TABLES = [
    'itemtype',
    'itemtypets',
    'appareltypes',
    'gardenitemtype',
    'seeds',
    'levels',
    'specialmoves',
    'singleplayergames',
    'leaderboardgames',
    'trackdetails',
    'puzzletypes',
    'crosswords',
    'wordsearches',
    'achievements',
    'achievementtypes',
    'achievementtags',
    'achievementtypetags',
    'quests',
    'questtasks',
    'task-completed',
]

BLOCKED_TABLES = {
    'users',
    'buddylist',
    'buddyalerts',
    'weevilitems',
    'weevilhats',
    'gardeninventory',
    'nest',
    'nestinfo',
    'pets',
    'petacquiredskills',
    'singleplayergames_stats',
    'weevilgames',
    'multiplayergames',
    'leaderboardhighscores',
    'game-rewards',
    'game-logs',
    'taskscompletedbyusers',
    'questscompleted',
    'achievementscompleted',
    'achievementcounters',
    'crossworduserprogress',
    'wordsearchuserprogress',
    'bubblehunts',
    'redeemedcodes',
    'gameinvites',
    'camerapics',
}


@dataclass
class InsertStatement:
    table: str
    sql: str


def split_sql_statements(sql: str) -> list[str]:
    statements: list[str] = []
    current: list[str] = []
    in_single = False
    in_double = False
    in_backtick = False
    escaped = False

    for char in sql:
        current.append(char)

        if escaped:
            escaped = False
            continue

        if char == '\\' and in_single:
            escaped = True
            continue

        if char == "'" and not in_double and not in_backtick:
            in_single = not in_single
            continue

        if char == '"' and not in_single and not in_backtick:
            in_double = not in_double
            continue

        if char == '`' and not in_single and not in_double:
            in_backtick = not in_backtick
            continue

        if char == ';' and not in_single and not in_double and not in_backtick:
            statement = ''.join(current).strip()
            if statement:
                statements.append(statement)
            current = []

    trailing = ''.join(current).strip()
    if trailing:
        statements.append(trailing)

    return statements


def strip_leading_sql_comments(statement: str) -> str:
    """Remove phpMyAdmin-style comments that appear immediately before INSERT.

    The statement splitter returns text between semicolons. In phpMyAdmin dumps,
    an INSERT block is often preceded by comment lines, so a chunk may look like:

        -- Dumping data for table `itemtype`
        INSERT INTO `itemtype` ...;

    Without removing those comments first, the extractor under-counts valid
    INSERT blocks because the chunk does not literally start with INSERT.
    """

    text = statement.lstrip()

    while text:
        if text.startswith('--') or text.startswith('#'):
            lines = text.splitlines(keepends=True)
            text = ''.join(lines[1:]).lstrip()
            continue

        if text.startswith('/*'):
            end = text.find('*/')
            if end == -1:
                return ''
            text = text[end + 2 :].lstrip()
            continue

        break

    return text


def extract_inserts(sql: str) -> list[InsertStatement]:
    inserts: list[InsertStatement] = []
    pattern = re.compile(r"(?is)^INSERT\s+INTO\s+`(?P<table>[^`]+)`")

    for statement in split_sql_statements(sql):
        cleaned_statement = strip_leading_sql_comments(statement)
        match = pattern.match(cleaned_statement.strip())
        if not match:
            continue

        inserts.append(InsertStatement(table=match.group('table'), sql=cleaned_statement.rstrip(';') + ';'))

    return inserts


def load_table_list(raw_values: list[str] | None) -> list[str]:
    if not raw_values:
        return DEFAULT_CATALOGUE_TABLES

    tables: list[str] = []
    for raw in raw_values:
        for value in raw.split(','):
            table = value.strip()
            if table:
                tables.append(table)
    return tables


def build_manifest(
    *,
    source_name: str,
    selected_tables: list[str],
    all_counts: dict[str, int],
    selected_counts: dict[str, int],
    blocked_hits: dict[str, int],
) -> str:
    selected_lines = '\n'.join(
        f"- `{table}`: {selected_counts.get(table, 0)} INSERT statement(s)"
        for table in selected_tables
    )

    blocked_lines = '\n'.join(
        f"- `{table}`: {count} blocked INSERT statement(s)"
        for table, count in sorted(blocked_hits.items())
    ) or '- None found.'

    all_lines = '\n'.join(
        f"- `{table}`: {count} INSERT statement(s)"
        for table, count in sorted(all_counts.items())
    )

    return f"""# Seed Extraction Manifest

Generated from `{source_name}`.

This manifest is produced by `tools/extract_seed_tables.py`.

## Selected catalogue/reference tables

{selected_lines}

## Blocked player/runtime tables found

{blocked_lines}

## All INSERT tables found in source dump

{all_lines}

## Safety notes

Default seed extraction must not include old accounts, passwords, session keys, login keys, IP addresses, inventories, buddy lists, progress, moderation logs, or old staff/mod/celebrity identity records.
"""


def write_seed_file(output_path: Path, statements: list[InsertStatement], source_name: str) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)

    header = f"""-- Binweevils Private Server Rewrite
-- Catalogue/reference seed export generated from {source_name}
--
-- Review before importing. This file should not contain old user/player state.

"""

    grouped: dict[str, list[str]] = defaultdict(list)
    for statement in statements:
        grouped[statement.table].append(statement.sql)

    parts = [header.rstrip(), '']
    for table in sorted(grouped):
        parts.append('-- --------------------------------------------------------')
        parts.append(f'-- Seed data for `{table}`')
        parts.append('')
        parts.extend(grouped[table])
        parts.append('')

    output_path.write_text('\n'.join(parts).rstrip() + '\n', encoding='utf-8')


def main() -> int:
    parser = argparse.ArgumentParser(description='Extract allowlisted seed INSERT statements from bwps.sql.')
    parser.add_argument('--input', default='bwps.sql', help='Path to the legacy SQL dump.')
    parser.add_argument('--output', default='database/seeds/001_catalogue_reference.sql', help='Output seed SQL path.')
    parser.add_argument('--manifest', default='database/seeds/seed_manifest.md', help='Output manifest path.')
    parser.add_argument('--table', action='append', help='Allowlisted table name or comma-separated table names.')
    parser.add_argument('--dry-run', action='store_true', help='Only print/write manifest; do not write SQL seed file.')
    args = parser.parse_args()

    input_path = Path(args.input)
    if not input_path.exists():
        raise SystemExit(f'Input SQL dump not found: {input_path}')

    selected_tables = load_table_list(args.table)
    selected_set = set(selected_tables)

    unsafe_requested = selected_set & BLOCKED_TABLES
    if unsafe_requested:
        names = ', '.join(f'`{name}`' for name in sorted(unsafe_requested))
        raise SystemExit(f'Refusing to extract blocked player/runtime table(s): {names}')

    sql = input_path.read_text(encoding='utf-8', errors='replace')
    inserts = extract_inserts(sql)

    all_counts: dict[str, int] = defaultdict(int)
    selected_counts: dict[str, int] = defaultdict(int)
    blocked_hits: dict[str, int] = defaultdict(int)
    selected_statements: list[InsertStatement] = []

    for insert in inserts:
        all_counts[insert.table] += 1

        if insert.table in BLOCKED_TABLES:
            blocked_hits[insert.table] += 1

        if insert.table in selected_set:
            selected_counts[insert.table] += 1
            selected_statements.append(insert)

    manifest = build_manifest(
        source_name=input_path.name,
        selected_tables=selected_tables,
        all_counts=all_counts,
        selected_counts=selected_counts,
        blocked_hits=blocked_hits,
    )

    manifest_path = Path(args.manifest)
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(manifest, encoding='utf-8')

    if not args.dry_run:
        write_seed_file(Path(args.output), selected_statements, input_path.name)
        print(f'Wrote seed SQL: {args.output}')

    print(f'Wrote manifest: {args.manifest}')
    print(f'Selected INSERT statements: {len(selected_statements)}')
    print(f'All INSERT tables: {len(all_counts)}')
    print(f'Blocked table INSERT groups found: {sum(blocked_hits.values())}')

    return 0


if __name__ == '__main__':
    raise SystemExit(main())
