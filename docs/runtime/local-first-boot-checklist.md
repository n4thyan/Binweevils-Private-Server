# Local First-Boot Checklist

This checklist is the practical companion to `docs/runtime/first-boot-trace-runbook.md`.

Use it when testing whether a clean `local_demo` account can reach the old runtime without importing old player/staff/demo data.

## Goal

Capture the first real blocker after a clean account reaches the game path.

Do not try to fix everything at once.

## Before you start

Make sure your local checkout is up to date with `main`.

```powershell
cd C:\Users\pc\Desktop\Binweevils-main
git checkout main
git pull origin main
git status
```

Expected status:

```text
On branch main
nothing to commit, working tree clean
```

## What to have open

Open these before loading the game:

```text
1. Browser devtools Console tab
2. Browser devtools Network tab with Preserve log enabled
3. PHP/web server error log or terminal
4. Node/socket server terminal
5. MySQL client/phpMyAdmin if needed for quick row checks
```

## Clean account state

The clean account should start with only:

```text
users row
buddylist row
```

Do not manually add:

```text
nest
nestinfo
weevilitems
weevilhats
gardeninventory
tasks/progress rows
old staff/demo/celebrity rows
```

## Create/check the clean local account

The existing CI path already proves this works in GitHub Actions. Locally, use the same idea: import the clean schema, import keys, then run the local account tool.

If running from PowerShell, the rough shape is:

```powershell
$env:LOCAL_BW_PASSWORD="local-test-password"
python tools/create_local_account.py --database-url mysql://root:@127.0.0.1:3306/bwps_clean --username local_demo --password-from-env LOCAL_BW_PASSWORD --execute
```

Adjust the database URL if your local MySQL password/database name is different.

## Confirm the account row

Use phpMyAdmin or MySQL to confirm:

```sql
SELECT username, sessionKey, loginKey, active FROM users WHERE username = 'local_demo';
SELECT ownerName FROM buddylist WHERE ownerName = 'local_demo';
```

Expected:

```text
one users row
one buddylist row
active = 1
```

## Try the game path

Test the normal login flow first if possible.

If the login flow redirects correctly, open:

```text
http://localhost/game-full/game.php
```

The exact local URL may differ depending on your XAMPP/Apache root.

## Capture the first failure

Stop at the first clear failure.

Copy back:

```text
Browser console first red error
Network tab first failed request
Failed request URL
HTTP status code
Response body preview
PHP error log first relevant warning/fatal
Node/socket terminal first relevant error
```

## Useful browser filters

In the Network tab, filter by:

```text
.php
.xml
.swf
ws
socket
api
```

## Useful things to screenshot

```text
first failed Network request row
request Headers tab
request Response tab
Console tab first red error
Node terminal error
PHP/XAMPP error log line
```

## Evidence template

Paste findings using this format:

```text
Symptom:
Where I saw it:
URL or socket event:
Status/error:
Response/body:
PHP log:
Node log:
Account:
Tables I checked:
What I did before it failed:
```

## Decision rule

Only one of these should happen after the trace:

```text
add a tiny local fixture if a row is genuinely required
add a compatibility adapter if a table shape is awkward
fix a config/path/cookie/session issue if no row is missing
add a doc note if the trace changes our understanding
```

## Do not do during the trace

```text
do not import old bwps.sql as the fix
do not add random rows until the error asks for them
do not manually copy old player inventory/nest data
do not change multiple systems at once
do not normalise packed tables during the boot test
```

## Good result

A good first trace does not have to fully boot the game.

A good result is simply:

```text
we know the exact first blocker
we know which file/table/endpoint/event caused it
we can make the next PR tiny and evidence-based
```
