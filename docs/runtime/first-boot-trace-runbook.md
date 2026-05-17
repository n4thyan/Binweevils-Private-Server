# First-Boot Trace Runbook

This Phase 5 runbook explains how to capture the first real runtime errors after a clean local account reaches the game page.

The goal is to add starter rows only when the runtime proves they are required.

## Why this runbook exists

The clean first-boot review found that `game-full/game.php` mainly checks session cookies and embeds the Flash runtime.

It does not directly prove the game needs nest, inventory, hats, progress, achievement, garden, or other player-state rows.

Those dependencies are likely triggered after the SWF starts making PHP endpoint calls and socket messages.

## Test account boundary

Use a disposable local account created through the clean bootstrap path.

Recommended account:

```text
local_demo
```

Expected clean starting rows:

```text
users
buddylist
```

Do not pre-seed extra rows before the first trace.

## What to capture

Capture evidence from four places:

```text
browser console
browser network tab
PHP/web server error log
Node/socket server console
```

The important details are:

```text
first failing URL or socket event
HTTP status code
response body or PHP warning/error
missing table or column name
missing username/owner key
empty payload that causes the client to hang
socket message name and payload if visible
```

## Browser trace steps

1. Open developer tools before loading the game page.
2. Enable Preserve log in the Network tab.
3. Clear the current log.
4. Log in with the clean local account or set matching local session cookies.
5. Load `game-full/game.php` through the local web server.
6. Wait until the game either loads, hangs, redirects, or errors.
7. Save or screenshot the first failed request and first console error.

Useful filters:

```text
.php
.xml
.swf
socket
ws
api
```

## PHP/server trace steps

Check the local web server/PHP logs for warnings or fatal errors.

Look especially for:

```text
Undefined index
Trying to access array offset on value of type null
mysqli SQL errors
missing table errors
missing column errors
empty query result assumptions
headers already sent
```

## Node/socket trace steps

Start the Node/socket server in a visible terminal where console output can be copied.

Capture:

```text
connection opened
first client message
first server response
first error stack trace
any database query failure
any missing player state assumption
```

## Evidence format

When reporting a missing runtime row, record it like this:

```text
Symptom:
Source:
Endpoint/event:
Account:
Table:
Column/key:
Observed error:
Expected old-runtime behaviour:
Minimal proposed local fixture:
```

Example shape:

```text
Symptom: SWF hangs after loading playercard
Source: PHP error log
Endpoint/event: /path/example.php
Account: local_demo
Table: example_table
Column/key: ownerName
Observed error: row lookup returned null, then code expected field X
Expected old-runtime behaviour: account has one default row
Minimal proposed local fixture: one row keyed by ownerName=local_demo with required default fields only
```

## Starter fixture rules

A starter fixture is allowed only if it is:

```text
required by a traced endpoint or socket event
local-only
minimal
non-production
not copied from old staff/demo/player data
not imported from old celebrity/mod rows
```

A starter fixture should not include:

```text
old usernames
old moderator names
old celebrity accounts
old inventory collections
old nest designs
old progress/reward history
old game logs
```

## Recommended order

Trace and fix in this order:

```text
1. Session bridge reaches game.php
2. SWF/static assets load
3. First PHP endpoint called by the SWF
4. First socket connection/message
5. First profile/player state request
6. First room/nest/inventory request
7. Buddy/social UI requests
```

Do not skip ahead to inventory/nest fixtures until the trace reaches those surfaces.

## What not to do

```text
do not import bwps.sql as the answer
do not add every table as a starter row
do not normalise tables during first-boot tracing
do not rewrite endpoints while tracing missing rows
do not hide errors with broad empty defaults
```

## Output of this phase

Each confirmed missing dependency should become either:

```text
a small docs note if no code change is needed
a tiny local fixture generator change if a row is genuinely required
a compatibility adapter if the old table shape is too messy to write directly
```

## Current hypothesis

The current clean minimum remains:

```text
users
buddylist
```

This hypothesis should remain unchanged until real first-boot evidence proves the next required row.
