# Rewrite Roadmap

This roadmap keeps the current working experience safe while the repo is cleaned up.

## Overall Progress

Current phase: Phase 5 - Runtime Bootstrap and Database Modernisation Audit.

```text
Phase 1 Foundation: merged
Phase 2 Audit: merged
Phase 3 Config Cleanup: merged
Phase 4 Database Cleanup and Split: merged
Phase 5 Runtime Bootstrap and Database Modernisation Audit: in progress
Phase 6 Launcher and Play Flow: not started
Phase 7 Tooling: not started
Phase 8 Public Polish: not started
```

## Phase 1: Foundation

Status: merged

- [x] Rewrite public README
- [x] Add credits and disclaimer files
- [x] Add architecture notes
- [x] Add environment template
- [x] Define safe modernisation rules
- [x] Keep fragile game paths untouched
- [x] Add initial audit notes
- [x] Add local setup notes
- [x] Add current run flow notes
- [x] Add endpoint inventory
- [x] Add database inventory
- [x] Add auth/account flow notes
- [x] Add security notes
- [x] Add runtime data cleanup plan
- [x] Add merge checklist
- [x] Add post-merge plan

## Phase 2: Audit

Status: merged

- [x] Map the current launch flow at a high level
- [x] Map the main boot/login/game path
- [x] Map known Node/server entry points
- [x] Map known client-facing cookies, ports, and paths
- [x] Map important fragile `game-full` files at a high level
- [x] Create `docs/LEGACY_FILE_MAP.md`
- [x] Create `docs/SERVER_ENTRYPOINTS.md`
- [x] Create `docs/GAME_FULL_MAP.md`
- [x] Create `docs/CLIENT_CONTRACT.md`
- [x] Create `docs/GAME_ENDPOINTS_TODO.md`

Still needs deeper follow-up audit later:

- [ ] Map all PHP endpoints called by the client
- [ ] Map Node/socket events fully
- [ ] Map database tables and relationships fully
- [ ] Identify old runtime account/staff/demo data fully
- [ ] Identify files that are genuinely unused

## Phase 3: Config Cleanup

Status: merged

- [x] Add Node `.env` loader without new dependencies
- [x] Add `server/config.js`
- [x] Move Node database config behind `server/config.js`
- [x] Move main Node game/web socket ports behind config
- [x] Move older legacy shim host/port behind config
- [x] Add REST shim env placeholders and discovery config values
- [x] Update REST shim runtime code to consume config values
- [x] Remove old static REST shim auth material in favour of local placeholders
- [x] Add PHP database environment overrides with old XAMPP defaults preserved
- [x] Keep old localhost defaults when no environment values exist
- [x] Keep `.env.example` updated
- [x] Document config support
- [ ] Document Linux/VPS setup later

## Phase 4: Database Cleanup and Split

Status: merged

- [x] Split current SQL dump into schema and seed-focused files
- [x] Keep original `bwps.sql` available for reference
- [x] Create clean database folder structure
- [x] Separate base schema from key/auto-increment layer
- [x] Add clean database documentation
- [x] Remove old account/player import assumptions from the clean path
- [x] Document that old staff/mod/celebrity/demo rows should not be carried forward as default local data
- [x] Prepare the repo for guarded local-only account bootstrap work

Current clean database structure includes:

```text
database/schema/001_base_schema.sql
database/schema/002_keys_auto_increment.sql
database/seeds/
database/README.md
```

## Phase 5: Runtime Bootstrap and Database Modernisation Audit

Status: in progress

Phase 5 is focused on making the clean database path usable by the runtime without blindly importing old account/player data.

Completed so far:

- [x] Add runtime data modernisation notes
- [x] Add runtime schema debt report
- [x] Add schema debt audit tool
- [x] Add schema debt CI check
- [x] Add runtime boot dependency map
- [x] Add runtime table usage scanner
- [x] Add runtime table usage CI check
- [x] Add PHP runtime syntax check
- [x] Add auth readiness check
- [x] Add runtime auth compatibility helper
- [x] Update login/register flow to use auth compatibility helpers
- [x] Add users password column guard
- [x] Add guarded local account bootstrap tool
- [x] Add local account bootstrap docs
- [x] Add local account tool check
- [x] Add disposable MySQL local account database smoke test
- [x] Add account-bootstrap keys for `users` and `buddylist`
- [x] Add reusable MySQL 8 schema import-copy builder
- [x] Refactor local account DB smoke test to use the schema copy tool
- [x] Add verification database smoke test plan
- [x] Add local auth verification runbook
- [x] Add clean login endpoint review
- [x] Add clean first-boot review
- [x] Add first-boot trace runbook

Known database debt still present:

- [ ] Packed buddy/list storage such as comma-separated names
- [ ] Username-based links instead of stable numeric relationships
- [ ] Mixed account, player, inventory, and runtime state
- [ ] Inconsistent owner column names across runtime tables
- [ ] Legacy date/default values in the old schema shape
- [ ] Missing indexes/foreign keys beyond the narrow bootstrap layer
- [ ] Starter state requirements for clean first boot still unknown

Next Phase 5 targets:

- [ ] Add login decision/update helper once connector/local workflow allows it
- [ ] Add clean login endpoint smoke test
- [x] Add local/manual first-boot trace plan
- [ ] Run local/manual first-boot trace
- [ ] Map missing first-boot rows from real runtime errors
- [ ] Add minimal starter fixtures only when runtime evidence proves they are needed
- [ ] Keep full database normalisation behind compatibility adapters

## Phase 6: Launcher and Play Flow

Status: not started

- [ ] Document existing Electron launcher
- [ ] Clean Electron package identity
- [ ] Add browser launch notes
- [ ] Explore Ruffle support
- [ ] Keep the original working launcher until a replacement is tested

Recommended branches:

```text
electron/launcher-identity
launcher/ruffle-experiment
```

## Phase 7: Tooling

Status: not started

- [ ] Add setup scripts
- [ ] Add database reset scripts
- [ ] Add local dev start scripts
- [ ] Add basic checks for missing config

## Phase 8: Public Polish

Status: not started

- [ ] Clean project branding
- [ ] Add screenshots or setup images if useful
- [ ] Add issue templates
- [ ] Add contributing notes
- [ ] Add release notes once a stable local setup exists

## Do Not Do Yet

- Do not rename `game-full/` paths blindly
- Do not move SWF files blindly
- Do not mass rename PHP endpoints
- Do not delete old XML/config files until mapped
- Do not normalise packed tables directly under the old runtime without a compatibility layer
- Do not rewrite the backend in one giant pass
- Do not remove credits from documentation

## Working Rule

Small passes only. If a change breaks the current game boot flow, revert and map it first.
