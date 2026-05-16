# Rewrite Roadmap

This roadmap keeps the current working experience safe while the repo is cleaned up.

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

Recommended follow-up branch:

```txt
audit/game-full-endpoints
```

## Phase 3: Config Cleanup

Status: in progress

- [x] Add Node `.env` loader without new dependencies
- [x] Add `server/config.js`
- [x] Move Node database config behind `server/config.js`
- [x] Move main Node game/web socket ports behind config
- [x] Move older legacy shim host/port behind config
- [x] Add REST shim env placeholders and discovery config values
- [x] Keep old localhost defaults when no `.env` exists
- [x] Keep `.env.example` updated
- [x] Document Node config support
- [ ] Update REST shim runtime code in a separate small pass
- [ ] Add PHP config support later, after Node config is stable
- [ ] Document Linux/VPS setup later

Current branch:

```txt
config/rest-shim-env
```

Recommended follow-up branches:

```txt
config/rest-shim-code
config/php-env-support
```

## Phase 4: Database Cleanup

- Split current SQL dump into schema and seed files
- Remove old runtime account data
- Replace old staff/mod/celeb/demo accounts with safe examples
- Add clean admin/test accounts for local development
- Document import/reset steps

Target structure:

```txt
database/schema.sql
database/seeds/catalogue.sql
database/seeds/dev.sql
```

Recommended branch:

```txt
database/schema-seed-split
```

## Phase 5: Server Rewrite

- Map current server entry points
- Add logging
- Clean database access
- Clean room/socket handling
- Keep client-facing responses compatible
- Replace one endpoint or module at a time

Recommended branches:

```txt
server/package-scripts
server/config-cleanup
server/socket-protocol-map
```

## Phase 6: Launcher and Play Flow

- Document existing Electron launcher
- Clean Electron package identity
- Add browser launch notes
- Explore Ruffle support
- Keep the original working launcher until a replacement is tested

Recommended branches:

```txt
electron/launcher-identity
launcher/ruffle-experiment
```

## Phase 7: Tooling

- Add setup scripts
- Add database reset scripts
- Add local dev start scripts
- Add basic checks for missing config

## Phase 8: Public Polish

- Clean project branding
- Add screenshots or setup images if useful
- Add issue templates
- Add contributing notes
- Add release notes once a stable local setup exists

## Do Not Do Yet

- Do not rename `game-full/` paths blindly
- Do not move SWF files blindly
- Do not mass rename PHP endpoints
- Do not delete old XML/config files until mapped
- Do not rewrite the backend in one giant pass
- Do not remove credits from documentation

## Working Rule

Small passes only. If a change breaks the current game boot flow, revert and map it first.