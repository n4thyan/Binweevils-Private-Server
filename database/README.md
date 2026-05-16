# Database

This directory is the future home for the cleaned database installer.

For now, the canonical legacy import remains:

```text
/bwps.sql
```

Do not delete or replace `bwps.sql` until the schema and seed split has been tested against the legacy PHP endpoints.

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
