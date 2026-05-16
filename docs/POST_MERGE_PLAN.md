# Post-Merge Plan

This file describes the recommended work after the foundation docs PR is merged.

The first PR is meant to establish the project identity and guardrails. After it lands, future work should happen in small focused branches.

## 1. Legacy file map

Branch:

```txt
audit/legacy-file-map
```

Goal:

- Map major folders and entry points.
- Identify which files are active runtime files.
- Identify which files are assets/content only.
- Identify likely dead files without deleting them yet.

Output:

```txt
docs/LEGACY_FILE_MAP.md
```

Do not move files in this branch.

## 2. Environment/config support

Branch:

```txt
config/env-support
```

Goal:

- Add environment config loading to the Node server layer.
- Keep old local defaults as fallbacks if needed.
- Avoid breaking local setup.
- Keep `.env.example` in sync.

Likely files:

```txt
server/db.js
server/rest.js
server/server.js
.env.example
```

Keep endpoint names and response shapes stable.

## 3. Server package scripts

Branch:

```txt
server/package-scripts
```

Goal:

- Confirm actual Node entry points.
- Add useful `npm` scripts.
- Add minimal start docs.
- Avoid dependency upgrades until runtime is tested.

Likely files:

```txt
server/package.json
docs/SETUP_LOCAL.md
```

## 4. Database split planning

Branch:

```txt
database/schema-seed-split
```

Goal:

- Create `database/` folder.
- Split schema from seed data.
- Keep catalogue/game data separate from dev account data.
- Create safe demo seed data.
- Do not remove the original `bwps.sql` until the split is tested.

Target layout:

```txt
database/schema.sql
database/seeds/catalogue.sql
database/seeds/dev.sql
```

## 5. Electron launcher identity cleanup

Branch:

```txt
electron/launcher-identity
```

Goal:

- Rename package identity to this rewrite.
- Remove unrelated placeholder package metadata.
- Keep the launcher behaviour stable.
- Do not upgrade Electron until the current launch path is tested.

Likely files:

```txt
electron/package.json
docs/RUN_FLOW.md
```

## 6. Runtime data cleanup

Branch:

```txt
audit/runtime-data
```

Goal:

- Replace old runtime/test account names with clean demo data.
- Remove old account-specific starter rows from default imports.
- Keep real game catalogue/NPC data where required.
- Preserve project credits in docs.

This branch should come after database split planning.

## 7. Browser/Ruffle exploration

Branch:

```txt
launcher/ruffle-experiment
```

Goal:

- Add an optional browser/Ruffle launch page.
- Do not remove Electron.
- Document whether Ruffle works with the existing SWF/client files.

## General rule

```txt
One focused branch per cleanup area.
Do not mix docs, database cleanup, launcher rewrites, and server rewrites in one massive PR.
```