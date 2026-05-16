# Environment Config Notes

This document explains the first Node-side config cleanup pass.

The goal of this phase is to move hardcoded local values behind a small config helper while keeping the imported localhost setup working by default.

## Config helper

Node config is now centralised in:

```txt
server/config.js
```

It loads optional local values from:

```txt
.env
server/.env
```

If neither file exists, it falls back to the legacy localhost defaults.

No new dependency is required for this first pass.

## Files changed in this pass

```txt
server/config.js
server/db.js
server/Main.js
server/server.js
.env.example
docs/SETUP_LOCAL.md
```

## Database config

`server/db.js` now reads database settings from `server/config.js`.

Default values remain:

```txt
DB_HOST=localhost
DB_PORT=3306
DB_NAME=bwps
DB_USER=root
DB_PASSWORD=
```

These are safe only as local defaults. They are not production/VPS settings.

## Main Node server config

`server/Main.js` now reads its bind host and ports from config.

Defaults remain:

```txt
NODE_BIND_HOST=
GAME_SOCKET_PORT=9339
WEB_SOCKET_PORT=2087
```

That preserves the old startup contract:

```txt
BinWeevils game/socket server -> 9339
BinWeevilsWeb socket bridge  -> 2087
```

## Older shim config

`server/server.js` now reads its host and port from config.

Defaults remain:

```txt
LEGACY_SHIM_HOST=127.0.0.1
LEGACY_SHIM_PORT=10843
```

This file is still marked as uncertain because it imports a missing `./xmlsocket` helper.

## REST shim config status

`server/config.js` and `.env.example` include REST shim settings for a follow-up pass:

```txt
REST_HOST=
REST_PORT=1122
REST_GET_SERVER_RESPONSE=127-0-0-1:10843
REST_GET_SERVER_EX_RESPONSE=127-0-0-1:10842
```

`server/rest.js` should be updated in a separate small PR after this one.

Reason: the current file contains old static auth-shim material. It is better to update and review that file on its own rather than mixing it into the first config pass.

## PHP config status

The PHP side still uses:

```txt
game-full/essential/config.php
```

That file was not changed in this PR.

PHP config should be handled separately because `game-full/` is a fragile compatibility layer.

## Compatibility rule

```txt
No .env file = old localhost defaults.
.env file = local override.
```

This keeps the project runnable in the old local style while allowing safer config later.

## Next config cleanup branches

Recommended follow-up order:

```txt
config/rest-shim-env
config/php-env-support
server/package-scripts
```

## Rule

```txt
Config first. Behaviour changes later.
```