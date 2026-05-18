# Database Adapter Boundary

This document defines the first safe boundary for the database rewrite track.

The goal is to let new code use cleaner database concepts while the old Flash/PHP runtime continues to receive the same legacy response shapes.

## Main rule

```text
Adapters first. Schema rewrites later.
```

Do not directly normalise old runtime tables underneath the Flash client. Add helper/adapters beside the old tables, then move reads and writes gradually.

## Canonical identity rule

New code should treat this as the internal identity model:

```text
users.id = canonical user_id
users.username = legacy/display identity
```

The old runtime can still output `username`, `ownerName`, `weevilName`, `userID`, or other legacy names where the client expects them.

New code should avoid adding new username-owned relationships unless it is preserving an old response shape.

## Legacy output rule

The old SWF/PHP contract wins until a compatibility layer replaces it.

Allowed:

```text
new helper resolves username -> user_id internally
old endpoint still returns username to the client
```

Not allowed yet:

```text
old endpoint suddenly returns user_id where the SWF expects username
old packed-list output is removed before an adapter exists
old ownerName columns are renamed in place
```

## Old table freeze rule

Do not delete, rename, or aggressively alter old runtime columns until all of these are true:

- the endpoint group using that column is mapped
- an adapter exists
- local boot still works
- the old response shape is preserved
- at least one safe migration/rollback path exists

## First adapter target

The first adapter target is user identity lookup.

Required helper behaviour:

```text
username -> user row
user_id -> user row
username -> user_id
user_id -> username
current logged-in user -> user row
```

The first helper is intentionally read-only. It does not change account creation, login, logout, or session storage.

## Future adapter groups

Recommended order:

```text
1. User identity lookup
2. Sessions/auth helpers
3. Social/buddy list parser
4. Clean social links table beside old buddylist
5. Dual-write one safe relationship type
6. Progression/economy helpers
7. Inventory ownership helpers
8. Nest state helpers
9. Achievements/bin pets later
```

## Naming rules

Use these names in new code/docs:

```text
user_id              numeric users.id reference
username             legacy/display username
owner_user_id        numeric owner reference
target_user_id       numeric target reference
legacy_owner_name    old ownerName/weevilName value when needed
```

Avoid new ambiguous names such as:

```text
idx
userID as text
weevil as owner name
belongsTo as owner name
nameList as relationship storage
```

If legacy names are required for old endpoint compatibility, keep them inside adapter output and document why.

## Testing rule

Every adapter pass should preserve this path:

```text
clean local database -> fresh local account -> PHP login/session -> game.php -> Ruffle SWF load -> socket proxy -> starting Nest / room state
```

A database cleanup is not successful if it makes the old client boot path worse.
