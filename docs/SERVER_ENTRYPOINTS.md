# Server Entrypoint Map

This document maps known Node.js server entry points and what they appear to do.

No runtime files were changed while creating this map.

## Main.js

Current code:

```js
var BinWeevils = require("./BinWeevils");
var BinWeevilsWeb = require("./BinWeevilsWeb");
var s = new BinWeevils("", 9339);
var x = new BinWeevilsWeb("", 2087);
s.runServer();
x.runServer();
```

Likely role:

- Main legacy startup file.
- Starts the XML/socket-style game server.
- Starts the web socket compatibility server.

Ports:

```txt
9339 = BinWeevils game/socket server
2087 = BinWeevilsWeb HTTPS/WebSocket layer
```

Needs confirmation by local run test.

## BinWeevils.js

Likely role:

- Main room/game server class.
- Tracks connected weevils.
- Handles dynamic nest rooms.
- Loads room IDs from `roomids.txt`.
- Loads profanity filter words from `profanity.txt`.
- Tracks minigame and leaderboard state.

Important dependencies:

```txt
Weevil.js
WeevilKartGame.js
roomids.txt
profanity.txt
xml2js
leo-profanity
line-reader
moment
```

## BinWeevilsWeb.js

Likely role:

- WebSocket compatibility server.
- Creates an HTTPS server and attaches WebSocket to it.
- Verifies cookies called `weevil_name` and `sessionId`.
- Sends buddy notifications.
- Handles JSON-ish client commands.

Observed commands include:

```txt
friends/get-list
weevil/get-notifications
friends/get-weevil
nest-news
friends/send-request
friends/handle-request
friends/delete
ping/pong
```

Notable cleanup issue:

`nest-news` currently includes an old Discord invite URL. That should be removed or replaced later as runtime/community data cleanup, but not in this audit branch.

## Weevil.js

Likely role:

- Player/session model.
- Handles login verification.
- Handles room joins.
- Sends XML responses to the legacy client.
- Talks to the database through `db.js`.
- Contains large amounts of gameplay and social behaviour.

Important account fields read during login:

```txt
id
isModerator
def
loginKey
canSpeak
curHat
active
```

Login notes:

- Login parses legacy XML-style data.
- Server must equal `Mulch`.
- It checks whether `loginKey` includes the first 5 characters sent by the client.
- It rejects inactive users.
- It adds a dynamic nest room after login.

This logic is fragile and should be preserved until a full auth replacement is tested.

## rest.js

Likely role:

- Local Express HTTP shim.
- Provides compatibility endpoints for token/profile/server discovery.

Observed listening port:

```txt
1122
```

Observed endpoints:

```txt
/
/v1/logins/:somekey/profiles
/connect/token
/getServer
/getServerEx
```

Risk:

- hardcoded tokens
- request-body logging
- hardcoded local socket targets

## server.js

Likely role:

- Smaller/older WebSocket shim.
- May be experimental or superseded by `Main.js` and `BinWeevilsWeb.js`.

Observed listening port:

```txt
10843
```

Observed issue:

It imports `./xmlsocket`, but that file was not found during this audit.

Do not rely on this as the main start file until tested.

## Current uncertainty

There are at least three possible server start surfaces:

```txt
node Main.js
node rest.js
node server.js
```

The likely local runtime may need:

```txt
node Main.js
node rest.js
```

`node server.js` may fail because of the missing `xmlsocket` import.

This should be tested locally before adding npm scripts.

## Recommended package scripts later

Only after testing, likely scripts could be:

```json
{
  "scripts": {
    "start": "node Main.js",
    "start:rest": "node rest.js",
    "start:legacy-ws": "node server.js"
  }
}
```

Do not add these until the start flow is confirmed.

## Rule

```txt
Do not add npm scripts until the correct startup order is tested.
```