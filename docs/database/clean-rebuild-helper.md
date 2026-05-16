# Clean Database Rebuild Helper

The clean rebuild helper is a local convenience wrapper for the experimental clean database path.

## Tool

```text
tools/rebuild_clean_database.sh
```

It imports the current split files into a disposable database:

```text
database/schema/001_base_schema.sql
database/schema/002_keys_auto_increment.sql
database/seeds/001_catalogue_reference.sql
```

Then it runs:

```text
tools/validate_clean_database_import.sh
```

## Safety guard

The helper drops and recreates the selected database, so it has two guard rails.

The database name must look disposable:

```text
ends with _test
ends with _dev
starts with bwps_clean_
```

The command must also explicitly confirm the exact database name:

```bash
CONFIRM_RESET=bwps_clean_test
```

## Example

```bash
DB_HOST=127.0.0.1 \
DB_PORT=3306 \
DB_USER=root \
DB_PASSWORD=root \
DB_NAME=bwps_clean_test \
CONFIRM_RESET=bwps_clean_test \
bash tools/rebuild_clean_database.sh
```

## What it does not do

The helper does not create:

- users,
- passwords,
- session keys,
- login keys,
- buddy lists,
- nest/player setup rows,
- player inventory,
- moderation logs.

It does not touch `bwps.sql`, PHP runtime code, Node code, SWF/XML files, or assets.

## Status

This is still for local/disposable testing only.

It should not be pointed at a live private-server database.
