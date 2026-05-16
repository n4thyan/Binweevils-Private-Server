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

- [ ] Extract `CREATE TABLE` statements.
- [ ] Extract index statements.
- [ ] Extract auto-increment statements.
- [ ] Preserve legacy table names for compatibility.
- [ ] Add comments for weird names and risky columns.

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

## Merge rule

Only merge each pass after the repo still loads and the docs make sense. The actual SQL split should be its own PR, because it is much riskier than documentation.