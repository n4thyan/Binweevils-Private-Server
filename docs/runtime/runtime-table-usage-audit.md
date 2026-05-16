# Runtime Table Usage Audit

This document explains the Phase 5 runtime table-usage scanner.

## Tool

```text
tools/audit_runtime_table_usage.py
```

Default use:

```bash
python tools/audit_runtime_table_usage.py --output docs/runtime/generated-runtime-table-usage-report.md
```

By default it scans:

```text
game-full
server
```

## What it does

The scanner looks for simple SQL table references in PHP/JS runtime files:

```text
FROM table
JOIN table
UPDATE table
INSERT INTO table
DELETE FROM table
```

It then produces a markdown report mapping:

```text
table -> file:line references and operation type
```

Example output shape:

```text
### users

- game-full/login/login.php:10 (FROM)
- game-full/login/login.php:31 (UPDATE)
```

## Why this exists

Before we enable clean local account writes or starter player-state generation, we need to know which files touch runtime tables.

This helps avoid guessing around fragile legacy tables such as:

```text
users
buddylist
nest
nestinfo
weevilitems
weevilhats
gardeninventory
```

## Limits

This is not a full SQL parser.

It may miss dynamic table names or queries built across many string fragments.

It is still useful as a quick dependency map before changing auth, registration, buddy, nest, or inventory behaviour.

## Phase 5 use

Use this audit alongside:

```text
docs/runtime/runtime-boot-dependency-map.md
docs/database/runtime-data-modernisation-notes.md
docs/database/runtime-schema-debt-report.md
```

The scanner supports the same main rule:

```text
map legacy runtime usage first, then modernise behind compatibility helpers.
```
