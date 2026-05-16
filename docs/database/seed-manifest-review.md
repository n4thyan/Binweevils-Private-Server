# Seed Manifest Review

This document tracks the first dry-run review of catalogue/reference seed extraction.

The goal is to inspect what `tools/extract_seed_tables.py` sees in `bwps.sql` before committing any generated seed SQL.

## Scope

This pass is review-only.

It should add or review:

```text
database/seeds/seed_manifest.md
```

It should not add generated seed SQL yet.

## Expected command

```bash
python tools/extract_seed_tables.py --input bwps.sql --manifest database/seeds/seed_manifest.md --dry-run
```

## What the manifest should prove

The manifest should show:

- which allowlisted catalogue/reference tables have `INSERT` statements,
- which known player/runtime tables were detected as blocked,
- which other tables contain `INSERT` statements,
- that the extraction helper can run without writing a seed SQL file.

## Safety boundaries

This pass must not commit rows from these categories as default seed data:

- old users,
- passwords,
- session keys,
- login keys,
- IP addresses,
- old buddy/social graph rows,
- old inventories,
- old player progress,
- moderation/admin logs,
- old staff/mod/celebrity identity rows.

## Review outcome

The dry-run manifest will decide the next pass.

If the selected catalogue/reference tables look clean enough, the next PR can generate the first reviewed seed file:

```text
database/seeds/001_catalogue_reference.sql
```

If unexpected tables or unsafe content appear, the allowlist should be tightened before any seed SQL is generated.
