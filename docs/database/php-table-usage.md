# PHP Table Usage Audit

This document records the Phase 4 PHP/database usage pass before any SQL split is attempted.

It is intentionally conservative. The legacy PHP should keep working while the database is mapped, then the SQL dump can be split later into schema and clean seed files.

No SQL is changed by this audit.

## Scope

Reviewed source area:

- `game-full/essential/internal.php`, which contains most legacy PHP database helpers.
- Existing Phase 4 table map in `docs/database/legacy-table-map.md`.
- Existing root dump `bwps.sql` table names and seed/data patterns.

This is a compatibility audit, not a security rewrite. Risky query patterns are noted so they can be fixed later without mixing behaviour changes into the database split.

## Status legend

| Status | Meaning |
| --- | --- |
| Required | PHP runtime clearly reads or writes this table. Keep schema. |
| Required seed/reference | PHP runtime expects catalogue rows. Keep schema and review safe seed rows. |
| Player state | Runtime writes user-specific data. Keep schema, do not import old rows by default. |
| Admin/log state | Runtime writes or reads admin/mod/development records. Keep schema, no old rows by default. |
| Optional/stale | Appears tied to old tooling, admin panels, or abandoned features. Keep schema until tested, but do not seed blindly. |
| Unknown | Present in the dump or old map, but PHP usage was not confirmed in this pass. Review before removing. |

## High-risk compatibility note: table name casing

Several PHP queries use mixed-case names such as `gardenInventory`, `trackDetails`, `puzzleTypes`, `wordSearches`, `wordSearchUserProgress`, `tasksCompletedByUsers`, and `tycoonBusinesses`.

The legacy SQL dump mostly declares lowercase table names such as `gardeninventory`. This may work on a local Windows/XAMPP style setup, but it can break on a Linux VPS depending on MySQL or MariaDB table-name case handling.

Do not rename tables casually yet. The safer later pass is either:

1. preserve the exact names the PHP queries use, or
2. normalise names only after updating every PHP query and testing the game.

## Core account and session tables

| Table | PHP usage found | Status | Split recommendation |
| --- | --- | --- | --- |
| `users` | Login, admin login, session validation, profile reads, weevil definition updates, currency/XP/food updates, moderation flags, bans. | Required player state | Schema only by default. Never seed old user rows. Create fresh local accounts/admins later. |
| `buddylist` | Buddy/friend lists, friend race leaderboard lookup. | Player state | Schema only by default. Demo fixtures only if needed. |
| `buddyalerts` | Buddy feed/alert records. | Player state | Schema only by default. Do not seed legacy alert rows. |
| `gameinvites` | Referral/invite state. | Player state | Schema only by default. |

### Notes

`users` is the biggest blocker for a clean installer because it currently mixes account identity, passwords, login/session keys, profile state, moderation state, currency, XP, avatar definition, and old local development data.

For Phase 4, keep the table name and columns. The later security phase can split or harden account handling after the game is stable.

## Inventory, nest, garden, and pets

| Table | PHP usage found | Status | Split recommendation |
| --- | --- | --- | --- |
| `weevilitems` | Player-owned nest inventory; admin item rewards; deleting/trading inventory items; checking ownership. | Player state | Schema only by default. Demo fixtures only. |
| `weevilhats` | Player-owned apparel/hat records. | Player state | Schema only by default. Demo fixtures only. |
| `gardenInventory` / `gardeninventory` | Player garden inventory; garden item deletion/trading; admin garden rewards. | Player state | Schema only by default. Confirm casing before SQL split. |
| `nest` | Player nest ownership/state, plaza earning timers, coolness/score. | Player state | Schema only by default. Optional clean demo nest fixture. |
| `nestInfo` / `nestinfo` | Nest room information/state. | Player state | Schema only by default. Optional clean demo fixture. |
| `pets` | Player pet records. | Player state | Schema only by default. |
| `petAcquiredSkills` / `petacquiredskills` | Player pet skills. | Player state | Schema only by default. |

## Shop/catalogue/reference tables

These are the tables most likely to become clean seed files. They represent game-world content rather than old player identity.

