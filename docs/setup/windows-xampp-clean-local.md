# Windows/XAMPP Clean Local Setup Guide

This guide is for setting up the project locally on Windows before running the first clean-account boot trace.

It assumes the repo is at:

```text
C:\Users\pc\Desktop\Binweevils-main
```

Adjust paths if your checkout is somewhere else.

## Goal

Get from a fresh local machine setup to this state:

```text
Apache/PHP can serve the project locally
MySQL has a clean bwps_clean database
clean schema imports without old player data
local_demo account exists
local_demo has only users + buddylist rows
runtime can be tested without importing old staff/demo/celebrity accounts
```

This guide does not use the VPS.

## 1. Update the local repo

Open PowerShell:

```powershell
cd C:\Users\pc\Desktop\Binweevils-main
git checkout main
git pull origin main
git status
```

Expected:

```text
On branch main
nothing to commit, working tree clean
```

## 2. Install/check required software

You need:

```text
XAMPP with Apache, PHP, MySQL/MariaDB, phpMyAdmin
Git
Python 3
Node.js/npm
A browser with developer tools
```

Quick checks from PowerShell:

```powershell
git --version
python --version
node --version
npm --version
```

For MySQL, XAMPP usually provides the CLI here:

```text
C:\xampp\mysql\bin\mysql.exe
```

## 3. Start XAMPP

Open the XAMPP Control Panel.

Start:

```text
Apache
MySQL
```

Then open:

```text
http://localhost/phpmyadmin
```

If phpMyAdmin loads, MySQL and Apache are alive.

## 4. Put the project somewhere Apache can serve it

Simplest test setup:

```text
C:\xampp\htdocs\Binweevils-main
```

If your real repo is on the Desktop, you can either copy it into `htdocs` for testing, or configure Apache later.

For the first local test, copying is fine.

Example PowerShell copy:

```powershell
Copy-Item C:\Users\pc\Desktop\Binweevils-main C:\xampp\htdocs\Binweevils-main -Recurse -Force
```

Then the local URL shape is likely:

```text
http://localhost/Binweevils-main/game-full/
```

Do not worry if the exact URL changes later. The first goal is just to make PHP files load.

## 5. Create a clean database

Open phpMyAdmin and create:

```text
bwps_clean
```

Recommended collation:

```text
utf8mb4_general_ci
```

You can also use MySQL CLI:

```powershell
C:\xampp\mysql\bin\mysql.exe -u root -e "CREATE DATABASE IF NOT EXISTS bwps_clean CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
```

## 6. Build the MySQL 8-compatible import copy

From the repo folder:

```powershell
cd C:\Users\pc\Desktop\Binweevils-main
python tools/build_mysql8_schema_copy.py --source database/schema/001_base_schema.sql --target tmp/001_base_schema.mysql8.sql
```

This does not edit the checked-in schema. It only creates a temporary import copy for local testing.

## 7. Import clean schema and keys

Use the XAMPP MySQL CLI:

```powershell
C:\xampp\mysql\bin\mysql.exe -u root bwps_clean < tmp\001_base_schema.mysql8.sql
C:\xampp\mysql\bin\mysql.exe -u root bwps_clean < database\schema\002_keys_auto_increment.sql
```

If your MySQL root user has a password, add `-p` and enter it when asked.

Do not import `bwps.sql` for this clean-path test.

## 8. Create the clean local account

Set a local-only password value in PowerShell:

```powershell
$env:LOCAL_BW_PASSWORD="local-test-password"
```

Then run:

```powershell
python tools/create_local_account.py --database-url mysql://root:@127.0.0.1:3306/bwps_clean --username local_demo --password-from-env LOCAL_BW_PASSWORD --execute
```

If your MySQL root user has a password, use this shape instead:

```powershell
python tools/create_local_account.py --database-url mysql://root:YOURPASSWORD@127.0.0.1:3306/bwps_clean --username local_demo --password-from-env LOCAL_BW_PASSWORD --execute
```

## 9. Confirm the account exists

In phpMyAdmin SQL tab or MySQL CLI, run:

```sql
SELECT username, active, sessionKey, loginKey FROM users WHERE username = 'local_demo';
SELECT ownerName, namesList, blockList, requestList FROM buddylist WHERE ownerName = 'local_demo';
```

Expected:

```text
one users row
one buddylist row
active = 1
empty buddy/block/request lists are okay
```

Also confirm these are still empty for the clean account:

```sql
SELECT COUNT(*) FROM nest WHERE ownerName = 'local_demo';
SELECT COUNT(*) FROM weevilitems;
SELECT COUNT(*) FROM weevilhats;
```

Expected for now:

```text
0 or no user-owned rows
```

Do not add starter rows yet.

## 10. Point PHP at the clean database

The PHP config supports environment overrides, but XAMPP/Apache may not automatically read your PowerShell environment.

For first testing, use the current default PHP config only if it points at the database you are testing.

Check:

```text
game-full/essential/config.php
```

Expected local database values for this clean path:

```text
DB_HOST=localhost or 127.0.0.1
DB_NAME=bwps_clean
DB_USER=root
DB_PASSWORD=blank unless your XAMPP MySQL has one
```

If the PHP runtime still points at `bwps`, the clean test will not be using `bwps_clean`.

Do not commit local password edits.

## 11. Install Node dependencies

From PowerShell:

```powershell
cd C:\Users\pc\Desktop\Binweevils-main\server
npm install
```

Known server files include:

```text
server/Main.js
server/rest.js
server/server.js
```

The exact startup order still needs local verification. For the first boot trace, start with the documented/runtime-known services only and keep the terminal output visible.

Likely commands to test separately:

```powershell
node Main.js
```

and, in another terminal if needed:

```powershell
node rest.js
```

Do not close the terminals. Their logs are part of the trace.

## 12. First page checks

Try simple PHP loading first:

```text
http://localhost/Binweevils-main/game-full/
```

Then try the login path if available from your local route.

Do not jump straight to the SWF/game if PHP itself is erroring.

## 13. When ready, run the first-boot trace

Use:

```text
docs/runtime/local-first-boot-checklist.md
docs/runtime/first-boot-trace-runbook.md
```

Before loading the game page, open browser devtools and enable Preserve log in Network.

Capture:

```text
first red console error
first failed network request
first PHP error log line
first Node/socket error
```

## 14. What to send back

Use this template:

```text
Local URL used:
Apache status:
MySQL database name:
Node command used:
Login result:
First console error:
First failed network request:
HTTP status:
Response preview:
PHP error log:
Node/socket log:
Tables checked:
```

## Do not do yet

```text
do not use the VPS
do not import bwps.sql into bwps_clean
do not add nest/inventory/progress rows manually
do not copy old staff/demo/celebrity users
do not fix five things at once
do not normalise tables during setup
```

## Success for this setup phase

Success does not mean the whole game works yet.

Success means:

```text
clean database imports
local_demo exists
PHP can talk to bwps_clean
server terminals can be started or their first errors are known
we have the first real boot blocker captured
```
