# Password Compatibility Plan

This plan records the safe route for moving the legacy account flow away from plain text password storage while keeping the old runtime working during migration.

## Current state

The legacy PHP login flow currently compares the submitted password directly against the value in `users.password`.

The registration flow currently stores the submitted password directly in `users.password`.

The clean database path does not currently seed any users, which is good. It means fresh local users can be created correctly once the compatibility helper is implemented.

## Goal

Support two account formats during migration:

```text
legacy local rows: users.password contains the old direct value
new local rows: users.password contains a modern password_hash() value
```

The runtime should prefer modern hashed values for all newly created accounts.

## Required helper behaviour

A future PHP helper should provide these behaviours:

```text
hash a new password before storing it
verify a submitted password against a stored hash
fall back to direct comparison only for old local legacy rows
optionally rehash old compatible rows after a successful login
```

## Files that need runtime changes later

```text
game-full/essential/backbone.php
game-full/essential/internal.php
game-full/login/login.php
game-full/register/create-new-weevil.php
tools/create_local_account.py
```

## Login change later

The login script should stop doing direct password comparison inline.

Instead, it should fetch the user by username, then pass the submitted password and stored password value to the compatibility helper.

## Registration change later

Registration should hash the submitted password before inserting a new account row.

## Admin login change later

Admin/mod-panel login helpers should use the same compatibility helper, otherwise hashed local admin accounts will not be able to use admin paths.

## Local account tool rule

`tools/create_local_account.py --execute` should stay disabled until the runtime can verify hashed local passwords.

When it is enabled, it should only create obvious local accounts such as:

```text
local_admin
local_demo
```

It must not copy old users from the legacy dump.

## Safety boundary

This plan does not change runtime auth.

It does not add any account rows, passwords, session keys, login keys, buddy data, nest data, or player inventory.
