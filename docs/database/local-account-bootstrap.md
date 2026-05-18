# Local/Beta Account Bootstrap

This tool creates guarded fresh accounts for local and private beta databases.

It must not be used to import old users, old moderator accounts, old celebrity accounts, live data, or production rows.

## Tool

```text
tools/create_local_account.py
```

## What it creates

The tool creates the starter rows currently needed for login/bootstrap review:

```text
users
buddylist
```

It deliberately does not import old private-server accounts, old passwords, old session keys, old inventory, old progress, or old production/player state.

For the legacy-compatible beta database, shop/game/catalogue/reference data should come from the sanitised old database import, not from old user rows.

## Username rules

Allowed prefixes:

```text
local_
beta_
```

Good examples:

```text
local_admin
local_demo
beta_friend1
beta_friend2
```

## Password handling

The password must come from an environment variable.

The tool uses the local PHP CLI to generate a modern `password_hash()` value so it matches the PHP runtime helper path.

## Plan-only mode

```bash
LOCAL_BW_PASSWORD="change-this-local-password" \
python tools/create_local_account.py \
  --database-url mysql://root:password@127.0.0.1/bwps_beta \
  --username local_demo \
  --password-from-env LOCAL_BW_PASSWORD
```

This validates inputs only. It does not write SQL or touch the database.

## SQL review mode

```bash
LOCAL_BW_PASSWORD="change-this-local-password" \
python tools/create_local_account.py \
  --database-url mysql://root:password@127.0.0.1/bwps_beta \
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
  --database-url mysql://root:password@127.0.0.1/bwps_beta \
  --username local_demo \
  --password-from-env LOCAL_BW_PASSWORD \
  --execute
```

## Local admin example

```bash
LOCAL_BW_PASSWORD="change-this-local-password" \
python tools/create_local_account.py \
  --database-url mysql://root:password@127.0.0.1/bwps_beta \
  --username local_admin \
  --password-from-env LOCAL_BW_PASSWORD \
  --moderator \
  --execute
```

## Beta tester examples

```bash
LOCAL_BW_PASSWORD="change-this-local-password" \
python tools/create_local_account.py \
  --database-url mysql://root:password@127.0.0.1/bwps_beta \
  --username beta_friend1 \
  --password-from-env LOCAL_BW_PASSWORD \
  --execute
```

```bash
LOCAL_BW_PASSWORD="change-this-local-password" \
python tools/create_local_account.py \
  --database-url mysql://root:password@127.0.0.1/bwps_beta \
  --username beta_friend2 \
  --password-from-env LOCAL_BW_PASSWORD \
  --execute
```

## Safety boundaries

The generated SQL:

```text
uses a transaction
skips creation if the user already exists
creates an empty buddylist row if one does not exist
uses guarded-bootstrap marker values for regIP/loginIP
uses fresh session/login keys
uses a modern password_hash() value
leaves old inventory/progress/player state empty
```

The tool refuses:

```text
usernames without local_ or beta_
short local passwords
missing password environment variable
unsupported database URL schemes
execute mode without php/mysql on PATH
```

## Next runtime check

After creating accounts, test:

```text
login path accepts helper-created users
first game boot works
chat works
shop/game/reward behaviour uses the legacy-compatible reference rows
```

If a feature fails because a fresh user is missing a starter row, add the smallest exact missing row type in a later PR.
