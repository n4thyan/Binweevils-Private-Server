# Runtime Data Modernisation Notes

Phase 5 starts with a database/runtime audit before changing auth or player bootstrap behaviour.

The legacy database should be treated as compatibility storage first. It was built to make the old Flash/PHP runtime work, not to be the final modern data model.

## Important rule

Do not redesign runtime tables directly under the old game until the compatibility behaviour is mapped.

A table can be inefficient and still be required by the current runtime. The safe route is:

```text
inspect current runtime usage
keep compatibility working
add adapters/helpers
introduce modern tables separately
migrate gradually
remove legacy direct usage later
```

## Confirmed example: buddy list storage

The `buddylist` table stores relationship state in packed list fields:

```text
ownerName
namesList
blockList
requestList
```

This allows values shaped like:

```text
weevil1,weevil2,weevil3,
```

That is inefficient because it is hard to index, hard to search, hard to remove one item safely, and easy to break with duplicate names or trailing commas.

Short-term handling:

```text
keep the old table for compatibility
create only minimum local rows if login/runtime boot needs them
do not build new social features directly on this format
```

Future replacement shape:

```text
buddy_relationships
  id
  requester_user_id
  receiver_user_id
  status
  is_best_friend
  created_at
  updated_at
```

## Other patterns to audit

Do not assume every table has the same issue, but actively check for these patterns:

```text
comma-separated values in one field
pipe/colon encoded runtime state
username-based links instead of stable numeric ids
TEXT/LONGTEXT fields that should be indexed/searchable
missing keys and missing foreign keys
hyphenated table names that require backticks
numeric column names
runtime/player data mixed with catalogue data
account/session fields in the main users table
case-sensitive table-name risks on Linux
```

## Tables that need careful review

The following tables are likely runtime/player-state sensitive and should not be redesigned casually:

```text
users
buddylist
buddyalerts
nest
nestinfo
weevilitems
weevilhats
gardeninventory
taskscompletedbyusers
achievementcounters
achievementscompleted
crossworduserprogress
wordsearchuserprogress
singleplayergames_stats
leaderboardhighscores
multiplayergames
pets
petacquiredskills
redeemedcodes
tycoonbusinesses
```

## Users table notes

The `users` table mixes account/auth data with gameplay state:

```text
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
food
curHat
loginIP
regIP
```

Examples of legacy packed/default runtime state include:

```text
def: 101101406100171700
curHat: |1:-140,-140,-140
```

Short-term handling:

```text
keep the shape for login/runtime compatibility
add a password compatibility helper before local account writes
avoid inserting real emails, IPs, or old session/login keys
```

Future direction:

```text
accounts
account_sessions
player_profiles
player_currency
player_appearance
moderation_state
```

## Inventory/nest notes

Inventory and nest tables mix ownership, placement, colour, room state, and item metadata references.

Examples to inspect before migration:

```text
weevilitems
weevilhats
gardeninventory
nest
nestinfo
```

Future direction should split stable catalogue data from per-player placement/state.

## Quest/progress notes

Quest/progress tables may contain packed task state:

```text
taskscompletedbyusers.tasks
crossworduserprogress.progress
wordsearchuserprogress.progress
```

Short-term handling is to avoid seeding old player progress and only create required local rows after endpoint behaviour is confirmed.

## Phase 5 first milestone

Before writing account/player state:

1. keep the clean schema/seed path working,
2. audit which runtime tables are touched during login/register/game boot,
3. add compatibility helpers instead of direct schema rewrites,
4. only then enable local account creation.

## Not a final schema yet

These notes are not the final modern schema design.

They are a safety map so we do not break the old runtime while modernising the backend in controlled passes.
