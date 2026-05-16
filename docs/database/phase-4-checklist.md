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
- [ ] Commit generated `001_base_schema.sql`.
- [ ] Commit generated `002_keys_auto_increment.sql`.
- [ ] Commit generated `schema_manifest.md`.
- [ ] Review weird names and risky columns after generation.

## Pass 4: Create clean seed files

- [ ] Extract safe catalogue data.
- [ ] Extract safe level/game/puzzle definitions.
- [ ] Remove old users, sessions, login keys, IPs, and demo account rows.
- [ ] Replace any required demo account data with obvious local fixtures.
- [ ] Keep seed files importable in deterministic order.

## Pass 5: Add setup/import docs

- [ ] Add local MariaDB/MySQL import commands.
- [ ] Add phpMyAdmin import notes.
- [ ] Add reset/reseed notes.
- [ ] Add warnings about not using the old dump in production.

## Pass 6: Optional migration tooling

- [ ] Add a script to rebuild a clean database from schema plus seeds.
- [ ] Add a script to create a local admin account.
- [ ] Add a script to validate required tables exist.
- [ ] Add a script to check for unsafe seed data before commit.

## Latest export result

The first CI export completed successfully from PR #10.

```text
CREATE TABLE blocks: 55
ALTER TABLE statements: 0
Artifact: generated-schema
```

The lack of separate `ALTER TABLE` statements means the original dump appears to store table definitions inline, without a later key/index pass that the extractor could separate out.

## Merge rule

Only merge each pass after the repo still loads and the docs make sense. The actual generated SQL split should be its own PR if the diff is large or hard to review.