# Binweevils Private Server Rewrite

A modern rewrite and preservation-focused rebuild of the KnowYourKnot Binweevils private server project.

This repo is being cleaned up so the old working Bin Weevils private server setup is easier to understand, safer to run locally, and easier to modernise over time. The current game files are being treated as a compatibility layer while the rewrite work happens around them in controlled passes.

This is not the original Bin Weevils Private Server, and it is not claiming ownership of the original work.

## Current Status

This repository currently contains an imported working base. The first stage of the rewrite is focused on documentation, structure, setup notes, and safe cleanup planning.

The goal is not to break the existing game experience. Large game folders, Flash assets, PHP endpoint paths, SWF files, XML configs, and CDN-style paths should stay stable until they are properly mapped.

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
- Replace old private-server staff/player seed data with clean demo data
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
bwps.sql       Current imported database dump
.env.example   Future environment/config template
docs/          Rewrite planning and technical notes
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for more detail.

## Safe Modernisation Rule

```txt
Preserve first. Modernise second. Rewrite only when the old behaviour is understood.
```

This matters because the Flash client may depend on exact folder names, endpoint names, filenames, XML paths, and old CDN-style URLs.

## Documentation

Current rewrite docs:

- [Credits](CREDITS.md)
- [Disclaimer](DISCLAIMER.md)
- [Architecture notes](docs/ARCHITECTURE.md)
- [Roadmap](docs/ROADMAP.md)
- [Initial audit notes](docs/AUDIT_NOTES.md)
- [Local setup notes](docs/SETUP_LOCAL.md)
- [Current run flow map](docs/RUN_FLOW.md)
- [Runtime data cleanup plan](docs/DATA_CLEANUP.md)

## Setup

Full setup instructions are still being written.

For now, treat this repo as a working imported base. Local setup may require a web server, PHP, MySQL/MariaDB, Node.js, the imported database dump, and the existing legacy file paths.

See [docs/SETUP_LOCAL.md](docs/SETUP_LOCAL.md) for the current local setup notes.

Future setup docs will be split into:

- Windows/XAMPP setup
- Linux/VPS setup
- Database import notes
- Local development flow
- Launcher/browser/Ruffle notes

## Rewrite Roadmap

See [docs/ROADMAP.md](docs/ROADMAP.md).

Current first pass:

- Project identity cleanup
- Credits and disclaimer files
- Architecture notes
- Safe working rules
- Environment template
- Future data cleanup checklist
- Initial run flow and setup notes

Future passes:

- Database sanitisation
- Schema and seed split
- Hardcoded config cleanup
- Server code cleanup
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