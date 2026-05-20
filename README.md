# Bin Weevils Private Server - OG Working Stack

An unofficial Bin Weevils private-server recovery and development project.

This repo is based on the original KnowYourKnot Binweevils private-server source and keeps that original project as the ground truth. The aim is not to replace the game with a random remake, and it is not a full clean-room rewrite. The current direction is simple: keep the original working game intact, then add careful, tested improvements on top.

The current stable stack has the original Flash game running locally with Ruffle/socket proxy support, restored login flow, chat commands, XP banking, prestige, OG level thresholds, reward codes, and a few quality-of-life fixes.

## Project status

Current working branch:

```text
stable/og-working-stack
```

Latest known-good checkpoint:

```text
working-og-reward-codes
```

This branch is the safest base for local testing, VPS deployment, and future feature work.

## Credits

Original base source:

- KnowYourKnot/Binweevils
- Original private-server work credited in the upstream README to Smiley / Darkk and HDWEEVIL

This repo builds on that base and documents the recovery work, fixes, and new features added during the current rebuild.

## Scope

This project is focused on an OG-first working private server.

The rules for the current rebuild are:

- Use the KnowYourKnot source as the ground truth.
- Keep the original database structure unless a feature absolutely needs a small migration.
- Do not clean, restructure, or replace the original database just for tidiness.
- Make small feature branches.
- Test each feature in-game before merging.
- Tag stable checkpoints before moving on.
- Back up the repo, htdocs, and database after each proven feature.

The game is currently still Flash/SWF-based, with Ruffle used to run the client in a modern browser. Long-term HTML5 work can happen separately, but this repo is currently about preserving and improving the working OG stack first.

## What has been added in this rebuild

Current merged features include:

- Blank session-key auth bypass fix.
- Ruffle socket proxy support.
- Relaxed client chat input restrictions.
- Chat commands and command prefixes.
- Admin and moderator chat commands.
- Banked XP multi-level progression.
- Prestige progression system.
- Original-style 80-level XP thresholds.
- Random nest teleporter destinations.
- Working starter reward/redeem codes.
- Database seed scripts for level thresholds and starter reward codes.
- Safer recovery workflow with stable tags and backups.

## What this project is not

This is not:

- an official Bin Weevils product,
- affiliated with Bin Weevils, 55 Pixels, Nickelodeon, or any original rights holder,
- a claim of ownership over the original game or assets,
- a from-scratch modern MMO engine,
- a database cleanup experiment.

It is a preservation/private-server development project intended for local development, educational use, and archival-style experimentation.

## Local setup

### Requirements

- XAMPP with Apache and MySQL
- Node.js
- Python, for running `websockify`
- A local clone of this repository

### Basic setup

1. Clone this repository.
2. Start Apache and MySQL in XAMPP.
3. Import the original `bwps.sql` database into MySQL.
4. Copy the contents of `game-full` into:

```text
C:\xampp\htdocs
```

5. Install server dependencies:

```powershell
cd C:\Users\pc\Desktop\Binweevils-OG\server
npm i
```

6. Install Electron dependencies if you still want to use the Electron client:

```powershell
cd C:\Users\pc\Desktop\Binweevils-OG\electron
npm i
```

For modern browser/Ruffle testing, Electron is not always required.

## Running the game locally

Start the Node game server in one PowerShell window:

```powershell
cd C:\Users\pc\Desktop\Binweevils-OG\server
node Main.js
```

Start the socket proxy in another PowerShell window:

```powershell
py -m websockify 3993 127.0.0.1:9339
```

Then open:

```text
http://localhost/
```

## Database notes

The current working stack intentionally uses the original database layout.

Do not wipe, clean, rename, or restructure tables unless the change is tested and documented. A previous attempt to over-clean the database broke the login/server-select flow, so the current rule is to preserve the original structure and add only small migrations or seed files where needed.

Useful current database files:

```text
database/seeds/levels_80_og_thresholds.sql
database/seeds/rewardcodes_starter_codes.sql
database/scripts/reset_all_users_to_level_1.sql
migrations/2026_05_20_add_prestige_system.sql
```

## Current starter reward codes

The current seed adds these test/starter codes:

```text
WELCOME2026 - 30 XP and 500 mulch
OGLEVELS    - 100 XP and 1000 mulch
NESTEGG     - 2500 mulch
```

The redeem-code flow has been patched so rewards are applied before the code is marked as redeemed.

## Stable checkpoints

Current known-good tags include:

```text
working-og-sessionfix
working-og-ruffle
working-og-chat-commands
working-og-xp-banking
working-og-prestige
working-og-chat-prefixes
working-og-nest-teleporter
working-og-admin-mod-commands
working-og-xp-thresholds
working-og-reward-codes
```

Before starting new work, use:

```powershell
cd C:\Users\pc\Desktop\Binweevils-OG
git switch stable/og-working-stack
git pull origin stable/og-working-stack
git status
```

## Planned future work

Likely future work includes:

- applying the external event-system fixes,
- site customisation before VPS deployment,
- public-facing landing page polish,
- more redeem codes and reward mappings,
- shop/catalogue fixes,
- persistent moderation logs,
- moderator-only big weevil command once the scale API/client packet behaviour is confirmed,
- continued OG bug fixes.

## Disclaimer

This project is unofficial and is not affiliated with or endorsed by the original Bin Weevils team, 55 Pixels, Nickelodeon, or any related rights holder. It is maintained as a private-server preservation and development project.
