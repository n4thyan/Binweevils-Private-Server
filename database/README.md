# Database

This directory is the future home for the cleaned database installer.

For now, the canonical legacy import remains:

```text
/bwps.sql
```

Do not delete or replace `bwps.sql` until the schema and seed split has been tested against the legacy PHP endpoints.

## Current clean split files

```text
database/schema/001_base_schema.sql
database/schema/002_keys_auto_increment.sql
database/schema/schema_manifest.md
database/seeds/001_catalogue_reference.sql
database/seeds/seed_manifest.md
```

Treat this as an experimental clean database path, not the official installer yet.

## Planned structure

```text
database/
  schema/      # table definitions, indexes, auto-increment rules
  seeds/       # safe game-world/catalog seed data
```

## What belongs in schema

Schema files should contain `CREATE TABLE`, primary keys, indexes, and auto-increment changes.

## What belongs in seeds

Seed files should contain clean reference data that a new server needs to feel playable, such as:

- apparel/catalogue data
- item and garden item types
- levels
- puzzles
- quests/tasks
- reward/code templates where safe
- default room/nest data where safe

The first reviewed seed file currently includes only:

```text
itemtype
itemtypets
appareltypes
gardenitemtype
seeds
puzzletypes
crosswords
questtasks
```

## What should not be seeded by default

Avoid shipping old account/player state in the default install:

- user passwords
- session keys
- login keys
- IP addresses
- legacy demo users
- buddy lists for old accounts
- player inventories/progress tied to old users
- moderation logs or old admin/staff identity records

Fresh development/demo accounts should be created by a setup script later, not copied from the old dump.

## Import testing

Use a disposable database and follow:

```text
docs/database/import-test-plan.md
```

Do not point the split files at a live database until the import path and runtime bootstrap have been tested.