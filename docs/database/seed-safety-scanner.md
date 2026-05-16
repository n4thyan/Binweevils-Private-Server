# Seed Safety Scanner

The seed safety scanner checks generated SQL seed files before they are merged.

## Tool

```text
tools/check_seed_safety.py
```

Default use:

```bash
python tools/check_seed_safety.py database/seeds
```

## Workflow

```text
.github/workflows/seed-safety-check.yml
```

The workflow runs on pull requests that change seed files, the scanner, or the workflow itself.

## What it blocks

The scanner refuses `INSERT` statements for known legacy runtime/player tables:

```text
users
buddyalerts
buddylist
nest
nestinfo
weevilitems
weevilhats
gardeninventory
taskscompletedbyusers
achievementcounters
game-logs
game-rewards
redeemedcodes
```

It also refuses the currently held-back optional table unless explicitly allowed:

```text
tycoonbusinesses
```

## Sensitive columns

The scanner also refuses seed INSERT statements that include obvious account/session columns:

```text
password
sessionKey
loginKey
loginIP
regIP
email
```

Column matching is case-insensitive.

## Why this exists

The clean database path should keep default seed files focused on catalogue/reference data.

Old player/runtime data should not accidentally slip back in through a generated SQL file.

## Held-back optional data

For review work only, the scanner supports:

```bash
python tools/check_seed_safety.py --allow-held-back database/seeds
```

That only allows tables listed as held-back optional data. It still refuses blocked runtime/player tables and sensitive account/session columns.

Do not use `--allow-held-back` in the default CI workflow.
