# Local Account Setup Plan

This document plans fresh local demo/admin account setup for the experimental clean database path.

It does not copy any account rows from the legacy dump.

## Why this is needed

The clean import path currently creates schema and catalogue/reference seed data only:

```text
database/schema/001_base_schema.sql
database/schema/002_keys_auto_increment.sql
database/seeds/001_catalogue_reference.sql
```

That leaves runtime/player tables empty, including:

```text
users
buddylist
nest
nestinfo
weevilitems
```

That is good for safety, but the old PHP runtime will eventually need fresh local accounts and minimum starter state to log in and test.

## `users` table shape

Current columns from the generated schema:

```text
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

Important defaults already exist for several gameplay fields:

```text
level: 1
mulch: 5000
dosh: 25
tycoon: 1
def: 101101406100171700
xp: 0
xp1: 0
xp2: 30
food: 100
canSpeak: 0
activated: 0
curHat: |1:-140,-140,-140
active: 1
bannedUntil: 0
```

## Fresh local account names

Use obvious disposable local names only:

```text
local_admin
local_demo
```

Do not use:

```text
old moderator names
old celebrity account names
old private-server usernames
copied rows from bwps.sql
real user emails
real IP addresses
```

## Password handling rule

Do not hard-code a real password in a committed SQL seed file.

Use a local setup script or command that reads account passwords from environment variables.

Suggested variables:

```text
BWPS_ADMIN_PASSWORD
BWPS_DEMO_PASSWORD
```

If the legacy runtime expects plaintext passwords, document that as a compatibility debt and keep the generated accounts local-only until authentication is modernised.

## Session/login keys

Fresh setup should generate fake local-only values for:

```text
sessionKey
loginKey
```

Do not copy keys from the old dump.

A future setup script can generate random hex strings at runtime.

## IP fields

Fresh local setup should avoid real IP addresses.

Use empty strings or local placeholders only:

```text
loginIP: 127.0.0.1
regIP: 127.0.0.1
```

If the runtime does not require those columns, prefer empty strings.

## Minimum starter state to investigate

The old runtime may require more than a `users` row. Before adding a script, inspect PHP endpoint behaviour for these tables:

```text
buddylist
nest
nestinfo
weevilitems
weevilhats
gardeninventory
taskscompletedbyusers
achievementcounters
```

Only create rows that are genuinely required for login/room bootstrapping.

## Proposed script shape

Future script:

```text
tools/create_local_account.py
```

Possible arguments:

```text
--database-url mysql://root:root@127.0.0.1:3306/bwps_clean_test
--username local_admin
--password-from-env BWPS_ADMIN_PASSWORD
--moderator
```

A second call could create:

```text
--username local_demo
--password-from-env BWPS_DEMO_PASSWORD
```

## Out of scope for this plan

This plan does not:

- create real account rows,
- add committed password hashes/plaintext passwords,
- insert old user data,
- insert old buddy lists,
- insert old nest/player state,
- change PHP authentication logic,
- change runtime endpoints.

## Next step

Before writing `tools/create_local_account.py`, inspect the registration/login PHP flow to confirm whether the legacy runtime expects plaintext passwords, MD5, SHA, or another format.
