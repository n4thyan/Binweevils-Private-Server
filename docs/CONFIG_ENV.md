# Environment Config Notes

This document explains the config cleanup pass.

The goal of this phase is to move hardcoded local values behind environment-aware config while keeping the imported localhost setup working by default.

## Node config helper

Node config is centralised in:

```txt
server/config.js
```

It loads optional local values from:

```txt
.env
server/.env
```

If neither file exists, it falls back to the legacy localhost defaults.

No new dependency is required for this config pass.

## Files covered by config so far

```txt
server/config.js
server/db.js
server/Main.js
server/server.js
server/rest.js
game-full/essential/config.php
.env.example
docs/SETUP_LOCAL.md
```

## Database config

Node and PHP both use the same database environment variable names.

Default values remain:

```txt
DB_HOST=localhost
DB_PORT=3306
DB_NAME=bwps
DB_USER=root
DB_PASSWORD=
```

Node reads these through `server/config.js`.

PHP reads these in:

```txt
game-full/essential/config.php
```

PHP currently reads:

```txt
DB_HOST
DB_USER
DB_PASSWORD
DB_NAME
```

`DB_PORT` is documented for Node and future PHP/database cleanup, but the legacy PHP config constants currently preserve the original host/user/pass/name-only contract.

These defaults are safe only as local defaults. They are not production/VPS settings.

## Main Node server config

`server/Main.js` reads its bind host and ports from config.

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

`server/server.js` reads its host and port from config.

Defaults remain:

```txt
LEGACY_SHIM_HOST=127.0.0.1
LEGACY_SHIM_PORT=10843
```

This file is still marked as uncertain because it imports a missing `./xmlsocket` helper.

## REST shim config

`server/rest.js` now consumes REST shim settings from `server/config.js`.

Current keys:

```txt
REST_HOST=
REST_PORT=1122
REST_GET_SERVER_RESPONSE=127-0-0-1:10843
REST_GET_SERVER_EX_RESPONSE=127-0-0-1:10842
REST_DEV_AUTH_A=dev-auth-a
REST_DEV_AUTH_B=dev-auth-b
```

Preserved defaults:

```txt
/getServer   -> 127-0-0-1:10843
/getServerEx -> 127-0-0-1:10842
REST port    -> 1122
```

The old static compatibility auth values have been replaced with local placeholder config values. This is not real authentication yet. A later auth rewrite should replace the whole compatibility shim with proper account-backed logic while preserving the legacy route contract.

## PHP config status

The PHP side now supports environment overrides for database config while keeping the old XAMPP defaults.

Current PHP defaults remain:

```txt
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=bwps
```

No PHP endpoint paths, cookies, login logic, registration logic, or SQL queries were changed in this pass.

## Compatibility rule

```txt
No env values = old localhost defaults.
env values = local override.
```

This keeps the project runnable in the old local style while allowing safer config later.

## Remaining config cleanup

Recommended follow-up:

```txt
server/package-scripts
```

## Rule

```txt
Config first. Behaviour changes later.
```