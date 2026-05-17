# MySQL 8 Schema Copy Tool

Phase 5 database smoke tests run against modern MySQL 8.

The checked-in clean schema still preserves the legacy database shape, including old defaults that modern MySQL rejects on some column types.

This helper builds a temporary import copy for smoke tests without rewriting the source schema.

## Tool

```text
tools/build_mysql8_schema_copy.py
```

## Default usage

```bash
python tools/build_mysql8_schema_copy.py
```

This reads:

```text
database/schema/001_base_schema.sql
```

and writes:

```text
tmp/001_base_schema.mysql8.sql
```

## What it changes

The tool removes unsupported default values from temporary import-copy lines for:

```text
TEXT/BLOB style columns
JSON/GEOMETRY style columns
date/time/timestamp style columns
```

Examples of legacy defaults modern MySQL can reject include:

```text
TEXT column DEFAULT '1'
DATE column DEFAULT CURRENT_TIMESTAMP()
old zero-date defaults
```

## What it does not change

The tool does not modify:

```text
database/schema/001_base_schema.sql
bwps.sql
runtime PHP
runtime Node
assets
seeds
live database
VPS database
```

It only writes a temporary copy used by smoke tests.

## Current user

The local account database smoke test now calls this tool instead of carrying an inline Python script inside the workflow.

```text
.github/workflows/local-account-db-smoke-test.yml
```

This makes future clean database smoke tests easier to write and keeps schema compatibility logic in one place.
