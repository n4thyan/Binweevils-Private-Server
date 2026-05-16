# Current Run Flow Map

This file maps the current imported run flow as it is understood so far.

It is intentionally conservative. The goal is to document what appears to happen before changing any runtime code.

## High-Level Flow

```txt
Browser/Electron
    -> http://localhost
        -> local web server serving game-full/
            -> Flash client / preserved files
                -> PHP endpoints and XML/config files
                -> Node REST/socket compatibility services
                    -> MySQL/MariaDB bwps database
```

## Local Web Layer

The legacy Electron client loads:

```txt
http://localhost
```

That means the local web server needs to serve the game entry point from localhost.

Current assumption:

```txt
game-full/ should be served as the local web root or copied into the local web root.
```

This should be verified against the original setup before changing paths.

## Flash / Compatibility Layer

The Flash client and preserved site files may depend on exact paths.

Do not rename these until mapped:

```txt
game-full/
game-full/php2/
game-full/php/
game-full/externalUIs/
game-full/fixedCam/
game-full/cdn.binw.net/
main_*.swf
core*.swf
crossdomain.xml
flashpolicy.xml
```

## Database Layer

The imported database is currently:

```txt
bwps.sql
```

Current server DB config points at:

```txt
host: localhost
user: root
password: empty
database: bwps
port: 3306
```

Future work should move this to env/config after local setup is verified.

## Node REST Layer

Known file:

```txt
server/rest.js
```

Observed compatibility endpoints include:

```txt
/
/v1/logins/:somekey/profiles
/connect/token
/getServer
/getServerEx
```

Current behaviour to preserve while refactoring:

- `/getServer` returns the local WebSocket target.
- `/getServerEx` returns the local chatroom/socket target.
- `/connect/token` currently behaves like a local auth shim.

The endpoint names should remain stable until the client call chain is mapped.

## Node WebSocket Layer

Known file:

```txt
server/server.js
```

Observed behaviour:

- Starts a WebSocket server on local loopback.
- Sends a `login.notify-websocket-connection` response on connect.
- Responds to at least:

```txt
friends/get-list{}
weevil/get-notifications{}
```

This is likely a compatibility shim for the original client.

## Electron Layer

Known file:

```txt
electron/main.js
```

Observed behaviour:

- Enables plugin support.
- Adds a Pepper Flash plugin path depending on platform.
- Loads `http://localhost`.
- Removes the menu.

This launcher is legacy but useful as a working path. Do not remove it until a replacement launch path is tested.

## Future Ruffle Path

A future browser/Ruffle path could sit beside the legacy launcher.

Possible future flow:

```txt
modern browser page
    -> Ruffle embed
        -> preserved SWF/client assets
        -> same compatibility endpoints
```

This should be added as an optional path, not as a replacement until tested.

## Known Unknowns

Still to map:

- Exact game entry file served at `http://localhost`
- Required Apache/PHP config
- All PHP endpoints called by the client
- All socket messages expected by the client
- Which Node services must run together
- Whether `server/rest.js` and `server/server.js` are both required for the current working setup
- Which tables are required for login/register/player state
- Which SQL rows are old runtime data vs required game catalog data

## Rule

```txt
Keep the client-facing path and response shape stable while cleaning internals.
```