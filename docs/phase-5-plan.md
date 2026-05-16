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

## Next safe pass after this

The next runtime-changing PR should be small and focused:

```text
add password compatibility helper
update login/register/admin auth to use it
do not enable local account writes until checks pass
```

## Later Phase 5 work

```text
enable tools/create_local_account.py --execute for local_admin/local_demo only
map required buddy/nest/inventory starter rows
add local bootstrap fixtures outside default SQL seeds
test clean database login path
```