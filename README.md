# Binweevils Private Server Rewrite

A vibe-coded, modernised rewrite and preservation-focused rebuild of the KnowYourKnot Binweevils private server project.

This repo is being cleaned up so the old working Bin Weevils private server setup is easier to understand, safer to run locally, and easier to modernise over time. The current game files are being treated as a compatibility layer while the rewrite work happens around them in controlled passes.

This is not the original Bin Weevils Private Server, and it is not claiming ownership of the original work.

## Current Status

The repository now contains a preserved working legacy base plus a growing clean rewrite support layer around it.

Phases 1 to 5 are complete for the current local boot milestone. Phase 6 has started through the Ruffle/socket-proxy proof, small compatibility feature passes, database rewrite planning, first gameplay feature-readiness testing, and pre-VPS private testing prep.

Recent progress includes:

- Clean database and runtime debt notes
- Runtime boot dependency mapping
- Runtime table usage scanning
- PHP syntax checks
- Auth readiness checks
- PHP auth compatibility helpers for login/register
- A guarded local account bootstrap tool
- A disposable MySQL account smoke test in GitHub Actions
- A MySQL 8 schema import-copy builder for smoke tests
- Local auth verification and login endpoint review notes
- Clean local account plus PHP login/session path proof
- Browser/Ruffle SWF loading proof
- Ruffle socket proxy bridge proof to the local Node game socket
- Session/logout hardening after the CoDCrafted session-key exploit report
- Banked XP level-up support up to level 80
- Prestige progression after level 80 with scaled thresholds
- Database normalisation rewrite planning with an adapter-first rule
- Read-only identity and social-list adapters
- Clean `user_social_links` migration and first friend-request dual-write helper
- Runtime feature-readiness audit after first gameplay testing
- Newer-bin map default path for the normal URL config
- Pre-VPS chat policy and command prep

The clean local account path can create fresh local test accounts in `bwps_clean` and confirm the minimum `users` and `buddylist` rows exist. It deliberately does not create old users, old moderator names, old celebrity accounts, or imported production/player state.

The core local boot target has also been proven:

```txt
clean local database -> fresh local account -> PHP login/session -> game.php -> Ruffle SWF load -> socket proxy -> starting Nest / room state
```

The current practical direction has changed for private testing: the live/testing runtime should use a sanitised legacy-compatible database rather than a tiny minimal clean database. The old database shape is still the safest compatibility contract for the Flash client, PHP endpoints, Node server, shops, games, rewards, and catalogue systems.

That does not mean bringing back unsafe old auth. Password/session security stays on the newer hardened path.

Known gameplay compatibility gaps now being tracked include:

- The Nest random teleporter currently falls back to Shopping Mall instead of choosing a valid random target
- Shop buying currently returns Error 999 for hats/furniture
- Default starter apparel can render, but the purchase/catalogue/inventory write path still needs audit
- Weevil Wheels can be played, but completion does not yet award Mulch, XP, or nest trophies
- Lab's Lab / Daily Brainstrain needs endpoint and reward-flow audit
- The current Buddy Tablet flow is unwanted long-term and should later be replaced by the OG buddy list plus Nest mailbox DM flow
- The friend request button did not emit the expected `friends/send-request` packet during first local testing, so the issue is currently client/feature wiring rather than the new clean social table itself

## Original Project and Credits

This rewrite is based on the public KnowYourKnot Binweevils repository:

https://github.com/KnowYourKnot/Binweevils

Credit for the original Bin Weevils Private Server / Bin Weevils Rewritten work belongs to Smiley / Darkk, HDWEEVIL, and the public KnowYourKnot reference repo.

Thanks to CoDCrafted for finding and flagging the session-key exploit class fixed during the Phase 5 security hardening passes.

See [CREDITS.md](CREDITS.md) for the full credit notice.

## What This Rewrite Is

This project is a modernised rewrite of an older private server setup.

The goals are:

- Preserve the working game experience
- Clean up the public project identity
- Document how the current files fit together
- Make local setup easier to follow
- Remove hardcoded secrets and unsafe defaults over time
- Keep hashed password/session hardening while restoring gameplay compatibility
- Use a sanitised legacy-compatible runtime database for private testing
- Replace old private-server staff/player seed data with clean beta/local data
- Add guarded local bootstrap tools
- Build smoke tests before changing fragile runtime behaviour
- Modernise the launcher and developer flow
- Harden known unsafe legacy behaviours
- Restore missing or rough gameplay systems gradually
- Rewrite backend pieces gradually without breaking Flash compatibility
- Normalise database debt behind compatibility adapters
- Clean and rework old database areas in smaller passes instead of one full rewrite

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
migrations/    Runtime database migrations added during the rewrite
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

This matters because the Flash client may depend on exact folder names, endpoint names, filenames, XML paths, SWF paths, and old CDN-style URLs.

## Database Compatibility Rule

```txt
The old database shape is the runtime compatibility contract for now.
Sanitise old private/player rows.
Keep useful reference/game data.
Add adapters before moving reads/writes to cleaner tables.
Do not weaken password/session security.
```

