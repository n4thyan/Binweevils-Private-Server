# Bin Weevils Private Server - OG Working Stack

An unofficial Bin Weevils private-server recovery and development project.

This repo is based on the original KnowYourKnot Binweevils private-server source and keeps that original project as the ground truth. The aim is not to replace the game with a random remake, and it is not a full clean-room rewrite. The current direction is simple: keep the original working game intact, then add careful, tested improvements on top.

The current stable stack has the original Flash game running locally with Ruffle/socket proxy support, restored login flow, chat commands, XP banking, prestige, OG level thresholds, reward codes, and quality-of-life fixes.

This project is unofficial and is not affiliated with Bin Weevils, 55 Pixels, Nickelodeon, or any original rights holder.

## Project status

Stable working branch:

```text
stable/og-working-stack
```

Current active feature branch:

```text
feature/weevil-editor-random-colours
```

Latest known-good stable checkpoint:

```text
working-og-reward-codes
```

Current feature work is focused on the original SWF Weevil editor, especially the colour randomiser and the backend validation needed to save those new colours properly.

## Current progress

The local OG stack is working with:

* XAMPP Apache and MySQL.
* Node game server on port `9339`.
* Python websockify bridge on port `3993`.
* Ruffle client support.
* Login and server select working locally.
* The original SWF-based game running through the local stack.

Current merged or working features include:

* Blank session-key auth bypass fix.
* Ruffle socket proxy support.
* Relaxed client chat input restrictions.
* Chat commands and command prefixes.
* Admin and moderator chat commands.
* Banked XP multi-level progression.
* Prestige progression system.
* Original-style 80-level XP thresholds.
* Random nest teleporter destinations.
* Working starter reward/redeem codes.
* Database seed scripts for level thresholds and starter reward codes.
* Safer recovery workflow with stable tags and backups.
* Patched Weevil editor SWF with a larger random colour pool.

## Weevil editor colour work

The Weevil editor SWF is located at:

```text
game-full\cdn.binw.net\externalUIs\weevilChanger.swf
```

The patched script/class is:

```text
com.binweevils.reg.PartsList
```

The current patch expands the editor’s Random button colour pool, giving much more variety than the original small colour set.

The patched SWF has been tested locally. The new colours appear correctly when clicking Random in the Weevil editor.

### Current blocker

The new colours currently render in the editor, but saving/applying them still needs backend validation work.

The likely blocker is:

```text
game-full\essential\internal.php
```

Specifically:

```php
function isDefValid($weevilDef)
```

The current validator uses indexed colour arrays. The patched SWF can now generate colour indexes outside the older expected range, so the backend may reject the new definition even though the editor displays it correctly.

The planned fix is to update colour-index validation without disabling the rest of the safety checks.

The goal is:

* Keep the existing 18-digit weevil definition format.
* Keep body, head, legs, antennae, eyes, and part validation intact.
* Expand accepted colour indexes to match the patched SWF palette.
* Avoid a blanket `return true` unless only used temporarily for testing.
* Keep malformed or broken weevil definitions blocked.

## Local setup

### Requirements

* XAMPP with Apache and MySQL
* Node.js
* Python
* Python `websockify`
* A local clone of this repository

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

6. Install Electron dependencies if using the Electron client:

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

Expected output:

```text
Server running on port 9339
```

Start the Ruffle/WebSocket bridge in another PowerShell window:

```powershell
cd C:\Users\pc\Desktop\Binweevils-OG
py -m websockify 3993 127.0.0.1:9339
```

Expected output:

```text
Listen on :3993
proxying from :3993 to 127.0.0.1:9339
```

If using Electron, start it in a third PowerShell window:

```powershell
cd C:\Users\pc\Desktop\Binweevils-OG\electron
npm.cmd start
```

Then open:

```text
http://localhost/
```

## Ruffle and socket notes

The local Ruffle/WebSocket setup uses port `3993`, not `9001`.

The SWF/Ruffle client attempts to connect to:

```text
ws://localhost:3993/
```

The websockify bridge forwards that traffic to the Node game server on:

```text
127.0.0.1:9339
```

If the game reaches server select and then kicks back out, check that both ports are listening:

```powershell
Test-NetConnection 127.0.0.1 -Port 9339
Test-NetConnection 127.0.0.1 -Port 3993
```

Both should return:

```text
TcpTestSucceeded : True
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

For the current colour editor work, use:

```powershell
cd C:\Users\pc\Desktop\Binweevils-OG
git switch feature/weevil-editor-random-colours
git pull
git status
```

## Safe workflow

Before editing SWFs, PHP, database files, or server code:

1. Make a local backup.
2. Work on a feature branch.
3. Test locally in-game.
4. Commit only the intended files.
5. Push the branch.
6. Tag stable checkpoints only after the feature is proven.

Avoid `git add .` when there are temporary backups or unrelated modified files in the tree.

## Planned future work

Likely future work includes:

* Finish the Weevil editor colour randomiser backend validation.
* Update `isDefValid()` so expanded colour indexes save safely.
* Test applied/saved random colours in-game.
* Back up and tag the completed colour patch.
* Apply the external event-system fixes.
* Continue site customisation before VPS deployment.
* Polish the public-facing landing page.
* Add more redeem codes and reward mappings.
* Fix shop/catalogue behaviour.
* Add persistent moderation logs.
* Add moderator-only big weevil command once the scale API/client packet behaviour is confirmed.
* Continue OG bug fixes.
* Package local changes for VPS deployment once local behaviour is stable.

## What this project is not

This is not:

* an official Bin Weevils product,
* affiliated with Bin Weevils, 55 Pixels, Nickelodeon, or any original rights holder,
* a claim of ownership over the original game or assets,
* a from-scratch modern MMO engine,
* a database cleanup experiment.

It is a preservation/private-server development project intended for local development, educational use, and archival-style experimentation.

## Credits

Original base source:

* **Smiley / KnowYourKnot** for the original Binweevils private-server source this repo is based on.
* Original private-server work credited in the upstream README to Smiley / Darkk and HDWEEVIL.

Additional thanks:

* **Codcrafted** for the session-key exploit find.
* **Bandit** for the Ruffle support method.

This repo builds on the original base and documents the recovery work, fixes, and new features added during the current rebuild.

## Disclaimer

This project is unofficial and is not affiliated with or endorsed by the original Bin Weevils team, 55 Pixels, Nickelodeon, or any related rights holder.

It is maintained as a private-server preservation and development project.

Do not use this project to impersonate official services, mislead users, collect real user data, or abuse security issues.
