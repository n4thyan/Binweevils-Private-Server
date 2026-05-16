# Seed Files

This folder will hold safe default data for a fresh local/private server install.

Seed files should be reviewed before import. The aim is to keep game-world content while avoiding old account and moderation data.

## Good seed candidates

These are likely to become seed files after the dump is split and tested:

- apparel types
- item catalogue data
- garden item catalogue data
- levels
- puzzle definitions
- quest/task definitions
- track/game definitions
- clean default nest/room templates

## Bad seed candidates

These should not be imported by default:

- old `users` rows
- plaintext password values
- session/login keys
- IP address fields
- old `buddylist` rows
- old player inventory/progress rows
- old moderation/admin logs
- old staff or celebrity account identity records

## Planned seed files

The current plan is documented in:

```text
docs/database/catalogue-seed-plan.md
```

Likely future files:

```text
database/seeds/001_catalogue_items.sql
database/seeds/002_progression_and_games.sql
database/seeds/003_puzzles_quests_achievements.sql
database/seeds/004_world_content_optional.sql
database/seeds/dev/001_local_demo_accounts.sql
```

## Extraction planning tool

The catalogue/reference extraction helper is:

```text
tools/extract_seed_tables.py
```

Dry-run first:

```bash
python tools/extract_seed_tables.py --input bwps.sql --manifest database/seeds/seed_manifest.md --dry-run
```

This writes a manifest without writing a seed SQL file.

The tool refuses to extract known player/runtime tables such as `users`, `buddylist`, `weevilitems`, `game-logs`, and progress tables.

## Manual manifest commit helper

The repository includes a manual helper workflow:

```text
.github/workflows/seed-manifest-commit.yml
```

Suggested inputs:

```text
target_branch: database/seed-manifest-review
commit_message: database: add seed extraction manifest [skip ci]
```

The workflow runs the seed extractor in dry-run mode, writes `database/seeds/seed_manifest.md`, and commits only that manifest back to the target branch.

It does not write seed SQL.

## Demo data rule

Demo data should be obvious and disposable.

Good examples:

- `demo_admin`
- `demo_weevil`
- `local_test_user`

Bad examples:

- old private-server usernames
- old moderator names
- old celebrity/staff names
- copied accounts from the dump

## Import order later

Once split, a clean install should run roughly like this:

1. schema files
2. catalog/world seed files
3. local setup script for admin/demo accounts
4. optional development fixtures
