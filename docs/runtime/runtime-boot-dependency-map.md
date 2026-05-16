# Runtime Boot Dependency Map

This Phase 5 note maps the legacy PHP/runtime database dependencies that matter before enabling the clean database path for real login testing.

The aim is to avoid guessing which player-state tables are required. The clean path should only create local fixture rows after the runtime dependency is confirmed.

## Current rule

Do not modernise or normalise these tables directly yet.

Keep the legacy table shape working, then add compatibility adapters or replacement tables later.

## Login page flow

Entry point:

```text
game-full/login/login.php
```

Primary table:

```text
users
```

Current dependency:

```text
lookup account by username
verify submitted password against users.password
check active/banned state
write fresh session/login bridge values
write last login timestamp and login IP
set sessionId and weevil_name cookies
redirect to game-full/game.php
```

Clean database impact:

```text
local login cannot work until at least one users row exists
local account writes should stay disabled until password compatibility is implemented
session/login bridge fields are still runtime-critical
```

## Registration flow

Entry point:

```text
game-full/register/create-new-weevil.php
```

Primary tables:

```text
users
buddylist
```

Current dependency:

```text
insert new users row
create a buddylist row for the username
set sessionId and weevil_name cookies
redirect to game-full/game.php
```

Clean database impact:

```text
fresh accounts probably need a users row plus a buddylist row
registration should hash new passwords after compatibility helper lands
old celebrity/mod/staff rows must not be imported as fixtures
```

## Session bridge

Important helper:

```text
confirmSessionKey()
getLoginDetails()
```

Primary table:

```text
users
```

Current dependency:

```text
sessionId cookie must match users.sessionKey
weevil_name cookie must match users.username
getLoginDetails returns id, username, tycoon state, and loginKey
```

Clean database impact:

```text
runtime expects users.sessionKey and users.loginKey for now
do not remove those fields until the Flash/PHP bridge is replaced
```

## Basic player stats boot

Important helper:

```text
getWeevilStats()
```

Primary table:

```text
users
```

Current dependency:

```text
reads level, mulch, dosh, xp, food, activation/chat state, and email presence
returns the old query-string payload expected by the game runtime
```

Clean database impact:

```text
minimum local user rows need sensible default gameplay values
users table currently doubles as account plus profile state
```

## Weevil profile lookups

Important helpers:

```text
weevilGetData()
weevilData()
getAllWeevilStats()
getAllWeevilStatsByName()
```

Primary table:

```text
users
```

Current dependency:

```text
reads id, username, visual definition, level, tycoon state, and created timestamp
```

Clean database impact:

```text
local fixture users need a valid weevil definition and created timestamp
appearance/profile modernisation should be deferred behind compatibility helpers
```

## Buddy list dependency

Table:

```text
buddylist
```

Schema shape:

```text
ownerName
namesList
blockList
requestList
```

Current risk:

```text
packed list fields are inefficient and hard to query
runtime likely expects the legacy shape for buddy UI paths
```

Clean database impact:

```text
create only an empty buddylist row for local users if needed
normalised buddy relationships should be future work, not default Phase 5 boot work
```

## Nest and inventory dependency

Likely tables:

```text
nest
nestinfo
weevilitems
weevilhats
gardeninventory
```

Known schema risks:

```text
owner links are inconsistent across username/id fields
nest fields include packed state defaults
inventory and placement state are partly mixed
```

Clean database impact:

```text
do not create starter rows until a boot endpoint proves they are required
keep these tables empty in default seeds
create local-only fixture rows from tooling, not from catalogue seeds
```

## Catalogue/reference dependency

Already included in the clean seed path:

```text
itemtype
itemtypets
appareltypes
gardenitemtype
seeds
puzzletypes
crosswords
questtasks
```

Clean database impact:

```text
catalogue/reference data is safe to seed by default
player/runtime data should remain generated locally only
```

## Tables to avoid in default seeds

```text
users
buddyalerts
buddylist
nest
nestinfo
weevilitems
weevilhats
gardeninventory
taskscompletedbyusers
achievementcounters
game-logs
game-rewards
redeemedcodes
tycoonbusinesses
```

These belong in runtime/local fixture generation only after the actual dependency is confirmed.

## Next safe runtime pass

The next runtime-changing PR should be limited to auth compatibility:

```text
add PHP password compatibility helper
update login flow to verify both modern hashes and old local legacy values
update registration so new accounts store hashed values
update admin login helper to use the same verifier
keep local account tool non-writing until this passes review
```

## Later fixture pass

After auth compatibility lands:

```text
enable tools/create_local_account.py --execute for local_admin/local_demo only
create local users row
create empty buddylist row only if required
leave nest/inventory/progress rows empty until endpoints prove they are needed
```
