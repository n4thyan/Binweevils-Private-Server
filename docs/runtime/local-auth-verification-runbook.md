# Local Auth Verification Runbook

This Phase 5 runbook explains how to verify the account bootstrap output against the PHP runtime compatibility helper without touching a live database.

The GitHub connector blocked adding the executable helper script directly, so this document keeps the exact verification boundary recorded in the repo.

## Purpose

The local account database smoke test already proves:

```text
clean schema can import into disposable MySQL
local account bootstrap can create local_demo
users row exists
buddylist row exists
stored account value is modern-hash shaped
nest and inventory rows are not created accidentally
```

This runbook covers the next manual/local check:

```text
stored users.password value from local_demo
plus game-full/essential/auth_compat.php
should verify the known local test value
and reject an incorrect local test value
```

## Manual verification shape

After running the disposable database smoke-test flow locally, export the stored value from the local account row into a temporary file.

Then run a tiny local PHP check that:

```text
requires game-full/essential/auth_compat.php
reads the stored value from the temporary file
calls bwps_auth_is_modern_hash(...)
calls bwps_auth_verify(...) with the expected local value
calls bwps_auth_verify(...) with an incorrect local value
exits non-zero if any result is wrong
```

## Expected result

```text
the stored value is recognised as modern
the expected local value verifies
the incorrect local value does not verify
```

## Boundary

This check does not need to:

```text
hit login.php
set cookies
follow redirects
boot the game
create nest rows
create inventory rows
touch the VPS
touch a live database
```

## Why this remains manual for now

The intended script/workflow content includes direct local verification strings and calls into the auth helper. The connector blocked that write, so this runbook preserves the safe test design without forcing a blocked patch.

## Next code boundary

The next runtime-code pass should split the login decision/update behaviour from the browser endpoint. That would allow CI to test login behaviour without relying on cookies, redirects, or browser headers.
