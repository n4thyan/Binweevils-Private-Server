# Social Links Backfill Runbook

This runbook explains how to copy legacy `buddylist` data into the clean `user_social_links` table.

The old `buddylist` table remains the source of truth for now. This backfill does not change old SWF/PHP output.

## Files involved

```text
migrations/2026_05_18_add_user_social_links.sql
tools/database/backfill-social-links.php
game-full/essential/social_adapter.php
```

## What the backfill does

It reads:

```text
buddylist.ownerName
buddylist.namesList
buddylist.blockList
buddylist.requestList
```

Then writes clean relationship-shaped rows into:

```text
user_social_links
```

Mapping:

```text
namesList   -> relation_type=buddy,   status=accepted
blockList   -> relation_type=blocked, status=blocked
requestList -> relation_type=request, status=pending
```

If the target username exists in `users`, the row gets a `target_user_id`.

If the target username does not exist, the row keeps:

```text
target_user_id = NULL
target_legacy_username = old name from packed list
```

This preserves messy old data without pretending every old name is valid.

## Safe dry-run

Default mode is dry-run.

From the repo root:

```powershell
php tools/database/backfill-social-links.php
```

This prints how many rows would be inserted but does not write anything.

## Limited dry-run

```powershell
php tools/database/backfill-social-links.php --limit=10
```

## Write mode

Only run this after the dry-run output looks sane:

```powershell
php tools/database/backfill-social-links.php --write
```

The script is designed to be safe to run more than once. Existing rows are skipped.

## What this does not do

- It does not delete `buddylist`.
- It does not rewrite `namesList`, `blockList`, or `requestList`.
- It does not change buddy add/remove/request code.
- It does not change old Flash-facing response shapes.
- It does not make the clean table the source of truth yet.
- It does not add foreign keys.

## Next step after backfill

After local/dev backfill is proven, the next safe step is dual-writing one low-risk relationship action to both old `buddylist` and new `user_social_links`.
