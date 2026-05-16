# Clean Database Path Status

This document records the current status of the clean database split.

## Files now available

```text
database/schema/001_base_schema.sql
database/schema/002_keys_auto_increment.sql
database/schema/schema_manifest.md
database/seeds/001_catalogue_reference.sql
database/seeds/seed_manifest.md
```

## What this path does

The clean path currently provides:

- table structure for the legacy database,
- reviewed catalogue/reference seed data,
- a manifest of what seed data was extracted,
- a manifest of blocked player/runtime data that must stay out of default seeds.

## What this path does not do yet

It does not currently create:

- a default admin account,
- a default demo player account,
- a default nest/player setup,
- runtime session/login rows,
- any production deployment configuration.

## Why the old dump still exists

`bwps.sql` remains in the repository for legacy compatibility and as the source used to generate the split files.

Do not delete it until the split import path has been fully tested and the application can bootstrap cleanly from schema plus reviewed seeds plus local setup scripts.

## Recommended status label

For now, treat this as:

```text
experimental clean database path
```

Do not yet describe it as the official installer.

## Current default seed contents

Included in `database/seeds/001_catalogue_reference.sql`:

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

Excluded from the default seed path:

```text
users
buddyalerts
buddylist
nest
nestinfo
weevilitems
tycoonbusinesses
```

## Next practical milestone

The next practical milestone is an import validation pass:

1. create a disposable database,
2. import schema files,
3. import `001_catalogue_reference.sql`,
4. confirm catalogue rows exist,
5. confirm old player/user tables are empty,
6. document any import errors before changing runtime code.
