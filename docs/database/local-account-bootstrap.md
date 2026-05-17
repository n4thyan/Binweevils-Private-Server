# Local Account Bootstrap

Phase 5 adds a guarded local-only account bootstrap path for clean database testing.

This is for disposable/local databases only.

It must not be used to import old users, old moderator accounts, old celebrity accounts, live data, or production rows.

## Tool

```text
tools/create_local_account.py
```

## What it creates

The tool creates the minimum rows currently needed for login/bootstrap review:

```text
users
buddylist
```

It deliberately does not create:

```text
nest
nestinfo
weevilitems
weevilhats
gardeninventory
progress rows
achievement rows
game stats
pets
old user rows
old staff/mod/celebrity rows
```

Those should only be added later if a runtime endpoint proves they are required.

## Username rules

During Phase 5, usernames must start with:

```text
local_
```

Good examples:

```text
local_admin
local_demo
```

## Password handling

The password must come from an environment variable.

The tool uses the local PHP CLI to generate a modern `password_hash()` value so it matches the PHP runtime helper path.

## Plan-only mode

```bash
LOCAL_BW_PASSWORD="change-this-local-password" \
python tools/create_local_account.py \
  --database-url mysql://root:password@127.0.0.1/bwps_clean \
  --username local_demo \
  --password-from-env LOCAL_BW_PASSWORD
```

This validates inputs only. It does not write SQL or touch the database.

## SQL review mode

```bash
LOCAL_BW_PASSWORD="change-this-local-password" \
python tools/create_local_account.py \
  --database-url mysql://root:password@127.0.0.1/bwps_clean \
  --username local_demo \
  --password-from-env LOCAL_BW_PASSWORD \
  --output-sql /tmp/local_demo.sql
```

Review the SQL before applying it.

## Execute mode

Execute mode requires both:

```text
php
mysql
```

on PATH.

```bash
LOCAL_BW_PASSWORD="change-this-local-password" \
python tools/create_local_account.py \
  --database-url mysql://root:password@127.0.0.1/bwps_clean \
  --username local_demo \
  --password-from-env LOCAL_BW_PASSWORD \
  --execute
```

## Local admin example

```bash
LOCAL_BW_PASSWORD="change-this-local-password" \
python tools/create_local_account.py \
  --database-url mysql://root:password@127.0.0.1/bwps_clean \
  --username local_admin \
  --password-from-env LOCAL_BW_PASSWORD \
  --moderator \
  --execute
```

## Safety boundaries

The generated SQL:

```text
uses a transaction
skips creation if the user already exists
creates an empty buddylist row if one does not exist
uses local-bootstrap marker values for regIP/loginIP
leaves nest/inventory/progress/player state empty
```

The tool refuses:

```text
non-local usernames
short local passwords
missing password environment variable
unsupported database URL schemes
execute mode without php/mysql on PATH
```

## Next runtime check

After creating `local_demo`, test:

```text
registration path still creates hashed users
login path accepts helper-created users
first game boot does not require nest/inventory starter rows
```

If the first boot fails due to missing starter data, add only the exact missing row type in a later PR.
