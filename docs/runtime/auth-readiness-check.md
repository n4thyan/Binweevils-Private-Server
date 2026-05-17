# Auth Readiness Check

Phase 5 needs to update legacy login and registration handling carefully.

Now that the runtime compatibility helper exists, this check guards against accidentally reintroducing direct legacy credential handling.

## Tool

```text
tools/check_auth_readiness.py
```

Default report generation:

```bash
python tools/check_auth_readiness.py --output /tmp/auth-readiness-report.md
```

Strict mode:

```bash
python tools/check_auth_readiness.py --output /tmp/auth-readiness-report.md --fail-on-error
```

## What it checks

The scanner looks at the main runtime auth files:

```text
game-full/login/login.php
game-full/register/create-new-weevil.php
```

It requires:

```text
login includes auth_compat.php
login uses bwps_auth_verify(...)
registration includes auth_compat.php
registration creates a bwps_auth_hash(...) stored credential
```

It fails on:

```text
direct credential equality checks
raw submitted credential values being bound into SQL
missing helper include/use in login or registration
```

## Why this exists

The clean database path should eventually create fresh local accounts without carrying old account rows forward.

Login and registration now use the compatibility helper, so modern local account values can work while existing local legacy rows are still accepted during migration.

## Current expected result

The workflow now runs the scanner in strict mode.

A clean helper-based flow should produce:

```text
No readiness findings detected.
```

## Boundary

This check is read-only.

It does not change PHP runtime behaviour, create accounts, modify the database, or write fixtures.
