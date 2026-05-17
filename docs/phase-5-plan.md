# Phase 5 Plan: Runtime Bootstrap and Database Modernisation Audit

Phase 5 starts after the Phase 4 clean database split.

The goal is to make the clean database path usable by the runtime without blindly carrying old account/player data forward.

## Phase 5 priorities

1. Audit runtime data debt before changing schema behaviour.
2. Map login/register/game boot dependencies.
3. Add auth/password compatibility safely.
4. Enable fresh local-only account creation.
5. Add minimum starter state only where runtime behaviour proves it is needed.
6. Keep modern schema redesign behind compatibility adapters.

## Important database note

The current database is not performance-ready or modern.

Known examples include packed list storage, packed runtime defaults, username-based links, mixed account/player state, and missing exported indexes/foreign keys.

These issues should be handled carefully. Do not normalise tables directly under the old PHP/Flash runtime without a compatibility layer.

## Completed Phase 5 starter pass

The first Phase 5 pass added:

```text
docs/database/runtime-data-modernisation-notes.md
docs/database/runtime-schema-debt-report.md
tools/audit_schema_debt.py
.github/workflows/schema-debt-audit-check.yml
```

## Runtime boot dependency map

The runtime boot dependency map records which tables are needed before local clean database login can work:

```text
docs/runtime/runtime-boot-dependency-map.md
```

## Runtime table usage scanner

The table usage scanner maps runtime source files to database tables before auth/bootstrap changes are made:

```text
tools/audit_runtime_table_usage.py
docs/runtime/runtime-table-usage-audit.md
.github/workflows/runtime-table-usage-check.yml
```

## PHP runtime syntax check

The PHP syntax check gives Phase 5 a small CI safety net before auth/runtime code changes:

```text
.github/workflows/php-runtime-syntax-check.yml
docs/runtime/php-runtime-syntax-check.md
```

## Auth readiness check

The auth readiness check records where legacy direct credential handling still needs review before clean local account writes are enabled:

```text
tools/check_auth_readiness.py
docs/runtime/auth-readiness-check.md
.github/workflows/auth-readiness-check.yml
```

## Runtime auth compatibility

The runtime login/register flow now uses a compatibility helper so new local accounts can use modern stored credentials while temporary legacy verification remains available during migration:

```text
game-full/essential/auth_compat.php
game-full/login/login.php
game-full/register/create-new-weevil.php
```

## Users password column guard

The clean schema is guarded so `users.password` remains wide enough for modern stored credential values:

```text
tools/check_credential_column.py
.github/workflows/users-column-check.yml
docs/database/users-column.md
```

## Local account bootstrap

The local account bootstrap pass enables guarded local-only account creation for disposable clean databases:

```text
tools/create_local_account.py
docs/database/local-account-bootstrap.md
.github/workflows/local-account-tool-check.yml
```

This creates only:

```text
users
buddylist
```

It deliberately avoids old users, old moderator names, nest rows, inventory rows, progress rows, and production data.

## Local account database smoke test

The local account database smoke test proves the clean schema and local account bootstrap tool work together against a disposable MySQL service in CI:

```text
.github/workflows/local-account-db-smoke-test.yml
docs/database/local-account-db-smoke-test.md
```

The smoke test imports the clean schema, creates `local_demo`, confirms `users` and `buddylist` rows exist, confirms the stored credential is hash-shaped, and confirms nest/item starter rows are not created yet.

## MySQL 8 schema copy tool

The schema copy tool extracts the smoke-test schema compatibility logic into a reusable tool:

```text
tools/build_mysql8_schema_copy.py
docs/database/mysql8-schema-copy-tool.md
```

The local account database smoke test now calls this tool instead of carrying inline Python inside the workflow.

## Verification database smoke test

The verification database smoke test planning pass documents the next smoke test layer:

```text
docs/database/verification-db-smoke-test.md
```

This test should connect the Python bootstrap tool, clean MySQL row, and PHP runtime helper before the project moves on to full login endpoint testing.

## Local auth verification runbook

The local auth verification runbook records the manual/local verification boundary after the connector blocked the executable helper script:

```text
docs/runtime/local-auth-verification-runbook.md
```

This runbook explains how to verify a generated local account stored value against the PHP runtime compatibility helper without touching a live database.

## Clean login endpoint review

The clean login endpoint review documents the existing login endpoint boundary and the safest next implementation point:

```text
docs/runtime/login-endpoint-review.md
```

The review confirms the endpoint already uses the auth compatibility helper, but still mixes verification, database updates, cookies, redirects, and logout fallback behaviour. A future runtime-code pass should split the login decision/update logic behind a small helper before direct endpoint smoke tests are added.

## Clean first-boot review

The clean first-boot review documents the immediate post-login boot boundary:

```text
docs/runtime/clean-first-boot-review.md
```

The review confirms `game-full/game.php` mainly checks the session cookies/session bridge and embeds the Flash runtime. It does not directly prove nest, inventory, hats, tasks, or progress rows are required. Those should only be added after PHP endpoint, SWF, or socket traces prove the exact missing-row dependency.

## First-boot trace runbook

The first-boot trace runbook records the manual trace procedure for the first real clean-account boot attempt:

```text
docs/runtime/first-boot-trace-runbook.md
```

The runbook explains how to capture browser console output, network requests, PHP logs, and Node/socket logs so starter rows can be added from evidence rather than guesses.

## Local first-boot checklist

The local first-boot checklist gives practical copy/paste commands, browser filters, account row checks, and an evidence template so local trace output can be turned into the next small PR:

```text
docs/runtime/local-first-boot-checklist.md
```

## Windows/XAMPP clean local setup

The current Phase 5 pass adds the setup guide needed before the first local trace can be run:

```text
docs/setup/windows-xampp-clean-local.md
```

This guide walks through XAMPP, `bwps_clean`, clean schema import, local account creation, Node dependency setup, and the first local test boundary without using the VPS or importing old player/staff/demo data.

## Next safe pass after this

After the Windows/XAMPP setup guide lands, the next safest step is to follow it locally, report the first setup/runtime blocker, and then make the next small PR from evidence.

## Later Phase 5 work

```text
map required buddy/nest/inventory starter rows from runtime evidence
add local bootstrap fixtures outside default SQL seeds
test clean database first game boot
keep full schema normalisation for a later phase
```