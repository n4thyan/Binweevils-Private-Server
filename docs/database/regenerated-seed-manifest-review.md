# Regenerated Seed Manifest Review

This review records the result after fixing `tools/extract_seed_tables.py` so it handles phpMyAdmin comments before `INSERT` blocks.

The regenerated manifest replaces the first seed manifest as the source of truth for the next seed export decision.

## Regenerated manifest

```text
database/seeds/seed_manifest.md
```

## Selected catalogue/reference INSERT groups found

```text
itemtype: 13
itemtypets: 1
appareltypes: 1
gardenitemtype: 1
seeds: 1
puzzletypes: 1
crosswords: 1
questtasks: 5
```

The following allowlisted catalogue/reference tables had no INSERT groups in the source dump:

```text
levels
specialmoves
singleplayergames
leaderboardgames
trackdetails
wordsearches
achievements
achievementtypes
achievementtags
achievementtypetags
quests
task-completed
```

## Blocked player/runtime INSERT groups detected

The corrected extractor now detects blocked data groups in the dump:

```text
buddyalerts: 1
buddylist: 1
nest: 1
nestinfo: 1
users: 1
weevilitems: 1
```

These are correctly treated as blocked player/runtime data and should not be exported into default seed files.

## Other non-default INSERT groups detected

```text
tycoonbusinesses: 1
```

`tycoonbusinesses` appears in the dump but is not part of the current default allowlist. Keep it out of the first default seed export until its contents and runtime usage are reviewed.

## Next seed export decision

The next PR can generate a first catalogue/reference seed file from the selected allowlist only.

Suggested output:

```text
database/seeds/001_catalogue_reference.sql
```

Suggested included tables:

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

Do not include:

```text
buddyalerts
buddylist
nest
nestinfo
users
weevilitems
tycoonbusinesses
```

## Safety note

No default seed file should contain old accounts, password fields, login/session keys, IP addresses, buddy lists, inventories, nest state, moderation logs, or old staff/mod/celebrity identity rows.
