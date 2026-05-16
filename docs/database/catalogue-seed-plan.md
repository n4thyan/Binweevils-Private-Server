# Catalogue Seed Split Plan

This document starts the safe seed-split pass for Phase 4.

The goal is to split useful game-world/catalogue data out of `bwps.sql` without carrying old player accounts, session keys, passwords, IP addresses, buddy lists, or old staff/mod/celebrity identities into the clean install path.

This is a plan only. It does not edit `bwps.sql` and does not add seed SQL yet.

## Current baseline

The schema export is now present in:

```text
database/schema/001_base_schema.sql
database/schema/002_keys_auto_increment.sql
database/schema/schema_manifest.md
```

The manifest reports:

```text
CREATE TABLE blocks: 55
ALTER TABLE statements: 0
```

This means Phase 4 can now move from schema extraction to seed extraction.

## Seed split rule

Seed files should be split by purpose, not dumped into one giant file.

Proposed future structure:

```text
database/seeds/001_catalogue_items.sql
database/seeds/002_progression_and_games.sql
database/seeds/003_puzzles_quests_achievements.sql
database/seeds/004_world_content_optional.sql
database/seeds/dev/001_local_demo_accounts.sql
```

The default import should use only safe reference data. Development/demo users should stay optional.

## Safe catalogue/reference tables

These are the first candidates for default seed extraction because they describe game content rather than old players.

| Table | Proposed seed file | Notes |
| --- | --- | --- |
| `itemtype` | `001_catalogue_items.sql` | Main item catalogue. Review descriptions/prices before import. |
| `itemtypets` | `001_catalogue_items.sql` | Tycoon/shop item catalogue variant. Confirm active usage. |
| `appareltypes` | `001_catalogue_items.sql` | Hat/apparel catalogue. |
| `gardenitemtype` | `001_catalogue_items.sql` | Garden item catalogue. |
| `seeds` | `001_catalogue_items.sql` | Garden seed/yield definitions. |
| `levels` | `002_progression_and_games.sql` | Level and XP progression. |
| `specialmoves` | `002_progression_and_games.sql` | Special move definitions. |
| `singleplayergames` | `002_progression_and_games.sql` | Game definition/reference data. |
| `leaderboardgames` | `002_progression_and_games.sql` | Leaderboard game definitions. |
| `trackdetails` | `002_progression_and_games.sql` | Racing track metadata. |
| `puzzletypes` | `003_puzzles_quests_achievements.sql` | Puzzle type definitions. |
| `crosswords` | `003_puzzles_quests_achievements.sql` | Crossword definitions and reward metadata. |
| `wordsearches` | `003_puzzles_quests_achievements.sql` | Wordsearch definitions and reward metadata. |
| `achievements` | `003_puzzles_quests_achievements.sql` | Achievement definitions. |
| `achievementtypes` | `003_puzzles_quests_achievements.sql` | Achievement categories/types. |
| `achievementtags` | `003_puzzles_quests_achievements.sql` | Achievement tag definitions. |
| `achievementtypetags` | `003_puzzles_quests_achievements.sql` | Achievement type/tag mapping. |
| `quests` | `003_puzzles_quests_achievements.sql` | Quest definitions. Review text/content. |
| `questtasks` | `003_puzzles_quests_achievements.sql` | Quest task definitions. Review IDs and dependency ordering. |
| `task-completed` | `003_puzzles_quests_achievements.sql` | Legacy task definition/lookup table. Hyphenated name needs backticks. |

## Optional world/content seed tables

These may be useful, but should be reviewed before becoming part of the default seed because they may contain dated/private-server content, old events, or old editorial material.

| Table | Proposed seed file | Notes |
| --- | --- | --- |
| `bubblecompetitions` | `004_world_content_optional.sql` | Event/competition definitions. Optional by default. |
| `newspapers` | `004_world_content_optional.sql` | Content/editorial data. Review before import. |
| `newspaperissues` | `004_world_content_optional.sql` | Content/editorial data. Review before import. |
| `tycoonbusinesses` | `004_world_content_optional.sql` | Business metadata. Likely useful but review for user-owned state. |
| `colourpalettes` | `004_world_content_optional.sql` | Reference data if active. Confirm runtime usage. |
| `gamebraintraining` | `004_world_content_optional.sql` | Review feature status before import. |
| `rewardcodes` | `004_world_content_optional.sql` | Do not blindly seed old codes. Prefer regenerated local codes. |

## Never include old rows in default seed

These tables should normally be schema-only in the default installer.

They may get optional dev fixtures later, but old dump rows should not be imported by default.

| Table | Reason |
| --- | --- |
| `users` | Contains account identity, passwords, login/session keys, IP fields, moderation flags, avatar/profile state. |
| `buddylist` | Old social graph/player state. |
| `buddyalerts` | Old player feed/alert state. |
| `weevilitems` | Old player inventory. |
| `weevilhats` | Old player apparel ownership. |
| `gardeninventory` | Old player garden inventory. |
| `nest` | Old player nest ownership/state. |
| `nestinfo` | Old player nest room state. |
| `pets` | Old player pets. |
| `petacquiredskills` | Old player pet progress. |
| `singleplayergames_stats` | Old player stats. |
| `weevilgames` | Old player game stats/progress. |
| `multiplayergames` | Appears player-progress-like in PHP audit. Review before seeding. |
| `leaderboardhighscores` | Old score table. Optional reset, not default seed. |
| `game-rewards` | Old per-player reward timers/state. |
| `game-logs` | Old moderation/admin logs. |
| `taskscompletedbyusers` | Old player task progress. |
| `questscompleted` | Old player quest progress. |
| `achievementscompleted` | Old player achievement progress. |
| `achievementcounters` | Old player achievement counters. |
| `crossworduserprogress` | Old player crossword progress. |
| `wordsearchuserprogress` | Old player wordsearch progress. |
| `bubblehunts` | Old event progress. |
| `redeemedcodes` | Old reward-code redemption state. |
| `gameinvites` | Old referral/invite state. |
| `camerapics` | Old user-generated camera/photo records. |

## Hold for manual review

These tables should not be deleted or seeded until code usage is confirmed.

| Table | Concern |
| --- | --- |
| `development` | Old admin/development tracker data. |
| `task-completed2` | Ambiguous legacy task table. |
| `rewardcodes` | Could expose old codes or unwanted reward state. Prefer regenerated codes. |
| `multiplayergames` | Name suggests definitions, but PHP audit showed player-progress-like usage. |
| `leaderboardhighscores` | Could be reset or optional, but not part of default clean seed. |

## Casing warning

The PHP audit found mixed-case usage in runtime code, while the schema/export table names are lowercase.

Examples:

```text
gardenInventory vs gardeninventory
trackDetails vs trackdetails
puzzleTypes vs puzzletypes
wordSearchUserProgress vs wordsearchuserprogress
```

Do not normalise names during seed extraction. Use the exact table names from the generated schema until compatibility is tested.

## Next extraction pass

The next safe pass should add a seed extraction helper that can output only allowlisted tables.

Suggested tool:

```text
tools/extract_seed_tables.py
```

First mode should be dry-run/manifest only:

```bash
python tools/extract_seed_tables.py --input bwps.sql --plan docs/database/catalogue-seed-plan.md --dry-run
```

Then a later PR can generate reviewed seed files.

## Safety rule

Default seed files must never include:

- old `users` rows
- passwords
- session keys
- login keys
- IP addresses
- old buddy lists
- old inventories/progress
- old moderation logs
- old staff/mod/celebrity identity records
