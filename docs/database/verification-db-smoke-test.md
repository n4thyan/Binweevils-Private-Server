# Verification Database Smoke Test

This Phase 5 pass is the next layer after the local account database smoke test.

The previous smoke test proves:

```text
clean schema imports into disposable MySQL
local_demo can be created
users and buddylist rows exist
stored account value is modern-hash shaped
nest and inventory rows are not created accidentally
```

The next smoke test should prove the runtime PHP helper can verify the generated local account value.

## Intended CI flow

```text
start disposable MySQL 8
import the clean schema
import the account-bootstrap key layer
run tools/create_local_account.py for local_demo
read the stored users.password value for local_demo
include game-full/essential/auth_compat.php in PHP
confirm the correct local test value verifies
confirm an incorrect local test value does not verify
confirm the stored value is recognised as a modern hash
```

## Why this matters

This connects three Phase 5 pieces together:

```text
Python local account bootstrap tool
clean MySQL account row
PHP runtime compatibility helper
```

That is safer than jumping straight to browser/game login because it tests the account verification bridge first.

## Boundaries

This smoke test must not touch:

```text
VPS
live database
production data
old users
old staff accounts
old celebrity accounts
nest starter rows
inventory starter rows
SWF assets
Electron runtime
Node runtime
```

## Expected result

A generated `local_demo` row should verify with the known local test value and reject a wrong value.

If this passes, the next Phase 5 step is a login endpoint review/test.
