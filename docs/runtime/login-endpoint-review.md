# Clean Login Endpoint Review

This Phase 5 review documents the current `game-full/login/login.php` behaviour before clean login endpoint tests are added.

The goal is to avoid guessing. The clean database path should be tested one layer at a time.

## Current endpoint

```text
game-full/login/login.php
```

The endpoint currently:

```text
includes backbone.php
includes auth_compat.php
expects POST userID and password
loads a user row by username
verifies the submitted value with bwps_auth_verify(...)
checks active/banned status
creates a fresh sessionKey and loginKey
updates users.sessionKey/users.loginKey/users.lastLogin/users.loginIP
sets sessionId and weevil_name cookies
redirects to ../game.php on success
redirects to localhost error URLs on failure
logs out when POST values are missing
```

## Good Phase 5 state

The most important auth compatibility part is already in place:

```text
login uses bwps_auth_verify(...)
registration stores bwps_auth_hash(...)
```

The database config also reads environment variables through `game-full/essential/config.php`, so future endpoint tests can point the runtime at a disposable CI database.

## Current blockers for direct endpoint testing

The endpoint is still hard to test directly because it combines several concerns:

```text
credential verification
database update
cookie writes
browser redirects
error message encryption
logout fallback when POST data is missing
```

It also still contains redirect URLs pointing at:

```text
http://localhost/?err=...
```

That is legacy-compatible but not ideal for clean automated tests.

## Runtime data touched on successful login

A successful login updates only the matching `users` row:

```text
sessionKey
loginKey
lastLogin
loginIP
```

It does not create nest, inventory, hats, buddylist, or first-boot player state rows.

## Recommended next implementation boundary

Before adding a browser/full-endpoint smoke test, split the login logic behind a small compatibility helper that can be called from both the endpoint and tests.

Suggested boundary:

```text
lookup local user by username
verify submitted value with bwps_auth_verify(...)
return a structured result
optionally update session/login keys only after verification passes
```

Keep redirects/cookies in `login.php` for now.

This lets CI test the login decision without pretending to be a browser or relying on headers after output.

## Suggested future test flow

```text
start disposable MySQL
import clean schema and keys
create local_demo with tools/create_local_account.py
include the login compatibility helper in PHP
verify local_demo with the known local test value
confirm sessionKey/loginKey are changed on success
confirm wrong value fails and does not change sessionKey/loginKey
```

## Do not do yet

```text
do not remove sessionKey/loginKey yet
do not redesign login cookies yet
do not add nest or inventory starter rows here
do not normalise buddylist in this pass
do not remove legacy redirect behaviour until endpoint tests exist
```

## Why this matters

This keeps Phase 5 focused.

The project now has proof that the clean database can create local accounts. The next safe step is proving the runtime login decision/update behaviour can be tested without full game boot.
