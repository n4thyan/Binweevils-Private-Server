# Endpoint Inventory

This file tracks the public HTTP and socket surface that the existing client expects.

The current goal is not to redesign these names immediately. The safer path is to document them, keep compatibility where the Flash/client side needs it, and then modernise the internals behind those routes.

## Observed runtime files

- `server/rest.js` contains the current Express HTTP shim.
- `server/server.js` contains the current WebSocket shim.
- The current HTTP shim serves `static/`, accepts URL-encoded and JSON bodies, and logs with `morgan`.

## HTTP endpoints currently visible in `server/rest.js`

| Method | Path | Current behaviour | Rewrite direction |
| --- | --- | --- | --- |
| `GET` | `/` | Returns `Hello World`. | Replace with a small health/status response. |
| `ALL` | `/v1/logins/:somekey/profiles` | Logs the request body and returns a hard-coded profile array with `id: "AAAA"`. | Keep as a compatibility shim, but back it with real account/profile lookup. |
| `ALL` | `/connect/token` | Checks `grant_type` for `password` or `refresh_token` and returns hard-coded token data. | Replace with proper auth flow, hashed passwords, short-lived access tokens, refresh token rotation, and no static secrets. |
| `ALL` | `/getServer` | Returns `127-0-0-1:10843`. | Move host/port to environment config and return the active game socket endpoint. |
| `ALL` | `/getServerEx` | Returns `127-0-0-1:10842`. Comment says this is for chatroom. | Move host/port to environment config and return the active chat/room socket endpoint. |

## WebSocket commands currently visible in `server/server.js`

The current WebSocket server listens on `127.0.0.1:10843`.

| Incoming message | Current response | Rewrite direction |
| --- | --- | --- |
| Connection open | Sends `login.notify-websocket-connection`. | Keep this compatibility notification if the client depends on it. |
| `friends/get-list{}` | Sends empty `invites` and `buddies` arrays. | Back with a buddy-list table/service. |
| `weevil/get-notifications{}` | Sends zero counts for buddy requests, nest news, and conversations. | Back with notification counters. |

## Legacy socket notes found in comments

`server/server.js` also contains old commented research around room requests and chatroom flow. That block should not be treated as active runtime code, but it is useful when rebuilding rooms because it references:

- public room joins
- private room joins
- private room creation
- multiplayer room requests
- chatroom room requests
- animation message forwarding

Keep that as research until the room protocol is mapped properly.

## Compatibility rule

Do not casually rename legacy endpoints while the old client still needs them. Add modern route names beside them later if needed, for example:

- legacy client route: `/connect/token`
- modern internal route: `/api/auth/token`

The legacy route can then become a thin adapter that calls the modern service.

## Hardening checklist

- Move all hostnames, ports, token secrets, and DB details into environment variables.
- Replace hard-coded token strings with generated tokens.
- Stop logging full auth request bodies once real credentials are involved.
- Add input validation for every HTTP route.
- Add rate limiting to login/token routes.
- Add a structured socket message parser instead of raw string comparisons everywhere.
- Keep protocol response field names stable until the client-side protocol is fully mapped.