| Table | PHP usage found | Status | Split recommendation |
| --- | --- | --- | --- |
| `itemtype` | Nest item catalogue checks, rewardable items, item metadata. | Required seed/reference | Keep reviewed catalogue seed rows. |
| `itemTypeTS` / `itemtypets` | Tycoon/shop item catalogue variant. | Required seed/reference if shop path is active | Keep reviewed seed rows after testing shop paths. |
| `apparelTypes` / `appareltypes` | Hat/apparel catalogue. | Required seed/reference | Keep reviewed catalogue seed rows. |
| `gardenItemType` / `gardenitemtype` | Garden item catalogue. | Required seed/reference | Keep reviewed catalogue seed rows. Confirm casing. |
| `seeds` | Garden seed/growth/yield catalogue. | Required seed/reference if garden path is active | Keep reviewed seed rows. |
| `levels` | Level/XP progression. | Required seed/reference | Keep seed rows. |
| `specialMoves` / `specialmoves` | Special move catalogue. | Required seed/reference if move shop/profile path is active | Keep reviewed seed rows. |
| `colourpalettes` | Palette data present in dump. | Unknown/reference | Keep schema and review seed use before dropping. |

## Games and score/progress tables

| Table | PHP usage found | Status | Split recommendation |
| --- | --- | --- | --- |
| `singlePlayerGames` / `singleplayergames` | Single-player game definitions. | Required seed/reference | Keep reviewed game definition seed rows. |
| `singlePlayerGames_stats` / `singleplayergames_stats` | User single-player stats/progress. | Player state | Schema only by default. |
| `weevilGames` / `weevilgames` | Per-user game/race stats, game keys, leaderboard values. | Player state | Schema only by default. |
| `multiplayerGames` / `multiplayergames` | Per-user multiplayer game state, wins/losses/game keys. | Player state | Schema only by default. Important naming conflict noted below. |
| `leaderboardGames` / `leaderboardgames` | Leaderboard game definitions. | Required seed/reference if leaderboard path is active | Keep reviewed seed rows. |
| `trackDetails` / `trackdetails` | Racing track metadata. | Required seed/reference | Keep reviewed seed rows. Confirm casing. |
| `gamebraintraining` | Brain training table present in dump. | Unknown | Keep schema until game path is checked. |

### Naming conflict to review

The table map treats `multiplayergames` as multiplayer game definitions, but PHP usage also shows `multiplayerGames` behaving as per-player multiplayer progress with columns like `weevil`, `game`, `gamekey`, `wins`, and `losses`.

Before the SQL split, confirm whether there is one legacy table doing both jobs, a naming/casing mismatch, or stale documentation in the first-pass map.

## Admin, logs, moderation, and development

| Table | PHP usage found | Status | Split recommendation |
| --- | --- | --- | --- |
| `game-logs` | Admin action logs and ban logs. | Admin/log state | Schema only by default. Do not import old rows. |
| `development` | Admin/development task tracker functions. | Optional/stale | Keep schema for now if admin panel expects it, but do not seed by default. |

## Rewards, codes, achievements, quests, and tasks

| Table | PHP usage found | Status | Split recommendation |
| --- | --- | --- | --- |
| `game-rewards` | Per-user reward timers/state such as `tinkSeed`, `castleMulch`, `flingXp`, `flumsXp`, `flumsMulch`. | Player state | Schema only by default. |
| `rewardcodes` | Reward code definitions. | Required/optional seed after manual review | Regenerate or review codes before seeding. |
| `redeemedcodes` | Per-user redeemed code state. | Player state | Schema only by default. |
| `achievements` | Achievement definitions. | Required seed/reference | Keep reviewed seed rows. |
| `achievementtypes` | Achievement type definitions. | Required seed/reference | Keep reviewed seed rows. |
| `achievementtags` | Achievement tags. | Required seed/reference | Keep reviewed seed rows. |
| `achievementtypetags` | Achievement type-to-tag mapping. | Required seed/reference | Keep reviewed seed rows. |
| `achievementscompleted` | User completed achievements. | Player state | Schema only by default. |
| `achievementcounters` | User achievement counters. | Player state | Schema only by default. |
| `quests` | Quest definitions. | Required seed/reference if quest path is active | Keep reviewed seed rows. |
| `questtasks` | Quest task definitions. | Required seed/reference if quest path is active | Keep reviewed seed rows. |
| `questscompleted` | User quest completion state. | Player state | Schema only by default. |
| `tasksCompletedByUsers` / `taskscompletedbyusers` | User completed task state. | Player state | Schema only by default. Confirm casing. |
| `task-completed` | Task detail lookup by `taskID`. | Required seed/reference if task path is active | Keep reviewed rows. Hyphenated table name needs careful quoting. |
| `task-completed2` | Legacy/ambiguous task table. | Unknown | Keep schema until usage is confirmed. |

