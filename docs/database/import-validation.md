# Clean Database Import Validation

This document describes the automated validation pass for the experimental clean database path.

## Validation script

```text
tools/validate_clean_database_import.sh
```

The script expects a reachable MySQL/MariaDB server and uses these environment variables:

```text
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=root
DB_NAME=bwps_clean_test
```

It recreates the selected disposable database and imports:

```text
database/schema/001_base_schema.sql
database/schema/002_keys_auto_increment.sql
database/seeds/001_catalogue_reference.sql
```

## GitHub Actions workflow

```text
.github/workflows/database-import-validation.yml
```

The workflow starts a MariaDB service, installs the MariaDB client, then runs the validation script.

## Checks performed

The script checks:

- 55 tables exist after import,
- selected catalogue/reference tables have expected row counts,
- blocked player/runtime tables remain empty,
- held-back optional data remains empty.

Expected catalogue/reference counts:

```text
itemtype: 42
itemtypets: 141
appareltypes: 2
gardenitemtype: 7
seeds: 4
puzzletypes: 9
crosswords: 1
questtasks: 43
```

Expected empty blocked/held-back tables:

```text
users
buddyalerts
buddylist
nest
nestinfo
weevilitems
tycoonbusinesses
```

## Why counts differ from the manifest

The seed manifest counts `INSERT` statement groups, not inserted rows.

Example: one `INSERT INTO itemtypets` statement may contain many row tuples.

The validation script checks final table row counts after import.

## Safety boundary

This validation does not touch a live database.

It is designed for a disposable database named:

```text
bwps_clean_test
```

Do not point it at a real/private-server production database.
