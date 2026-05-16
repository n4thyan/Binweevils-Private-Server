# Auth Readiness Check

Phase 5 needs to update legacy login and registration handling carefully.

The actual runtime auth change should stay small, but before that we need a repeatable way to see whether old direct credential handling is still present.

## Tool

```text
tools/check_auth_readiness.py
```

Default use:

```bash
python tools/check_auth_readiness.py --output /tmp/auth-readiness-report.md
```

Strict mode for the future:

```bash
python tools/check_auth_readiness.py --fail-on-error
```

## What it checks

The scanner looks at the main legacy auth files:

```text
game-full/login/login.php
game-full/register/create-new-weevil.php
```

It flags:

```text
direct credential equality checks
user creation lines that write credential fields
credential values bound into SQL before storage review
```

## Why this exists

The clean database path should eventually create fresh local accounts without carrying old account rows forward.

Before that happens, login and registration need a compatibility layer so modern local account values can work while existing local legacy rows are still accepted during migration.

## Current expected result

At the start of Phase 5, this scanner is expected to report findings. That is useful because it confirms the legacy places that still need runtime review.

The workflow does not fail on those findings yet. It only proves the scanner runs and uploads a report.

After the runtime auth compatibility patch lands, this scanner can be changed to fail on direct legacy handling.

## Boundary

This check is read-only.

It does not change PHP runtime behaviour, create accounts, modify the database, or write fixtures.
