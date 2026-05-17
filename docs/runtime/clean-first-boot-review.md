# Clean First-Boot Review

This Phase 5 review records what happens immediately after login when the runtime redirects to the game page.

The goal is to avoid guessing starter rows for clean local accounts.

## Entry point

```text
game-full/game.php
```

## What `game.php` currently does

The page is mostly a bridge into the old Flash runtime.

At the PHP level it currently:

```text
loads essential/backbone.php
sets basic security headers
requires weevil_name and sessionId cookies
calls confirmSessionKey(weevil_name, sessionId)
redirects to ../ if the session bridge fails
renders the old page shell
embeds /mainDEV663.swf?ver=1
passes FlashVars including loginPath=http://localhost/
starts a browser WebSocket connection to ws://localhost:2087
```

## Immediate clean database dependency

For this page alone, the clean account path needs:

```text
users.username
users.sessionKey
```

These are needed so `confirmSessionKey(...)` accepts the cookies created by login/register.

The page itself does not create or directly require:

```text
nest rows
nestinfo rows
weevilitems rows
weevilhats rows
gardeninventory rows
tasks/progress rows
```

## Important boundary

A clean local account can reach `game.php` if the session bridge works, but that does not prove the full game can boot.

The real first-boot requirements are likely triggered after the SWF loads and starts calling PHP endpoints or socket messages.

That means starter rows should not be guessed from the database schema alone.

## Known post-page runtime surfaces

Once the page renders, the client/runtime surface includes:

```text
/mainDEV663.swf?ver=1
FlashVars loginPath=http://localhost/
WebSocket ws://localhost:2087
server/rest.js compatibility endpoints
server/server.js socket commands
legacy PHP endpoints called by the SWF
```

## Starter-row rule

Do not add starter rows just because a table exists.

Only add local fixture rows when one of these proves it is required:

```text
a PHP endpoint errors because a row is missing
a socket command errors because a row is missing
the SWF boot sequence expects a specific payload
a local/manual boot trace shows a missing-row dependency
```

## Current minimum local account state

The current safe local state remains:

```text
users row
buddylist row
```

The `users` row provides account/session/profile defaults.

The `buddylist` row is created because registration already creates one and the buddy UI/socket paths are expected to need the legacy packed-list shape.

## Do not add yet

```text
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

These should stay out of default clean seeds until runtime evidence proves the exact minimum local fixture shape.

## Next safe test shape

The next practical test should be a local/manual trace rather than a blind seed change:

```text
create local_demo through the clean database path
log in or set matching session cookies locally
load game-full/game.php
record PHP errors, network calls, and socket messages
identify the first missing runtime row or endpoint mismatch
add one minimal local fixture only if required
repeat
```

## Why this matters

The legacy database mixes account, profile, inventory, nest, task, and event state. Adding lots of default rows too early would make the clean path look like it works while hiding real runtime dependencies.

Phase 5 should keep the clean account path small until first-boot traces prove more is needed.
