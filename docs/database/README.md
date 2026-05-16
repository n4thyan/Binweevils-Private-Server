# Database Rewrite Notes

This folder tracks the safe database modernisation work for the Binweevils Private Server rewrite.

The current project still ships the original `bwps.sql` dump at the repository root. That dump is useful because it proves which tables the legacy PHP code expects, but it mixes too many concerns in one file:

- schema definitions
- catalog/reference data
- player/user state
- demo accounts
- old local development data
- indexes and auto-increment statements

Phase 4 should not blindly rewrite the live database in one jump. The first goal is to map the dump, then split it into safer parts once the code paths have been checked.

## Current rule

`bwps.sql` stays untouched until a split can be tested.

That keeps the repo runnable while we document what belongs in schema, what belongs in seed data, and what should be regenerated or removed entirely.

## Target layout

The intended future layout is:

```text
database/
  schema/
    001_base_schema.sql
    002_indexes.sql
  seeds/
    001_catalog_items.sql
    002_games_and_rewards.sql
    003_demo_world.sql
  README.md
```

This PR only creates the documentation and folder structure. It does not change runtime behaviour.

## Split categories

### Keep as schema

Tables, columns, primary keys, indexes, and auto-increment rules.

### Keep as seed/reference data

Data that represents the game world, shops, levels, catalogue items, puzzles, rewards, and other content required for a fresh install.

### Replace with local/dev seed data

Demo users, buddy lists, inventories, nest ownership, player progress, and logs. These should become fresh local seed records rather than copied legacy account data.

### Remove from default seed

Old local IP records, demo session keys, login keys, player passwords, one-off logs, and old staff/mod/player identity records that are not required for a clean rewrite.

## Safety notes

The dump currently contains legacy sample accounts and player state. Before this becomes a proper installer, the rewrite should avoid shipping real-looking user records, plaintext passwords, session keys, login keys, old IP values, or old moderator/staff identity data.

The safest installer flow is:

1. import schema only,
2. import clean catalog/world seed data,
3. create a fresh admin account locally,
4. create demo users only when explicitly requested.
