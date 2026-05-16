# Legacy File Map

This document maps the imported project layout without changing runtime files.

The purpose is to identify what appears active, what is fragile, and what should be audited before cleanup.

## Top-level layout

```txt
electron/      Legacy Electron/Pepper Flash launcher
server/        Node.js socket/web/private server layer
game-full/     Preserved web/game compatibility layer
bwps.sql       Imported MySQL/MariaDB database dump
docs/          Rewrite documentation
.env.example   Future config template
```

## electron/

### Current role

`electron/` is the legacy desktop launcher/client wrapper.

Observed files:

```txt
electron/main.js
electron/package.json
electron/plugins/
```

### Behaviour observed

`electron/main.js`:

- enables plugin support
- appends a Pepper Flash plugin path depending on OS
- sets a PPAPI Flash version
- opens an 800x600 browser window
- loads `http://localhost`
- removes the Electron menu

### Current issues

`electron/package.json` still has unrelated placeholder identity:

```txt
name: freeze-penguin-client
description: A Freeze Penguin Client
author: Lau
```

This should be cleaned in a later launcher identity branch, but launcher behaviour should stay unchanged until tested.

### Treatment

```txt
Status: active/legacy
Risk: medium
Touch now: no
Future branch: electron/launcher-identity
```

## server/

### Current role

`server/` contains the Node.js runtime layer.

Observed active files include:

```txt
server/Main.js
server/BinWeevils.js
server/BinWeevilsWeb.js
server/Weevil.js
server/WeevilKartGame.js
server/ExtensionHelper.js
server/db.js
server/rest.js
server/server.js
server/package.json
server/roomids.txt
server/profanity.txt
```

### Main legacy server entry point

`server/Main.js` appears to be the main private server entry point:

```txt
new BinWeevils("", 9339)
new BinWeevilsWeb("", 2087)
```

This suggests two runtime services:

- legacy socket/game server on port `9339`
- web socket/web compatibility server on port `2087`

This should be confirmed by running the project locally before scripts are added.

### BinWeevils.js

`server/BinWeevils.js` appears to manage the main legacy socket/game world.

Observed responsibilities:

- tracks connected weevils
- manages room IDs from `roomids.txt`
- handles profanity filter setup from `profanity.txt`
- handles dynamic nest rooms
- tracks minigame/leaderboard state
- imports `Weevil` and `WeevilKartGame`

Treatment:

```txt
Status: likely active
Risk: high
Touch now: no
```

### BinWeevilsWeb.js

`server/BinWeevilsWeb.js` appears to manage a WebSocket/HTTPS compatibility layer.

Observed responsibilities:

- creates a WebSocket server attached to an HTTPS server
- verifies users from cookies named `weevil_name` and `sessionId`
- sends buddy online/offline/request notifications
- handles commands such as `friends/get-list`, `weevil/get-notifications`, `friends/get-weevil`, `friends/send-request`, and `ping/pong`

Treatment:

```txt
Status: likely active
Risk: high
Touch now: no
```

### Weevil.js

`server/Weevil.js` is the main player/session model.

Observed responsibilities:

- verifies login data against the `users` table
- reads `loginKey`, `active`, `isModerator`, `def`, `canSpeak`, and `curHat`
- handles room joins and player spawning
- manages buddy, nest, minigame, profile, chat, and player state logic

Treatment:

```txt
Status: likely active
Risk: high
Touch now: no
```

### rest.js

`server/rest.js` is an Express HTTP compatibility shim.

Observed endpoints:

```txt
GET /
ALL /v1/logins/:somekey/profiles
ALL /connect/token
ALL /getServer
ALL /getServerEx
```

Treatment:

```txt
Status: possibly active depending on launch flow
Risk: medium/high because auth/token behaviour is unsafe
Touch now: no
Future branch: config/env-support
```

### server.js

`server/server.js` is a smaller WebSocket shim on `127.0.0.1:10843`.

Observed behaviour:

- sends `login.notify-websocket-connection`
- handles `friends/get-list{}`
- handles `weevil/get-notifications{}`
- imports `./xmlsocket`, but that file was not found during this audit

Treatment:

```txt
Status: uncertain/possibly old shim
Risk: medium
Touch now: no
Needs follow-up: confirm whether it runs or is superseded by Main.js/BinWeevilsWeb.js
```

### db.js

`server/db.js` contains hardcoded local MySQL settings.

Treatment:

```txt
Status: active dependency of Weevil.js
Risk: high for public deployment
Touch now: no
Future branch: config/env-support
```

### package.json

`server/package.json` contains dependencies only, with no name, scripts, engines, or clear entry point.

Notable dependencies:

```txt
express
mysql
xml2js
ws is used by files but should be checked in package-lock/dependency tree
request
leo-profanity
isprofanity
discord.js
@discordjs/opus
```

Treatment:

```txt
Status: active package manifest
Risk: low to document, medium to edit
Future branch: server/package-scripts
```

## game-full/

### Current role

`game-full/` is the preserved Flash/site compatibility layer.

It should be treated as fragile because the client may depend on exact paths and filenames.

Likely important areas:

```txt
game-full/php/
game-full/php2/
game-full/login/
game-full/register/
game-full/essential/
game-full/externalUIs/
game-full/fixedCam/
game-full/cdn.binw.net/
game-full/profilePics/
game-full/static/
game-full/www.* mirror/cache folders
SWF files
XML files
crossdomain.xml
flashpolicy.xml
```

Detailed notes are now split into:

```txt
docs/GAME_FULL_MAP.md
docs/CLIENT_CONTRACT.md
```

### Treatment

```txt
Status: active/compatibility layer
Risk: very high
Touch now: no
Future branch: audit/game-full-endpoints
```

## bwps.sql

### Current role

`bwps.sql` is the imported database dump.

It currently mixes:

- schema
- catalogue data
- seeded users
- account-owned starter rows
- legacy runtime data

### Treatment

```txt
Status: active import source
Risk: high
Touch now: no
Future branch: database/schema-seed-split
```

## Missing or uncertain items

### `server/server.js` imports `./xmlsocket`

`server/server.js` imports:

```js
const xmlsocket = require("./xmlsocket")();
```

During this audit, `server/xmlsocket.js` and `server/xmlsocket/index.js` were not found.

This suggests one of:

- `server/server.js` is stale/unused
- the file is missing from the import
- the xmlsocket helper lives under a different name/path

Do not delete `server/server.js` yet. First confirm the actual startup flow.

## Recommended follow-up branches

```txt
audit/game-full-endpoints
server/package-scripts
config/env-support
electron/launcher-identity
database/schema-seed-split
```

## Rule

```txt
Map first. Change second. Delete last.
```