## Bubble hunts, newspapers, camera, and live/event systems

| Table | PHP usage found | Status | Split recommendation |
| --- | --- | --- | --- |
| `bubbleCompetitions` / `bubblecompetitions` | Bubble hunt/competition definitions and active flag. | Optional seed/reference | Keep reviewed event rows only if wanted. Confirm casing. |
| `bubbleHunts` / `bubblehunts` | User bubble hunt progress. | Player state | Schema only by default. |
| `newspapers` | Newspaper metadata/content. | Optional seed/content | Review content before seeding. |
| `newspaperissues` | Newspaper issue metadata/content. | Optional seed/content | Review content before seeding. |
| `camerapics` | User camera/magazine photo records. | Player state | Schema only by default. |

## Puzzle tables

| Table | PHP usage found | Status | Split recommendation |
| --- | --- | --- | --- |
| `puzzleTypes` / `puzzletypes` | Puzzle type definitions. | Required seed/reference | Keep seed rows. Confirm casing. |
| `crosswords` | Crossword definitions, config paths, rewards. | Required seed/reference | Keep reviewed seed rows. |
| `crosswordUserProgress` / `crossworduserprogress` | User crossword progress. | Player state | Schema only by default. Confirm casing. |
| `wordSearches` / `wordsearches` | Wordsearch definitions. | Required seed/reference | Keep reviewed seed rows. Confirm casing. |
| `wordSearchUserProgress` / `wordsearchuserprogress` | User wordsearch progress. | Player state | Schema only by default. Confirm casing. |

## Dynamic SQL patterns to fix later

Do not mix these fixes into the SQL split PR, but mark them for later code hardening:

- `getPuzzleListData($table1, $table2)` builds table names dynamically. Later rewrite should use an allowlist.
- `setRaceStatus($track, $type)` builds a column name dynamically. Later rewrite should use an allowlist.
- Some delete/trade helpers build `IN (...)` lists from arrays. Later rewrite should validate integer IDs before building SQL.
- Login/admin functions compare plaintext `password` values in `users`. A later auth phase should replace this with hashing and migration rules.
- Several tables with hyphens need backticks forever unless renamed carefully: `game-logs`, `game-rewards`, `task-completed`, `task-completed2`.

## Clean split guidance from this pass

### Schema-only by default

Use schema only, no old rows:

- `users`
- `buddylist`
- `buddyalerts`
- `weevilitems`
- `weevilhats`
- `gardenInventory` / `gardeninventory`
- `nest`
- `nestInfo` / `nestinfo`
- `pets`
- `petAcquiredSkills` / `petacquiredskills`
- `singlePlayerGames_stats` / `singleplayergames_stats`
- `weevilGames` / `weevilgames`
- `multiplayerGames` / `multiplayergames` when used as player progress
- `game-rewards`
- `game-logs`
- `tasksCompletedByUsers` / `taskscompletedbyusers`
- `questscompleted`
- `achievementscompleted`
- `achievementcounters`
- `crosswordUserProgress` / `crossworduserprogress`
- `wordSearchUserProgress` / `wordsearchuserprogress`
- `bubbleHunts` / `bubblehunts`
- `redeemedcodes`
- `gameinvites`
- `camerapics`

### Seed/reference after review

Likely safe to seed after manual content review:

- `itemtype`
- `apparelTypes` / `appareltypes`
- `gardenItemType` / `gardenitemtype`
- `seeds`
- `levels`
- `specialMoves` / `specialmoves`
- `singlePlayerGames` / `singleplayergames`
- `leaderboardGames` / `leaderboardgames`
- `trackDetails` / `trackdetails`
- `puzzleTypes` / `puzzletypes`
- `crosswords`
- `wordSearches` / `wordsearches`
- `achievements`
- `achievementtypes`
- `achievementtags`
- `achievementtypetags`
- `quests`
- `questtasks`
- `task-completed`
- `bubbleCompetitions` / `bubblecompetitions`
- `newspapers`
- `newspaperissues`

### Hold for manual review

Do not drop or seed yet:

- `development`
- `task-completed2`
- `colourpalettes`
- `gamebraintraining`
- `rewardcodes`

## Next pass

The next Phase 4 pass can start extracting `CREATE TABLE` statements into `database/schema/001_base_schema.sql`, but it should preserve table names exactly until casing has been tested on the target environment.