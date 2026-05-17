# Binweevils Private Server Rewrite

A vibe-coded, modernised rewrite and preservation-focused rebuild of the KnowYourKnot Binweevils private server project.

This repo is being cleaned up so the old working Bin Weevils private server setup is easier to understand, safer to run locally, and easier to modernise over time. The current game files are being treated as a compatibility layer while the rewrite work happens around them in controlled passes.

This is not the original Bin Weevils Private Server, and it is not claiming ownership of the original work.

## Current Status

The repository now contains a preserved working legacy base plus a growing clean rewrite support layer around it.

Phases 1 to 4 are merged. The project is currently in Phase 5: runtime bootstrap and database modernisation audit.

Current Phase 5 work has focused on making the clean database path usable without carrying old player/staff/demo data forward. The repo now includes:

- Runtime/database debt notes
- Runtime boot dependency mapping
- Runtime table usage scanning
- PHP syntax checks
- Auth readiness checks
- PHP auth compatibility helpers for login/register
- A guarded local account bootstrap tool
- A disposable MySQL account smoke test in GitHub Actions
- A MySQL 8 schema import-copy builder for smoke tests
- Local auth verification and login endpoint review notes

The clean local account path can now create a fresh `local_demo` account in a disposable MySQL database and confirm the minimum `users` and `buddylist` rows exist. It deliberately does not create nest, inventory, hats, old users, old moderator names, old celebrity accounts, or imported production/player state.

The project is still not production-ready. The game runtime, database relationships, old packed-list tables, starter player state, and endpoint behaviour still need careful compatibility work.

## Original Project and Credits

This rewrite is based on the public KnowYourKnot Binweevils repository:

https://github.com/KnowYourKnot/Binweevils

Credit for the original Bin Weevils Private Server / Bin Weevils Rewritten work belongs to Smiley / Darkk, HDWEEVIL, and the public KnowYourKnot reference repo.

See [CREDITS.md](CREDITS.md) for the full credit notice.

## What This Rewrite Is

This project is a modernised rewrite of an older private server setup.

The goals are:

- Preserve the working game experience
- Clean up the public project identity
- Document how the current files fit together
- Make local setup easier to follow
- Remove hardcoded secrets and unsafe defaults over time
- Split database schema from old runtime/player data
- Replace old private-server staff/player seed data with clean demo/local data
- Add guarded local bootstrap tools
- Build smoke tests before changing fragile runtime behaviour
- Modernise the launcher and developer flow
- Rewrite backend pieces gradually without breaking Flash compatibility

## What This Rewrite Is Not

This project is not:

- The original Bin Weevils Private Server
- The official Bin Weevils Rewritten project
- Affiliated with Bin Weevils, 55 Pixels, Nickelodeon, or any original rights holders
- A claim of ownership over the original game, assets, branding, or private server work
- A finished public service ready for production hosting

## Repo Layout

The current layout is being kept mostly intact for compatibility.

```txt
electron/      Legacy desktop launcher/client wrapper
game-full/     Preserved Flash/site compatibility layer
server/        Node/socket/private server layer
database/      Clean schema split, key layer, and future seed/reset structure
tools/         Audit, compatibility, and local bootstrap helper scripts
.github/       CI checks and disposable database smoke tests
bwps.sql       Original imported database dump kept for reference
.env.example   Environment/config template
docs/          Rewrite planning and technical notes
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for more detail.

## Safe Modernisation Rule

```txt
Preserve first. Modernise second. Rewrite only when the old behaviour is understood.
```

This matters because the Flash client may depend on exact folder names, endpoint names, filenames, XML paths, and old CDN-style URLs.

## Documentation

Core rewrite docs:

- [Credits](CREDITS.md)
- [Disclaimer](DISCLAIMER.md)
- [Architecture notes](docs/ARCHITECTURE.md)
- [Roadmap](docs/ROADMAP.md)
- [Initial audit notes](docs/AUDIT_NOTES.md)
- [Local setup notes](docs/SETUP_LOCAL.md)
- [Current run flow map](docs/RUN_FLOW.md)
- [Endpoint inventory](docs/ENDPOINTS.md)
- [Database inventory](docs/DATABASE_INVENTORY.md)
- [Auth and account flow notes](docs/AUTH_FLOW.md)
- [Security notes](docs/SECURITY_NOTES.md)
- [Runtime data cleanup plan](docs/DATA_CLEANUP.md)
- [Foundation PR merge checklist](docs/MERGE_CHECKLIST.md)
- [Post-merge plan](docs/POST_MERGE_PLAN.md)

Current Phase 5 docs:

- [Phase 5 plan](docs/phase-5-plan.md)
- [Runtime boot dependency map](docs/runtime/runtime-boot-dependency-map.md)
- [Runtime table usage audit](docs/runtime/runtime-table-usage-audit.md)
- [PHP runtime syntax check](docs/runtime/php-runtime-syntax-check.md)
- [Auth readiness check](docs/runtime/auth-readiness-check.md)
- [Runtime data modernisation notes](docs/database/runtime-data-modernisation-notes.md)
- [Runtime schema debt report](docs/database/runtime-schema-debt-report.md)
- [Users password column notes](docs/database/users-column.md)
- [Local account bootstrap notes](docs/database/local-account-bootstrap.md)
- [Local account database smoke test](docs/database/local-account-db-smoke-test.md)
- [MySQL 8 schema copy tool](docs/database/mysql8-schema-copy-tool.md)
- [Verification database smoke test plan](docs/database/verification-db-smoke-test.md)
- [Local auth verification runbook](docs/runtime/local-auth-verification-runbook.md)
- [Clean login endpoint review](docs/runtime/login-endpoint-review.md)

## Setup

Full setup instructions are still being written.

For now, treat this repo as a working imported base plus rewrite scaffolding. Local setup may require a web server, PHP, MySQL/MariaDB, Node.js, the imported database dump or clean schema path, and the existing legacy file paths.

See [docs/SETUP_LOCAL.md](docs/SETUP_LOCAL.md) for the current local setup notes.

Future setup docs will be split into:

- Windows/XAMPP setup
- Linux/VPS setup
- Clean database import/reset notes
- Local development flow
- Launcher/browser/Ruffle notes

## Rewrite Roadmap

See [docs/ROADMAP.md](docs/ROADMAP.md).

Current progress:

- Phase 1 Foundation: merged
- Phase 2 Audit: merged
- Phase 3 Config cleanup: merged
- Phase 4 Database cleanup/split: merged
- Phase 5 Runtime bootstrap and database modernisation audit: in progress

Current Phase 5 focus:

- Keep the old runtime compatible
- Make fresh local accounts possible on a clean database path
- Add CI smoke tests before changing endpoint behaviour
- Map database debt before normalising tables
- Add starter rows only when runtime evidence proves they are needed

Future passes:

- Login decision/update helper
- Clean login endpoint smoke tests
- First-boot missing-row mapper
- Minimal starter fixtures for clean local accounts
- Server/runtime module rewrite
- Ruffle/browser launch option
- Admin and moderation tooling
- Safer local setup scripts

## Disclaimer

This is an unofficial fan preservation and rewrite project.

Bin Weevils and related names, logos, characters, assets, and branding belong to their original owners. This repo is intended for local testing, education, documentation, and preservation.

No affiliation with the original rights holders is implied.

## Credit Notice

If you fork, modify, or build from this repo, keep credit to the original KnowYourKnot repository, Smiley / Darkk, and HDWEEVIL.

Credits stay in the docs. Old runtime player/staff/demo account data can be cleaned from configs, SQL, and seed files as part of the rewrite.
