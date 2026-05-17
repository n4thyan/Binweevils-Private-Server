# Local Account Database Smoke Test

This Phase 5 smoke test proves the local account bootstrap tool can work against a disposable clean MySQL database.

It does not touch a VPS, live database, production database, or imported account data.

## Workflow

```text
.github/workflows/local-account-db-smoke-test.yml
```

## What it does

The workflow:

```text
starts a disposable MySQL 8 service
creates an empty bwps_clean database
imports database/schema/001_base_schema.sql
runs tools/create_local_account.py with --execute
checks that users has exactly one local_demo row
checks that buddylist has exactly one local_demo row
checks the stored credential looks like a PHP password_hash value
checks that nest/weevilitems/weevilhats rows were not created
```

## Why this matters

This is the first CI check that proves the clean schema and local account tool work together against a real MySQL service.

It confirms Phase 5 can create the minimum login/bootstrap rows without importing old accounts or old player state.

## What it does not test

This smoke test does not run the game, browser, Flash/Ruffle runtime, Electron app, Node server, or PHP login endpoint.

It only tests the database side of local account bootstrapping.

## Expected local rows

The tool should create:

```text
users.username = local_demo
buddylist.ownerName = local_demo
```

It should not create:

```text
nest
weevilitems
weevilhats
```

If game boot later proves those rows are needed, they must be added in a separate evidence-based pass.
