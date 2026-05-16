# Foundation PR Merge Checklist

Use this checklist before merging the first documentation/foundation PR.

## Purpose of this PR

This PR establishes the rewrite identity and safe working rules before runtime code cleanup begins.

It is intentionally documentation-first.

## Expected changes

This PR should only include:

- README rewrite
- credits and disclaimer docs
- architecture notes
- setup notes
- run flow notes
- endpoint inventory
- database inventory
- auth/account notes
- security notes
- runtime data cleanup plan
- environment template
- `.gitignore` cleanup

## Files that should not be changed in this PR

These should remain untouched in the foundation PR:

```txt
game-full/
server/*.js
electron/*.js
electron/package.json
bwps.sql
SWF files
XML files
PHP endpoint files
image/audio/game assets
```

## Review checks

Before merge, confirm:

- [ ] The README clearly says this is a modern rewrite/preservation project.
- [ ] Credits are kept in `CREDITS.md`.
- [ ] Disclaimer is clear but not overdone.
- [ ] Runtime data cleanup is separated from credit attribution.
- [ ] No fragile client paths were moved.
- [ ] No SQL rows were deleted.
- [ ] No server runtime code was changed.
- [ ] No Electron runtime code was changed.
- [ ] `.env.example` contains placeholders only.
- [ ] `.env` remains ignored.

## After merge

After this PR is merged into `main`, create follow-up branches for real cleanup work.

Recommended next branch order:

```txt
audit/legacy-file-map
config/env-support
server/package-scripts
database/schema-seed-split
electron/launcher-identity
```

## Rule

```txt
Merge docs first. Change runtime code in smaller follow-up PRs.
```