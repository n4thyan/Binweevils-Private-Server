# Legacy Client Contract

This document lists the current paths, cookies, ports, files, and response shapes that appear to be part of the working legacy client flow.

The point of this file is to stop future cleanup from breaking the game by accident.

## Core rule

```txt
Do not change the client-facing contract until the old behaviour is mapped and tested.
```

Internal code can be cleaned later, but these external paths and names should stay stable until a replacement is verified.

## Current browser/Electron entry contract

The legacy Electron launcher opens:

```txt
http://localhost
```

Expected landing page:

```txt
game-full/index.php
```

Important assumption:

```txt
game-full/ is expected to be served as the localhost web root or copied into the localhost web root.
```

## Login contract

Login page:

```txt
/
/index.php
```

Login POST target:

```txt
/login/login.php
```

Expected submitted fields:

```txt
userID
password
```

Successful login redirect:

```txt
../game.php
```

Logout behaviour is also handled by:

```txt
/login/login.php
```

with a logout query/action path used by the current PHP code.

## Registration contract

Registration page:

```txt
/register/index.php
```

Registration POST target:

```txt
/register/create-new-weevil.php
```

Expected submitted fields observed so far:

```txt
userID
password
recap
```

Observed response strings used by the registration page include:

```txt
responseCode=2
responseCode=3
responseCode=999
```

Do not change these values until the registration UI is tested.

## Cookie contract

The working PHP, Flash container, and Node WebSocket layer depend on these cookies:

```txt
weevil_name
sessionId
```

Known consumers:

```txt
game-full/game.php
game-full/essential/internal.php
server/BinWeevilsWeb.js
```

Do not rename these cookies until the whole legacy auth/session bridge is replaced and tested.

## Game container contract

Main game page:

```txt
/game.php
```

Main SWF path embedded by the game page:

```txt
/mainDEV663.swf?ver=1
```

Observed FlashVars:

```txt
cluster=uk
loginPath=http://localhost/
autoBin=false
zone=
```

Do not rename or move the main SWF until all embedded asset loads and endpoint calls are mapped.

## WebSocket bridge contract

`game.php` opens a WebSocket connection to:

```txt
ws://localhost:2087
```

It forwards incoming socket messages to Flash through:

```txt
flashContentObject.receiveFromWS(e.data)
```

Related server mapping:

```txt
server/Main.js -> new BinWeevilsWeb("", 2087)
```

Do not change this bridge before testing the live Flash client flow.

## Legacy game socket contract

`server/Main.js` also starts:

```txt
new BinWeevils("", 9339)
```

Likely role:

```txt
legacy room/game socket server
```

The exact client connection path still needs mapping.

## Express REST shim contract

`server/rest.js` currently listens on:

```txt
1122
```

Observed routes:

```txt
GET /
ALL /v1/logins/:somekey/profiles
ALL /connect/token
ALL /getServer
ALL /getServerEx
```

Observed server-discovery responses:

```txt
/getServer   -> 127-0-0-1:10843
/getServerEx -> 127-0-0-1:10842
```

These may be old or separate from the `Main.js` flow, so do not delete them until tested.

## Session/auth database contract

Important fields currently used across PHP and Node:

```txt
users.id
users.username
users.password
users.active
users.isModerator
users.sessionKey
users.loginKey
users.level
users.mulch
users.dosh
users.tycoon
users.def
users.xp
users.xp1
users.xp2
users.food
users.canSpeak
users.activated
users.lastLogin
users.curHat
users.bannedUntil
users.createdAt
users.loginIP
users.regIP
```

Future cleanup can split this into better tables, but the legacy field names should not be removed until every reader/writer is mapped.

## Response format contract

The legacy client expects mixed response styles:

```txt
query-string style: res=1&userName=...
JSON style: {"responseCode":1,...}
XML/socket style messages
raw string socket commands
```

Do not convert everything to modern JSON in one pass. Build adapters instead.

## Known fragile areas

Treat these as fragile until tested:

```txt
game-full/index.php
game-full/game.php
game-full/login/login.php
game-full/register/create-new-weevil.php
game-full/essential/backbone.php
game-full/essential/internal.php
game-full/essential/config.php
server/Main.js
server/BinWeevils.js
server/BinWeevilsWeb.js
server/Weevil.js
server/rest.js
bwps.sql
/mainDEV663.swf
```

## Safe future strategy

When modernising, preserve the external contract and replace internals behind it.

Example:

```txt
Old route stays: /login/login.php
Modern internal service: AuthService.login()
Old response shape stays until Flash/client replacement is ready.
```

## Do not change yet

- Do not rename `weevil_name` or `sessionId`.
- Do not rename `/game.php`.
- Do not move `/mainDEV663.swf`.
- Do not change `ws://localhost:2087` until the runtime config replacement is tested.
- Do not remove `/connect/token`, `/getServer`, or `/getServerEx` until confirmed unused.
- Do not remove `users.sessionKey` or `users.loginKey` until the auth bridge is replaced.
- Do not rewrite all response formats to JSON in one pass.

## Test checklist for future cleanup

After any real runtime change, test:

- homepage loads
- login form submits
- registration form submits
- cookies are created
- `/game.php` loads after login
- SWF embed appears
- WebSocket connects to port `2087`
- Flash receives socket messages
- room join still works
- profile/stats still load
- logout clears session state

## Rule

```txt
Preserve the contract. Modernise behind it.
```