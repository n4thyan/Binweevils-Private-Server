# Database Normalisation Rewrite Plan

This plan is the next database-focused track after Phase 5.

Phase 5 proved the clean local boot path and documented the old database debt. This next phase is about replacing the messy database shape in small, safe passes without breaking the old SWF/PHP runtime.

## Status

```text
Phase 5 runtime bootstrap: complete for the current local boot milestone
Next database track: planned
Implementation rule: compatibility adapters first
```

## Main rule

```text
Do not normalise the old runtime tables directly underneath the Flash client.
Add compatibility adapters first, then move reads/writes gradually.
```

The old client and PHP endpoints may depend on exact column names, packed strings, owner names, and legacy default values. A clean schema can be added beside the old one, but the old runtime contract must stay stable until adapters prove the new path works.

## Debt to clean up

### 1. Packed buddy/list storage

Current problem:

- Some social/list data is stored as comma-separated strings.
- This makes lookups, deletes, validation, and moderation harder.

Target shape:

```text
user_social_links
- id
- owner_user_id
- target_user_id
- relation_type
- status
- created_at
- updated_at
```

Examples of `relation_type`:

```text
buddy
best_friend
blocked
ignored
```

### 2. Username-based links

Current problem:

- Many runtime tables link records by username or owner name.
- Renames or casing differences can break relationships.

Target shape:

```text
users.id is the stable identity key
profile/runtime tables use user_id references
legacy username fields remain only where the old client still needs them
```

Adapter rule:

```text
new code reads/writes by user_id
old endpoints can still output username/ownerName until the client contract is replaced
```

### 3. Mixed account, player, inventory, and runtime state

Current problem:

- Account credentials, player display state, XP, economy, session keys, inventory, and runtime flags are mixed across old tables.

Target split:

```text
accounts              login identity and security fields
player_profiles       public weevil/profile state
player_progression    level, XP, prestige, trophies/progression state
player_economy        mulch/dosh and economy totals
sessions              active login/session state
inventory_items       item ownership
nest_state            nest/home runtime state
```

### 4. Inconsistent owner column names

Current problem:

- Tables use different owner columns such as username, ownerName, weevilID, idx, or user-style names.

Target shape:

```text
canonical internal key: user_id
legacy output names: handled by adapters only
```

### 5. Legacy date/default values

Current problem:

- Some old schema defaults use legacy or fake dates.
- Some timestamps are stored as strings or inconsistent values.

Target shape:

```text
created_at TIMESTAMP/DATETIME
updated_at TIMESTAMP/DATETIME
last_seen_at nullable TIMESTAMP/DATETIME
legacy display values generated only where the old client needs them
```

### 6. Missing indexes and foreign keys

Current problem:

- The old schema has limited relationship enforcement.
- Some lookups depend on slow or fragile text matches.

Target shape:

```text
indexes on all lookup columns
unique constraints for natural one-row relationships
foreign keys only after the runtime write path is understood
```

Do not add aggressive foreign keys until write order and cleanup behaviour are proven.

### 7. Starter state requirements

Current problem:

- Clean first boot may need more starter rows as more screens are tested.

Target approach:

```text
add starter fixtures only when a runtime trace proves they are required
keep fixtures small, local, and documented
avoid importing old production/player state as default data
```

## Suggested PR order

### PR 1: Database adapter boundary docs and naming rules

Docs only.

- Define canonical `user_id` rule.
- Define legacy-output rule.
- Define old-table read/write freeze policy.
- List endpoint groups that need adapters.

### PR 2: Read-only user lookup adapter

Small code pass.

- Add helper functions that resolve `username -> user_id` and `user_id -> username`.
- Do not change runtime behaviour yet.
- Add smoke checks around existing login/session path.

### PR 3: Social list adapter plan

Small code/docs pass.

- Map `buddylist`, block/ignore lists, and best-friend behaviour.
- Add adapter functions that can parse old packed strings safely.
- Keep writes going to the old table until tests exist.

### PR 4: Clean social table beside old data

Migration-only plus optional helper code.

- Add clean social link table.
- Backfill only local/dev data first.
- Keep old table as source of truth until dual-write is proven.

### PR 5: Dual-write for one safe relationship type

Tiny runtime pass.

- Pick one low-risk relationship type.
- Write to old shape and clean shape.
- Read from old shape until clean shape proves stable.

### PR 6: Move reads behind adapter

Runtime pass.

- Endpoints call adapter instead of reading packed strings directly.
- Adapter can read old or new shape.
- Old client response stays the same.

### PR 7: Repeat for progression, inventory, nest, and sessions

Do not do all systems at once.

Recommended order:

```text
sessions/auth
social lists
progression/economy
inventory
nest state
achievements/bin pets later
```

## Do not do in the database rewrite

- Do not delete old runtime columns before adapters exist.
- Do not rename columns used directly by old PHP endpoints.
- Do not normalise every table in one PR.
- Do not import old production/player data as clean default seed data.
- Do not add foreign keys before write order is known.
- Do not change SWF-facing response shapes unless a compatibility layer preserves old output.

## Success criteria

The database rewrite is working when:

- the clean local boot path still works
- old endpoints still return the same client-facing shapes
- new internal code can use stable numeric IDs
- packed strings are no longer required for new writes
- clean fixtures replace old imported player/staff/demo rows
- database relationships are documented before enforcement
- every migration is small enough to review and roll back
