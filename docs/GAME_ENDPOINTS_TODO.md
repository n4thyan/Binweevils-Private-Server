# Game Endpoint Audit TODO

This is the remaining endpoint audit list before real cleanup work begins.

The current PR mapped the main boot/login/game path. This file records what still needs deeper inspection in follow-up branches.

## Purpose

The Flash client and old PHP files may depend on exact endpoint names, response formats, cookies, and path locations.

Before any endpoint is renamed, deleted, or modernised, it should be listed here, tested, then moved into the main endpoint inventory.

## Already mapped in this audit phase

Mapped at a high level:

```txt
/
/index.php
/login/login.php
/register/index.php
/register/create-new-weevil.php
/game.php
/mainDEV663.swf?ver=1
ws://localhost:2087
server/Main.js ports 9339 and 2087
server/rest.js port 1122
```

Also documented:

```txt
weevil_name cookie
sessionId cookie
loginKey field
sessionKey field
users table account/session fields
```

## PHP areas still needing endpoint inventory

Audit these folders in a later branch:

```txt
game-full/php/
game-full/php2/
game-full/nest/
game-full/weevil/
game-full/shop/
game-full/profile/
game-full/garden/
game-full/messages/
game-full/buddy/
game-full/leaderboard/
game-full/admin/
game-full/essential/
```

Some of these folders may not exist exactly under those names. Treat this as a search list, not proof of current structure.

## Endpoint categories to map

### Account/session

Look for endpoints that read or write:

```txt
users.username
users.password
users.sessionKey
users.loginKey
users.active
users.bannedUntil
users.canSpeak
users.isModerator
```

### Avatar/weevil data

Look for endpoints that read or write:

```txt
users.def
users.curHat
users.level
users.xp
users.food
users.mulch
users.dosh
```

### Inventory/shop

Look for endpoints that handle:

```txt
buying hats
buying nest items
buying garden items
owned inventory
starter items
catalogue item IDs
currency deduction
```

### Nest/garden/rooms

Look for endpoints that handle:

```txt
nest state
room layouts
garden layouts
placed items
visitor rooms
dynamic rooms
```

### Social/buddy/messages

Look for endpoints or socket messages that handle:

```txt
buddy list
buddy requests
best friends
private messages
notifications
online/offline status
```

### Moderation/admin

Look for endpoints that handle:

```txt
ban
mute
canSpeak
admin login
admin logs
game logs
moderator checks
```

### Minigames/leaderboards

Look for endpoints that handle:

```txt
scores
leaderboards
game IDs
weekly tables
multiplayer joins
```

## Response formats to preserve

The project currently appears to use mixed legacy formats.

When mapping an endpoint, record its exact response style:

```txt
query-string response
JSON response
XML response
raw socket string
redirect
plain text response code
```

Do not standardise these yet. Just document them.

## Suggested endpoint inventory table

Use this format when adding endpoint details:

| Area | Method | Path | Reads | Writes | Response format | Risk | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| login | POST | `/login/login.php` | `users` | `sessionKey`, `loginKey`, cookies | redirect | high | active login path |

## Search terms for the next audit branch

Useful search terms:

```txt
$_GET
$_POST
$_COOKIE
sessionId
weevil_name
loginKey
sessionKey
mysql
mysqli
UPDATE users
INSERT INTO users
SELECT * FROM users
responseCode
getData
buy
nest
shop
buddy
friend
profile
mulch
dosh
canSpeak
isModerator
```

## Branch recommendation

Next endpoint-specific audit branch:

```txt
audit/game-full-endpoints
```

That branch should only map endpoints. It should not rewrite PHP yet.

## Rule

```txt
Every legacy endpoint needs a contract before it gets cleaned.
```