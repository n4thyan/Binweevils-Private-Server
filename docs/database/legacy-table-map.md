# Legacy Table Map

This is a first-pass map of the legacy `bwps.sql` dump. It is intentionally conservative.

The goal is to understand what each table appears to do before splitting schema and seed data.

## Account and player state

| Table | Purpose | Split recommendation |
| --- | --- | --- |
| `users` | User account record, login/session fields, avatar definition, currency, level, XP, moderation flags, IP fields. | Schema only by default. Do not seed old rows. Create fresh local accounts later. |
| `buddylist` | Buddy, block, and request lists by owner name. | Schema only by default. Demo fixtures only. |
| `buddyalerts` | Feed-style buddy alerts. | Schema only by default. Demo fixtures only. |
| `weevilitems` | Player-owned nest/items inventory. | Schema only by default. Demo fixtures only. |
| `weevilhats` | Player-owned apparel/hat records. | Schema only by default. Demo fixtures only. |
| `weevilgames` | Per-player game stats. | Schema only by default. |
| `singleplayergames_stats` | Single-player game stats keyed by user. | Schema only by default. |
| `taskscompletedbyusers` | User task completion state. | Schema only by default. |
| `questscompleted` | User quest completion state. | Schema only by default. |
| `achievementscompleted` | User achievement completion state. | Schema only by default. |
| `achievementcounters` | User achievement counter state. | Schema only by default. |
| `crossworduserprogress` | User crossword progress. | Schema only by default. |
| `wordsearchuserprogress` | User wordsearch progress. | Schema only by default. |
| `redeemedcodes` | Reward codes redeemed by users. | Schema only by default. |
| `camerapics` | Camera/magazine photo records tied to users. | Schema only by default. |
| `gardeninventory` | Player garden inventory/state. | Schema only by default. |
| `pets` | Player pet records. | Schema only by default. |
| `petacquiredskills` | Player pet skill records. | Schema only by default. |
| `nest` | Player nest ownership/state. | Schema plus optional clean demo fixture only. |
| `nestinfo` | Nest room info/state. | Schema plus optional clean demo fixture only. |

## Game catalogue and world data

| Table | Purpose | Split recommendation |
| --- | --- | --- |
| `appareltypes` | Hat/apparel catalogue. | Seed/reference data. |
| `itemtype` | Main nest item catalogue. | Seed/reference data. |
| `itemtypets` | Tycoon/shop item catalogue variant. | Seed/reference data. |
| `gardenitemtype` | Garden item catalogue. | Seed/reference data. |
| `seeds` | Garden seed catalogue and growth/yield rules. | Seed/reference data. |
| `levels` | Level/XP progression data. | Seed/reference data. |
| `specialmoves` | Special move definitions. | Seed/reference data. |
| `singleplayergames` | Single-player game definitions. | Seed/reference data. |
| `multiplayergames` | Multiplayer game definitions. | Seed/reference data. |
| `leaderboardgames` | Leaderboard game definitions. | Seed/reference data. |
| `trackdetails` | Racing/track metadata. | Seed/reference data. |
| `tycoonbusinesses` | Tycoon/business metadata. | Seed/reference data. |
| `puzzletypes` | Puzzle type definitions. | Seed/reference data. |
| `crosswords` | Crossword definitions and config paths. | Seed/reference data. |
| `wordsearches` | Wordsearch definitions and config paths. | Seed/reference data. |
| `quests` | Quest definitions. | Seed/reference data after review. |
| `questtasks` | Quest/task step definitions. | Seed/reference data after review. |
| `tasks` / task-related legacy tables | Mission/task definitions where present. | Seed/reference data after review. |
| `rewardcodes` | Reward code definitions. | Review manually before seeding. Codes may need regenerated values. |

## Achievements and tags

| Table | Purpose | Split recommendation |
| --- | --- | --- |
| `achievements` | Achievement definitions. | Seed/reference data. |
| `achievementtypes` | Achievement category/type definitions. | Seed/reference data. |
| `achievementtags` | Achievement tag definitions. | Seed/reference data. |
| `achievementtypetags` | Type-to-tag mapping. | Seed/reference data. |

## Events, competitions, and live systems

| Table | Purpose | Split recommendation |
| --- | --- | --- |
| `bubblecompetitions` | Bubble hunt/competition definitions. | Optional seed after review. |
| `bubblehunts` | User bubble hunt progress. | Schema only by default. |
| `gameinvites` | Referral/invite state. | Schema only by default. |
| `game-rewards` | Game reward state or reward rules. | Review before seeding. |
| `newspapers` | Newspaper metadata. | Optional seed after content review. |
| `newspaperissues` | Newspaper issue metadata. | Optional seed after content review. |
| `development` | Old development tracker table. | Probably omit from clean installer unless code still depends on it. |

## Admin, logs, and moderation

| Table | Purpose | Split recommendation |
| --- | --- | --- |
| `game-logs` | Admin/game/moderation log records. | Schema only by default. No old rows. |

## Tables needing extra review

Some legacy names are awkward or ambiguous and should be checked against PHP usage before being renamed or removed:

- `game-logs`
- `game-rewards`
- `task-completed`
- `task-completed2`
- `weevilhats` column named `1`
- any table using hyphens in the table name

## Cleanup risks already spotted

- The old dump includes plaintext demo passwords in `users`.
- The old dump includes session and login keys in `users`.
- The old dump includes local IP values in `users`.
- Some old seeded user records are tied to old names and old player state.
- Some seed text references legacy private-server community identities.

Do not remove references from credits, README attribution, or licence-style notices. This table map is only about runtime seed data and old account/config records that should not be part of a clean modern install.
