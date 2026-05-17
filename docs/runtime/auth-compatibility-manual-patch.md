# Auth Compatibility Manual Patch Plan

The connected GitHub tool is currently blocking direct writes to the runtime auth helper, so the actual PHP auth patch may need to be applied locally by a maintainer.

This document keeps the manual patch controlled, reviewable, and easy to verify.

## Goal

Move Phase 5 auth away from direct legacy credential comparison while keeping old local legacy rows usable during migration.

New local accounts should use modern PHP credential hashing.

Existing local legacy rows should still verify temporarily so the old runtime can be migrated safely.

## Target files

```text
game-full/essential/auth_compat.php
game-full/login/login.php
game-full/register/create-new-weevil.php
```

Possible later file after inspection:

```text
game-full/essential/internal.php
```

Only touch `internal.php` if an admin/mod-panel login path still performs direct credential comparison.

## Required helper behaviour

Create a small helper file:

```text
game-full/essential/auth_compat.php
```

It should provide three behaviours:

```text
create a modern stored credential value for new local accounts
detect whether an existing stored value already uses PHP's modern hash format
verify a submitted value against either modern storage or the old direct legacy format
```

Use PHP built-ins for modern storage and verification.

Use a constant-time comparison helper for the temporary direct legacy fallback.

Do not add any account rows in this patch.

## Login patch

File:

```text
game-full/login/login.php
```

Required changes:

```text
include the auth compatibility helper
replace direct submitted-vs-stored credential comparison with the helper verifier
leave existing session/login key behaviour intact
leave existing cookies intact
leave existing redirect behaviour intact
```

Do not redesign the `users` table in this patch.

Do not remove `sessionKey` or `loginKey` yet. The old Flash/PHP bridge still depends on them.

## Registration patch

File:

```text
game-full/register/create-new-weevil.php
```

Required changes:

```text
include the auth compatibility helper
transform the submitted credential before inserting a new users row
keep buddylist creation behaviour intact
keep session/login key creation behaviour intact
keep cookies and redirect behaviour intact
```

This makes newly registered local users use modern storage without changing old legacy rows directly.

## Scanner update after patch

After the runtime patch lands, update the auth readiness workflow to run strict mode:

```bash
python tools/check_auth_readiness.py --fail-on-error
```

Then update the scanner if needed so it recognises the helper-based flow as clean.

## Review checklist

Before merging the runtime patch:

```text
PHP syntax check is green
auth readiness report no longer flags direct equality in login
registration still creates a user row
registration still creates an empty buddylist row
login still sets sessionId and weevil_name cookies
clean database path still does not seed old users
local account writer remains disabled until after this patch
```

## Local test commands

Run from the repo root:

```bash
find game-full server -type f -name '*.php' -print0 | xargs -0 -n1 php -l
python tools/check_auth_readiness.py --output /tmp/auth-readiness-report.md
python tools/audit_runtime_table_usage.py --output /tmp/runtime-table-usage-report.md
```

After scanner strict mode is enabled:

```bash
python tools/check_auth_readiness.py --fail-on-error
```

## What this patch must not do

```text
do not import old users
do not add local_admin or local_demo yet
do not seed old buddy/nest/inventory rows
do not remove sessionKey/loginKey
do not normalise buddylist yet
do not redesign the users table yet
do not touch bwps.sql
```

## Next pass after auth compatibility

Once the runtime auth patch is merged and checks are green, the next Phase 5 pass can enable the local account tool for obvious local-only fixtures:

```text
local_admin
local_demo
```

That should be a separate PR.
