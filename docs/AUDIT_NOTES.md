# Initial Audit Notes

These notes record the first non-destructive audit pass.

No fragile game files were moved, renamed, or rewritten during this pass.

## Scope Checked So Far

Initial files reviewed:

```txt
bwps.sql
server/db.js
server/server.js
server/rest.js
server/package.json
electron/package.json
```

## Database Dump

`bwps.sql` is currently an imported phpMyAdmin/MariaDB dump for the `bwps` database.

Observed points:

- It contains schema and data mixed together.
- It contains old runtime rows, not just clean structure.
- Some tables contain old usernames and buddy-related state.
- Some shop/item rows include legacy fan/community/event notes.
- It should not remain the final canonical database format.

Future target:

```txt
database/schema.sql
database/seed.example.sql
```

`schema.sql` should contain table definitions only.

`seed.example.sql` should contain safe local demo data only.

## Server Database Config

`server/db.js` currently uses hardcoded local MySQL settings.

Current pattern:

```txt
host: localhost
user: root
password: empty
database: bwps
port: 3306
```

This is fine as an old local default, but should become environment-based config later.

Target direction:

```txt
process.env.DB_HOST
process.env.DB_PORT
process.env.DB_NAME
process.env.DB_USER
process.env.DB_PASSWORD
```

Do not change this until the working local setup is tested, because the current server may depend on the old defaults.

## WebSocket Server

`server/server.js` currently starts a WebSocket server on local loopback and returns a small set of hardcoded compatibility responses.

Observed points:

- Host/port are hardcoded.
- Some responses are hardcoded JSON strings.
- There is commented reference/decompile-style code kept in the file.
- This should be mapped before being rewritten.

Future target:

- Move host/port to config/env.
- Replace hardcoded response strings with small response helpers.
- Keep response shapes compatible with the client.
- Move old reference snippets into docs if they are still useful.

## REST Server

`server/rest.js` currently exposes local compatibility endpoints.

Observed points:

- Express static content is served from `static`.
- Server port is hardcoded.
- `/getServer` and `/getServerEx` return local socket targets.
- `/connect/token` returns a static local test-style token response.
- This should be cleaned before any public or VPS deployment.

Future target:

- Move ports and hostnames to env/config.
- Replace static token responses with a local dev auth shim or real auth bridge.
- Keep old endpoint names until the client dependency chain is mapped.

## Server Dependencies

`server/package.json` has dependencies but no project name, scripts, engines, or lockfile strategy documented yet.

Observed points:

- `request` is present and should eventually be replaced.
- Discord-related packages are present and may be unused.
- Profanity packages are present and should be mapped before removal.
- No clear `start` script exists yet.

Future target:

```json
{
  "scripts": {
    "start": "node server.js",
    "start:rest": "node rest.js"
  }
}
```

Only add scripts once the correct entry points are confirmed.

## Electron Client

`electron/package.json` still uses old placeholder identity from a different project.

Observed points:

- Package name does not match this project.
- Description does not match this project.
- Author field is legacy/placeholder data.
- Electron version is old.

Future target:

- Rename package identity to this rewrite.
- Keep the launcher working before upgrading Electron.
- Document the existing launch flow first.

## Priority Cleanup List

Safe next tasks:

1. Map current run commands.
2. Map all server entry points.
3. Create `docs/SETUP_LOCAL.md` from the current working setup.
4. Start a database table inventory.
5. Prepare database split plan.
6. Add config notes before touching code.

Do not do yet:

- Do not mass-delete SQL rows.
- Do not move `game-full`.
- Do not rename Flash endpoints.
- Do not upgrade Electron blindly.
- Do not remove dependencies until usage is mapped.

## Working Rule

```txt
Document first. Change second. Test after every small pass.
```