# Auth and Account Flow Notes

This file documents the current authentication/account shape before any runtime cleanup is attempted.

The goal is to understand how accounts are represented, where legacy shortcuts exist, and what needs replacing in later code-focused PRs.

## Current auth/account surfaces

Known surfaces so far:

```txt
server/rest.js
server/db.js
server/server.js
bwps.sql
```

The current account system appears to be split between:

- a MySQL/MariaDB `users` table in `bwps.sql`
- hardcoded local database connection settings in `server/db.js`
- compatibility token/profile routes in `server/rest.js`
- WebSocket connection notification and simple client response stubs in `server/server.js`

## Database-backed account shape

The `users` table currently contains these important fields:

```txt
id
username
password
email
isModerator
sessionKey
loginKey
level
mulch
dosh
tycoon
def
xp
xp1
xp2
food
canSpeak
activated
lastLogin
curHat
invitedBy
active
bannedUntil
createdAt
loginIP
regIP
```

This table mixes identity, auth/session state, player stats, moderation status, avatar defaults, economy values, and IP logging into one table.

That is acceptable for understanding the legacy base, but it should not be the final modern design.

## Seeded users in current SQL

The imported dump currently includes seeded local users.

Observed issues:

- passwords are plain text
- session keys are static
- login keys are static
- local IP values are stored in the dump
- usernames are old test/runtime data, not clean modern seed data
- one seeded account has an extremely high level/xp value

These rows should eventually move out of the default database import.

Future target:

```txt
database/schema.sql              table structure only
database/seeds/catalogue.sql     game catalogue/content data
database/seeds/dev.sql           optional local demo accounts only
```

## Current REST auth shim

`server/rest.js` currently has a `/connect/token` route.

Observed behaviour:

- accepts `password` and `refresh_token` grant types
- logs the request body
- returns hard-coded refresh token and access token values
- does not currently appear to validate a username/password against `users`

This is useful as a compatibility shim, but not safe as real authentication.

Rewrite direction:

- keep `/connect/token` as a legacy adapter if the client expects it
- move real auth into a small internal service
- validate credentials against the database
- hash passwords with a modern password hash
- generate short-lived access tokens at runtime
- rotate refresh tokens
- stop logging auth request bodies
- add rate limiting before any public deployment

## Current profile route

`server/rest.js` also has `/v1/logins/:somekey/profiles`.

Observed behaviour:

- logs the request body
- returns a hard-coded profile object with `id: "AAAA"`

Rewrite direction:

- keep the legacy route path while the client needs it
- resolve `:somekey` to a login/session record
- return the real profile/account information expected by the client
- add a modern internal profile service behind the legacy route

## Current socket auth/connection hint

`server/server.js` currently sends this connection notification on WebSocket connect:

```txt
login.notify-websocket-connection
```

This may be a client compatibility requirement.

Rewrite direction:

- keep the connection notification until tested
- add proper session validation around socket connections later
- map all expected socket messages before changing response shapes

## Registration/starter data direction

The SQL dump also includes account-owned starter rows such as starter businesses/inventory tied to seeded accounts.

Those should not stay as static rows in the default dump.

Future target:

- account creation creates the base `users` row
- registration/bootstrap code creates starter inventory
- registration/bootstrap code creates starter business rows if required
- starter values come from config or seed templates, not copied old user rows

## Future modern auth model

A cleaner future split could look like:

```txt
users
user_auth
user_sessions
weevil_profiles
weevil_inventory
tycoon_businesses
moderation_flags
```

Do not jump straight to this split while the Flash/client expectations are still unknown. First keep compatibility, then refactor internally.

## Immediate cleanup order

1. Keep current legacy account flow documented.
2. Confirm which route the client actually uses for login/register.
3. Confirm whether any PHP files also read/write `users`.
4. Create a safe `dev` seed with one demo account only.
5. Remove old seeded runtime users from default import.
6. Replace plain-text passwords with hashed passwords.
7. Generate session/login keys at runtime.
8. Add minimal rate limiting and body validation.

## Do not do yet

- Do not remove seeded users until a clean demo seed exists.
- Do not rename `users` fields until all readers/writers are mapped.
- Do not change `/connect/token` response shape until the client is tested.
- Do not remove `login.notify-websocket-connection` until the socket flow is tested.

## Rule

```txt
Keep legacy paths. Replace unsafe internals behind them.
```