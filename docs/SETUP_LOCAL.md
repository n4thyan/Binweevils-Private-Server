# Local Setup Notes

These notes describe the current imported setup as observed from the repo.

They are not final polished setup instructions yet. The current priority is to document the working assumptions without changing fragile game files.

## Current Assumptions

The imported project appears to expect:

- A local web server serving the game files from `http://localhost`
- PHP support for legacy endpoints inside `game-full/`
- MySQL or MariaDB with a database named `bwps`
- The imported `bwps.sql` loaded into that database
- Node.js for the socket/REST compatibility layer
- The legacy Electron launcher loading `http://localhost`
- Pepper Flash plugin support for the legacy Electron client

## Likely Windows/XAMPP Flow

This has not been fully verified in this pass, but the current structure suggests this flow:

1. Install XAMPP or another local Apache/PHP/MySQL stack.
2. Create a MySQL/MariaDB database named `bwps`.
3. Import `bwps.sql` into that database.
4. Serve the contents of `game-full/` from the local web root so the game is available at `http://localhost`.
5. Install Node dependencies inside `server/`.
6. Start the Node compatibility services as needed.
7. Start the legacy Electron launcher from `electron/`.

## Environment config

Node now has a small local config helper at:

```txt
server/config.js
```

It loads optional `.env` values from:

```txt
.env
server/.env
```

If no `.env` file exists, the imported localhost defaults are still used.

To customise local settings:

```bash
cp .env.example .env
```

Then edit `.env` for your machine.

Do not commit `.env`.

## Database

Default local database settings are:

```txt
DB_HOST=localhost
DB_PORT=3306
DB_NAME=bwps
DB_USER=root
DB_PASSWORD=
```

These are old local development defaults. Node can now override them through `.env`, but the PHP side still has its own legacy config in `game-full/essential/config.php`.

Do not use these defaults for a public VPS or production-style deployment.

## Node Server Layer

The server folder currently has multiple entry points that need mapping.

Known files:

```txt
server/Main.js
server/server.js
server/rest.js
server/package.json
```

Install dependencies from inside `server/`:

```bash
npm install
```

Likely manual commands:

```bash
node Main.js
node rest.js
```

The older `server.js` shim is still uncertain because it imports `./xmlsocket`, which was not found during audit.

## Node config values

Current Node environment keys:

```txt
DB_HOST
DB_PORT
DB_NAME
DB_USER
DB_PASSWORD
NODE_BIND_HOST
GAME_SOCKET_PORT
WEB_SOCKET_PORT
REST_HOST
REST_PORT
REST_GET_SERVER_RESPONSE
REST_GET_SERVER_EX_RESPONSE
LEGACY_SHIM_HOST
LEGACY_SHIM_PORT
```

The defaults preserve the old local behaviour:

```txt
GAME_SOCKET_PORT=9339
WEB_SOCKET_PORT=2087
REST_PORT=1122
LEGACY_SHIM_HOST=127.0.0.1
LEGACY_SHIM_PORT=10843
```

## Electron Launcher

The Electron launcher currently loads:

```txt
http://localhost
```

Start from inside `electron/`:

```bash
npm install
npm start
```

This launcher still depends on legacy Pepper Flash support. A future pass may add a browser/Ruffle option, but the legacy launch path should be kept until the current working flow is fully documented.

## Do Not Use VPS Yet

Do not deploy this repo directly to a public VPS yet.

Before VPS deployment, the project needs:

- Secret/config cleanup
- Database sanitisation
- Runtime account data cleanup
- Auth review
- PHP endpoint review
- Node socket/REST review
- Public web server config review

## Next Setup Tasks

- Confirm exact Windows/XAMPP steps
- Confirm exact Node startup order
- Add proper `npm` scripts after entry points are verified
- Add Linux/VPS setup later
- Split database into schema and safe seed files later

## Rule

```txt
Get local working setup documented first. VPS comes later.
```