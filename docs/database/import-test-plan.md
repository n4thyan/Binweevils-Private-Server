# Database Import Test Plan

This plan describes how to test the new clean database path without replacing the legacy `bwps.sql` import yet.

## Goal

Prove that the split files import cleanly in a disposable database before they are treated as the recommended setup path.

The current split path is:

```text
database/schema/001_base_schema.sql
database/schema/002_keys_auto_increment.sql
database/seeds/001_catalogue_reference.sql
```

## Current generated file status

Schema manifest:

```text
CREATE TABLE blocks: 55
ALTER TABLE statements: 0
```

Seed manifest selected catalogue/reference data:

```text
itemtype: 13 INSERT statement(s)
itemtypets: 1 INSERT statement(s)
appareltypes: 1 INSERT statement(s)
gardenitemtype: 1 INSERT statement(s)
seeds: 1 INSERT statement(s)
puzzletypes: 1 INSERT statement(s)
crosswords: 1 INSERT statement(s)
questtasks: 5 INSERT statement(s)
```

Blocked player/runtime data detected but excluded:

```text
buddyalerts: 1
buddylist: 1
nest: 1
nestinfo: 1
users: 1
weevilitems: 1
```

Held back for separate review:

```text
tycoonbusinesses: 1
```

## Local disposable database test

Use a disposable database name, not a live database.

Example:

```bash
mysql -u root -p -e "DROP DATABASE IF EXISTS bwps_clean_test; CREATE DATABASE bwps_clean_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p bwps_clean_test < database/schema/001_base_schema.sql
mysql -u root -p bwps_clean_test < database/schema/002_keys_auto_increment.sql
mysql -u root -p bwps_clean_test < database/seeds/001_catalogue_reference.sql
```

Then confirm tables exist:

```bash
mysql -u root -p bwps_clean_test -e "SHOW TABLES;"
```

Confirm selected seed counts:

```bash
mysql -u root -p bwps_clean_test -e "SELECT COUNT(*) AS itemtype_rows FROM itemtype;"
mysql -u root -p bwps_clean_test -e "SELECT COUNT(*) AS questtasks_rows FROM questtasks;"
```

Confirm old user/player data was not seeded:

```bash
mysql -u root -p bwps_clean_test -e "SELECT COUNT(*) AS users_rows FROM users;"
mysql -u root -p bwps_clean_test -e "SELECT COUNT(*) AS buddylist_rows FROM buddylist;"
mysql -u root -p bwps_clean_test -e "SELECT COUNT(*) AS weevilitems_rows FROM weevilitems;"
```

Expected old runtime/player counts for this clean seed path:

```text
users: 0
buddylist: 0
weevilitems: 0
```

## XAMPP/phpMyAdmin test

1. Create a disposable database named `bwps_clean_test`.
2. Import `database/schema/001_base_schema.sql`.
3. Import `database/schema/002_keys_auto_increment.sql`.
4. Import `database/seeds/001_catalogue_reference.sql`.
5. Browse the tables and confirm `users`, `buddylist`, and `weevilitems` are empty.

## Do not use on live data yet

This split path is not a full installer yet.

It currently creates schema and selected catalogue/reference rows only. It does not create a local admin account, demo user, default nest, or any runtime setup rows required by the current PHP endpoints.

## Known follow-ups

- Add a local admin/demo account creation script.
- Add optional development fixtures with obvious names only.
- Decide whether `tycoonbusinesses` should become an optional seed file.
- Review table-name casing on Linux/MariaDB before VPS use.
- Add validation scripts that check table counts after import.
- Add a proper reset/reseed helper once the import path is stable.
