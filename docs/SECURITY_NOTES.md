# Security Notes

This document lists security issues found during the foundation and runtime audit.

The current repo should still be treated as a local/preservation import, not something ready for public VPS deployment.

## Fixed or hardened during Phase 5

### Logout/session-key bypass hardening

Phase 5 fixed the session-key exploit class reported by CoDCrafted.

The hardening passes now:

- rotate `users.sessionKey` on logout instead of clearing it to an empty string
- rotate `users.loginKey` during logout as well
- clear blank `sessionId` and `weevil_name` cookies early in the PHP bootstrap
- reject blank usernames and blank session keys inside `confirmSessionKey()` before any database match can succeed

Expected failures:

```txt
confirmSessionKey('some_user', '')
confirmSessionKey('', 'some_key')
confirmSessionKey('', '')
```

These checks should stay in place even if the auth system is later rewritten.

## Current high-risk areas

### Plain-text passwords

The imported `users` seed rows use plain-text passwords.

Required future fix:

- use a modern password hashing library
- never commit real account passwords
- ship optional local demo credentials only in a clearly marked dev seed

### Static session/login keys in old imported data

The original imported `users` rows contain static `sessionKey` and `loginKey` values.

Progress so far:

- logout now rotates session/login keys instead of leaving blank values
- blank session checks are rejected defensively

Required future fix:

- generate all session/login keys at runtime
- store active session state separately from core user profile data
- remove old imported key material from any default clean seed path

### Hardcoded token response

The current `/connect/token` route returns static token values.

Required future fix:

- generate tokens dynamically
- do not commit real token material
- add expiry handling
- rotate refresh tokens
- avoid logging token request bodies

### Hardcoded database config

Legacy defaults still exist for old local XAMPP compatibility.

Progress so far:

- Node config has environment override support
- PHP database config has environment override support
- old localhost defaults are preserved only as local fallback values

Required future fix:

- keep using environment variables for real deployments
- keep `.env.example` as a template only
- never commit real `.env` files

### Request body logging

Some auth/profile routes may still log request bodies.

Required future fix:

- remove body logging from auth routes
- redact sensitive fields in logs
- use structured logging for non-sensitive events only

### Public VPS risk

Do not deploy the current import directly to a public VPS.

Required before public hosting:

- remove seeded old users
- replace plain-text passwords
- review every auth route
- review every PHP endpoint
- review database permissions
- lock MySQL/MariaDB to localhost unless intentionally exposed
- configure HTTPS properly
- add rate limiting to auth endpoints
- add basic abuse/moderation controls
- add proper admin/moderation audit logging

## Local-only assumptions

The current values are acceptable only as old local defaults while documenting the project:

```txt
localhost
root
empty DB password
127.0.0.1 socket endpoints
static demo tokens
```

They are not suitable for production, public hosting, or shared VPS deployment.

## Secret handling rule

```txt
.env.example is committed.
.env is never committed.
real credentials are never committed.
```

## Safe cleanup order

1. Document current auth flow.
2. Add environment config support.
3. Add local dev seed file.
4. Remove old seeded user rows from default SQL.
5. Replace plain-text passwords.
6. Remove static token/session values.
7. Keep blank-session rejection in the auth checker.
8. Add input validation and rate limiting.
9. Review public deployment separately.
