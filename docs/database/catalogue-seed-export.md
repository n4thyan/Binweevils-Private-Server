# Catalogue Seed Export

This document explains the first reviewed default seed export.

## Goal

Generate a small default catalogue/reference seed file from the reviewed allowlist only:

```text
database/seeds/001_catalogue_reference.sql
```

## Source manifest

The regenerated seed manifest found safe catalogue/reference INSERT groups for:

```text
itemtype
itemtypets
appareltypes
gardenitemtype
seeds
puzzletypes
crosswords
questtasks
```

It also detected blocked player/runtime INSERT groups that must not be exported:

```text
buddyalerts
buddylist
nest
nestinfo
users
weevilitems
```

`tycoonbusinesses` was detected too, but remains non-default until reviewed separately.

## Manual helper workflow

The helper workflow is:

```text
.github/workflows/catalogue-seed-commit.yml
```

Suggested inputs after merge:

```text
target_branch: database/catalogue-reference-seed
commit_message: database: add catalogue reference seed [skip ci]
```

The workflow runs:

```bash
python tools/extract_seed_tables.py \
  --input bwps.sql \
  --output database/seeds/001_catalogue_reference.sql \
  --manifest database/seeds/seed_manifest.md \
  --table itemtype,itemtypets,appareltypes,gardenitemtype,seeds,puzzletypes,crosswords,questtasks
```

## Safety check

The workflow refuses the generated SQL if it contains obvious blocked-table inserts for:

```text
users
buddyalerts
buddylist
nest
nestinfo
weevilitems
weevilhats
gardeninventory
game-logs
game-rewards
redeemedcodes
```

## Out of scope

This first seed export does not include:

- old users,
- old passwords,
- old session/login keys,
- old IP address fields,
- buddy lists,
- nest state,
- player inventory,
- player progress,
- moderation/admin logs,
- old staff/mod/celebrity identity rows,
- `tycoonbusinesses`.

## Next review

After the generated seed file is committed, review it before treating it as a default import file.
