# Phase 4 Database Summary

Phase 4 created an experimental clean database path for the Binweevils Private Server rewrite.

The aim was to split the legacy database dump into safer, reviewable pieces while avoiding old account/player/runtime data in default imports.

## Status

```text
Database split/tooling status: mostly complete
Runtime account bootstrap status: intentionally held back
Official installer status: not ready yet
```

The clean path is good enough for disposable local database import testing. It is not yet a complete production/private-server setup flow because it does not create local users, admin accounts, player starter state, or runtime bootstrap rows.

## Main files produced

```text
database/schema/001_base_schema.sql
database/schema/002_keys_auto_increment.sql
database/schema/schema_manifest.md
database/seeds/001_catalogue_reference.sql
database/seeds/seed_manifest.md
```

## Current clean import order

```text
database/schema/001_base_schema.sql
database/schema/002_keys_auto_increment.sql
database/seeds/001_catalogue_reference.sql
```

## Seed data included

The first default catalogue/reference seed includes:

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

## Data deliberately excluded

Default seeds deliberately exclude old runtime/player data, including:

```text
users
buddyalerts
buddylist
nest
nestinfo
weevilitems
weevilhats
gardeninventory
taskscompletedbyusers
achievementcounters
game-logs
game-rewards
redeemedcodes
tycoonbusinesses
```

`tycoonbusinesses` is held back for separate review before any optional export.

## Tools added

```text
tools/extract_schema.py
tools/extract_seed_tables.py
tools/validate_clean_database_import.sh
tools/check_seed_safety.py
tools/rebuild_clean_database.sh
tools/create_local_account.py
```

Important note: `tools/create_local_account.py` is still a non-writing stub. Its `--execute` mode is intentionally disabled until runtime password compatibility is handled.

## Workflows added

```text
.github/workflows/schema-extract.yml
.github/workflows/seed-extraction-check.yml
.github/workflows/seed-manifest-commit.yml
.github/workflows/catalogue-seed-commit.yml
.github/workflows/database-import-validation.yml
.github/workflows/seed-safety-check.yml
.github/workflows/clean-rebuild-helper-check.yml
.github/workflows/local-account-tool-check.yml
```

## Validation now available

The repository can now validate the clean split import path in CI and locally.

CI validation:

```text
.github/workflows/database-import-validation.yml
```

Local/disposable rebuild helper:

```text
tools/rebuild_clean_database.sh
```

Safety scanner:

```text
tools/check_seed_safety.py
```

## Auth/account status

Legacy auth was reviewed and documented in:

```text
docs/database/auth-flow-review.md
docs/database/password-compatibility-plan.md
```

Important finding:

```text
The old PHP runtime currently compares submitted passwords directly against users.password.
```

Because of that, fresh local admin/demo account creation is still held back. The next safe runtime-auth step is a small PHP compatibility helper that allows new local accounts to use hashed password storage while preserving legacy migration compatibility.

## What not to do yet

Do not remove `bwps.sql` yet.

Do not call the clean split path the official installer yet.

Do not point the rebuild helper at a live database.

Do not enable account writes until password compatibility is implemented.

Do not seed old users, old moderators, old celebrity names, old passwords, old session/login keys, IP addresses, buddy lists, nest state, inventories, player progress, or moderation logs.

## Recommended next phase

Move into a focused runtime bootstrap/auth phase.

Suggested first passes:

1. Add a PHP password compatibility helper.
2. Update login/register/admin auth to use the helper.
3. Enable `tools/create_local_account.py --execute` for `local_admin` and `local_demo` only.
4. Add minimum starter-state generation only after endpoint behaviour is confirmed.
5. Keep account/player fixtures in local/dev setup tooling, not default SQL seeds.

## Safe stopping point

Phase 4 can be considered complete for database split, seed safety, import validation, and rebuild tooling.

The remaining account/bootstrap work should be treated as the start of the next phase because it touches runtime auth and player setup behaviour.
