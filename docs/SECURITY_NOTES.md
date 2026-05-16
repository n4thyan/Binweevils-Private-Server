# Security Notes

This document lists security issues found during the foundation audit.

The current repo should be treated as a local/preservation import, not something ready for public VPS deployment.

## Current high-risk areas

### Plain-text passwords

The imported `users` seed rows use plain-text passwords.

Required future fix:

- use a modern password hashing library
- never commit real account passwords
- ship optional local demo credentials only in a clearly marked dev seed

### Static session/login keys

The imported `users` rows contain static `sessionKey` and `loginKey` values.

Required future fix:

- generate session/login keys at runtime
- rotate tokens on login/logout
- store session data separately from core user profile data

### Hardcoded token response

The current `/connect/token` route returns static token values.

Required future fix:

- generate tokens dynamically
- do not commit real token material
- add expiry handling
- rotate refresh tokens
- avoid logging token request bodies

### Hardcoded database config

`server/db.js` currently uses local database values directly in code.

Required future fix:

- use environment variables
- keep `.env.example` as a template only
- never commit real `.env` files

### Request body logging

Some auth/profile routes currently log request bodies.

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
7. Add input validation and rate limiting.
8. Review public deployment separately.
