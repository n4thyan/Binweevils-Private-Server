# Legacy-Compatible Beta Database Setup

This is the private-testing database path.

The goal is not a perfect clean rewrite yet. The goal is a database that the old Flash/PHP/Node runtime actually recognises while keeping old private/player data out.

## Why this exists

The tiny `bwps_clean` path proved login and boot, but wider gameplay expects old reference tables and old table shapes.

Missing or reduced data can break things like:

```text
shops
hats
furniture
catalogues
reward codes
game rewards
trophies
levels
Daily Brainstrain / Lab's Lab
Weevil Wheels rewards
```

For private testing, use a sanitised legacy-compatible database instead.

## Database names

Recommended local names:

```text
bwps_clean = minimal clean experiment database
bwps_beta  = practical private-test database
```

Use `bwps_beta` for friend/testing sessions.

## Safety rules

Do not import old users as playable accounts.

Do not reuse:

```text
old passwords
old session keys
old login keys
old IP fields
old user inventory/progress rows
old staff/player/demo rows
```

Do keep:

```text
shop/catalogue data
game/reference data
reward definitions
achievement definitions
level tables
world/config reference rows
```

Password and session hardening still stays active.

## Files added for this pass

```text
migrations/2026_05_18_prepare_legacy_beta_database.sql
```

This migration wipes old runtime/player/private rows while leaving useful reference rows alone.

## Simple local setup path

In phpMyAdmin:

```text
1. Create a new database called bwps_beta
2. Import the original bwps.sql into bwps_beta
3. Import migrations/2026_05_18_prepare_legacy_beta_database.sql into bwps_beta
4. Import the newer rewrite migrations into bwps_beta if they are not already present
5. Create fresh accounts with tools/create_local_account.py
6. Point .env at bwps_beta
7. Restart Node/rest/websockify/Electron
```

## PowerShell account example

From the repo root:

```powershell
cd C:\Users\pc\Desktop\Binweevils-main
$env:LOCAL_BW_PASSWORD="change-this-password"
py tools\create_local_account.py --database-url mysql://root@127.0.0.1/bwps_beta --username local_demo --password-from-env LOCAL_BW_PASSWORD --execute
```

Moderator example:

```powershell
cd C:\Users\pc\Desktop\Binweevils-main
$env:LOCAL_BW_PASSWORD="change-this-password"
py tools\create_local_account.py --database-url mysql://root@127.0.0.1/bwps_beta --username local_admin --password-from-env LOCAL_BW_PASSWORD --moderator --execute
```

Tester account examples:

```powershell
cd C:\Users\pc\Desktop\Binweevils-main
$env:LOCAL_BW_PASSWORD="change-this-password"
py tools\create_local_account.py --database-url mysql://root@127.0.0.1/bwps_beta --username beta_friend1 --password-from-env LOCAL_BW_PASSWORD --execute
py tools\create_local_account.py --database-url mysql://root@127.0.0.1/bwps_beta --username beta_friend2 --password-from-env LOCAL_BW_PASSWORD --execute
```

## Point local config at bwps_beta

From the repo root:

```powershell
@"
DB_HOST=localhost
DB_PORT=3306
DB_NAME=bwps_beta
DB_USER=root
DB_PASSWORD=
"@ | Set-Content .env -Encoding ASCII
```

Then restart:

```text
Node game server
REST shim
websockify
Electron/browser client
```

## What to test after switching

Test these first:

```text
login
Nest boot
map travel
old map
new map
chat
cmd help
shop purchase
hat purchase
furniture purchase
reward code redemption
Weevil Wheels completion reward
Daily Brainstrain / Lab's Lab reward
```

## Map status update

Local testing later showed both Old Bin and New Bin paths can work.

So the current direction is:

```text
keep both maps available
keep the selector for now if it works
only fix broken travel behaviours directly
```

The random Nest teleporter is still a separate issue because it appears to always fall back to Shopping Mall.

## If something breaks

Do not start deleting SWFs or rewriting endpoints immediately.

Check first:

```text
is the expected table present?
is the expected reference row present?
is the logged-in user missing a starter row?
did the sanitiser wipe a table that should have kept reference rows?
```

Then patch the smallest missing compatibility row or endpoint.
