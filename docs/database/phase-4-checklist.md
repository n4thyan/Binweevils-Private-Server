# Phase 4 Database Checklist

This checklist keeps the database rewrite safe and reversible.

## Pass 1: Map only

- [x] Create `database/` workspace.
- [x] Document schema vs seed split rules.
- [x] Add first-pass legacy table map.
- [x] Keep `bwps.sql` untouched.

## Pass 2: Verify PHP usage

- [x] Search PHP code for table usage in the main legacy database helper file.
- [x] Add `docs/database/php-table-usage.md`.
- [x] Mark confirmed tables as required, optional, player state, admin/log state, or unknown.
- [x] Identify tables that are read-only catalogue/reference data.
- [x] Identify tables that are user-generated/player state.
- [x] Record table-name casing risks before SQL extraction.
- [ ] Continue wider endpoint-by-endpoint checks while extracting schema.
- [ ] Identify SQL queries that rely on seed rows by ID.

## Pass 3: Create schema-only export

- [x] Add schema extraction tool.
- [x] Document expected generated schema files.
- [x] Preserve legacy table names for compatibility.
- [x] Run schema extraction in CI.
- [x] Confirm extraction produced 55 `CREATE TABLE` blocks.
- [x] Confirm extraction produced no separate `ALTER TABLE` statements from the legacy dump.
- [x] Confirm generated schema artifact uploads from GitHub Actions.
- [x] Commit generated `001_base_schema.sql`.
- [x] Commit generated `002_keys_auto_increment.sql`.
- [x] Commit generated `schema_manifest.md`.
- [ ] Review weird names and risky columns after generation.

## Pass 4: Create clean seed files

- [x] Add catalogue/reference seed split plan.
- [x] Add seed extraction planning helper.
- [x] Add dry-run CI check for seed extraction manifest.
- [x] Add seed manifest review notes.
- [x] Add manual seed manifest commit helper.
- [x] Commit generated `database/seeds/seed_manifest.md`.
- [x] Fix extractor handling for phpMyAdmin comments before INSERT blocks.
- [x] Regenerate seed manifest after comment-handling fix.
- [x] Review regenerated manifest before seed SQL export.
- [x] Add manual catalogue seed SQL commit helper.
- [x] Generate `database/seeds/001_catalogue_reference.sql`.
- [x] Document generated catalogue seed SQL before default import use.
- [x] Add local account setup plan and non-writing tool stub.
- [x] Inspect registration/login PHP password handling.
- [x] Document legacy auth/session behaviour before account writes.
- [ ] Add password compatibility helper for modern local accounts.
- [ ] Implement fresh local admin/demo account creation after auth review.
- [ ] Extract safe level/game/puzzle definitions not already covered.
- [ ] Remove old users, sessions, login keys, IPs, and demo account rows.
- [ ] Replace any required demo account data with obvious local fixtures.
- [ ] Keep seed files importable in deterministic order.

## Pass 5: Add setup/import docs

- [x] Add local MariaDB/MySQL import commands.
- [x] Add phpMyAdmin import notes.
- [x] Add reset/reseed notes.
- [x] Add warnings about not using the old dump in production.
- [x] Add validation script and workflow for import testing.
- [x] Run import validation workflow and review result.

## Pass 6: Optional migration tooling

- [ ] Add a script to rebuild a clean database from schema plus seeds.
- [ ] Add a script to create a local admin account.
- [x] Add a script to validate required tables exist.
- [ ] Add a script to check for unsafe seed data before commit.

## Latest export result

The first CI export completed successfully from PR #10.

```text
CREATE TABLE blocks: 55
ALTER TABLE statements: 0
Artifact: generated-schema
```

The generated schema files are now present under:

```text
database/schema/
```

## Latest seed note

The regenerated seed manifest found selected catalogue/reference INSERT groups for:

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

It also detected blocked player/runtime INSERT groups for:

```text
buddyalerts
buddylist
nest
nestinfo
users
weevilitems
```

Those blocked tables must stay out of default seed files.

## Current clean path status

The clean path is experimental but now has CI import validation for schema plus catalogue/reference seed data.

Current import order:

```text
database/schema/001_base_schema.sql
database/schema/002_keys_auto_increment.sql
database/seeds/001_catalogue_reference.sql
```

Fresh local accounts are still blocked from automatic writes until the PHP auth/password compatibility helper is added.

## Auth review status

`docs/database/auth-flow-review.md` records the current legacy auth flow.

Important result: the old runtime currently compares submitted passwords directly against `users.password`, then bridges the logged-in player through `users.sessionKey`, `users.loginKey`, and the `sessionId` / `weevil_name` cookies.

That means the clean local account tool must not write production-style accounts blindly. The next safe step is a compatibility helper that lets new local accounts use `password_hash()` while old local legacy rows can still load during the migration.

## Merge rule

Only merge each pass after the repo still loads and the docs make sense. Seed extraction should be reviewed table-by-table before old runtime data is excluded from the default import path.