See [docs/runtime/pre-vps-testing-plan.md](docs/runtime/pre-vps-testing-plan.md) and [docs/database/database-normalisation-rewrite-plan.md](docs/database/database-normalisation-rewrite-plan.md).

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

Current runtime and database rewrite docs:

- [Phase 5 plan](docs/phase-5-plan.md)
- [Current runtime status](docs/runtime/current-runtime-status.md)
- [Runtime feature readiness audit](docs/runtime/feature-readiness-audit.md)
- [Pre-VPS testing plan](docs/runtime/pre-vps-testing-plan.md)
- [Runtime boot dependency map](docs/runtime/runtime-boot-dependency-map.md)
- [Runtime table usage audit](docs/runtime/runtime-table-usage-audit.md)
- [PHP runtime syntax check](docs/runtime/php-runtime-syntax-check.md)
- [Auth readiness check](docs/runtime/auth-readiness-check.md)
- [Runtime data modernisation notes](docs/database/runtime-data-modernisation-notes.md)
- [Runtime schema debt report](docs/database/runtime-schema-debt-report.md)
- [Database normalisation rewrite plan](docs/database/database-normalisation-rewrite-plan.md)
- [Database adapter boundary](docs/database/database-adapter-boundary.md)
- [Social list adapter plan](docs/database/social-list-adapter-plan.md)
- [Social links backfill runbook](docs/database/social-links-backfill.md)
- [Users password column notes](docs/database/users-column.md)
- [Local account bootstrap notes](docs/database/local-account-bootstrap.md)
- [Local account database smoke test](docs/database/local-account-db-smoke-test.md)
- [MySQL 8 schema copy tool](docs/database/mysql8-schema-copy-tool.md)
- [Verification database smoke test plan](docs/database/verification-db-smoke-test.md)
- [Local auth verification runbook](docs/runtime/local-auth-verification-runbook.md)
- [Clean login endpoint review](docs/runtime/login-endpoint-review.md)
- [Ruffle socket proxy runbook](docs/runtime/ruffle-socket-proxy-runbook.md)
- [Prestige system notes](docs/runtime/prestige-system.md)

## Setup

Full setup instructions are still being written.

For now, treat this repo as a working imported base plus rewrite scaffolding. Local setup may require a web server, PHP, MySQL/MariaDB, Node.js, a sanitised legacy-compatible database, and the existing legacy file paths.

See [docs/SETUP_LOCAL.md](docs/SETUP_LOCAL.md) for the current local setup notes.

Future setup docs will be split into:

- Windows/XAMPP setup
- Linux/VPS setup
- Legacy-compatible beta database setup
- Local development flow
- Launcher/browser/Ruffle notes

## Rewrite Roadmap

See [docs/ROADMAP.md](docs/ROADMAP.md).

Current progress:

- Phase 1 Foundation: merged
- Phase 2 Audit: merged
- Phase 3 Config cleanup: merged
- Phase 4 Database cleanup/split: merged
- Phase 5 Runtime bootstrap and database modernisation audit: complete for current local boot milestone
- Phase 6 Launcher, play flow, compatibility features, and private testing prep: started

Current focus:

- Keep the old runtime compatible
- Use a sanitised old database as the practical feature-testing base
- Keep clean password/session hardening
- Make chat usable for private testers
- Add simple chat commands
- Keep full database normalisation behind compatibility adapters
- Rebuild missing gameplay systems in small, isolated passes
- Keep security hardening visible in docs

Recent gameplay/runtime passes:

- Banked XP can now apply multiple levels in one pass
- Level 80 remains the normal cap for a single run
- Prestige progression can continue after level 80
- Lifetime XP is kept instead of being reset on prestige
- Prestige thresholds scale upward per prestige count
- First gameplay testing has identified shop purchase, game reward, Buddy Tablet/mailbox, and random teleporter compatibility gaps
- Normal URL path config now defaults map to the newer Bin map

Future passes:

- Sanitised legacy-compatible beta database setup
- Random Nest teleporter target fix
- Shop purchase pipeline audit
- Game reward pipeline audit for Mulch, XP, and trophies
- Daily Brainstrain / Lab's Lab reward audit
- Cleaner repeatable Ruffle/browser start flow
- Electron launcher cleanup and packaging review
- Admin and moderation dashboard polish
- Reward/beta tester code setup
- Safer local/VPS setup scripts
- Server/runtime module rewrite

## Disclaimer

This is an unofficial fan preservation and rewrite project.

Bin Weevils and related names, logos, characters, assets, and branding belong to their original owners. This repo is intended for local testing, education, documentation, and preservation.

No affiliation with the original rights holders is implied.

## Credit Notice

If you fork, modify, or build from this repo, keep credit to the original KnowYourKnot repository, Smiley / Darkk, HDWEEVIL, and credited security/testing contributors where relevant.

Credits stay in the docs. Old runtime player/staff/demo account data can be cleaned from configs, SQL, and seed files as part of the rewrite.