# Current Runtime Status

This note records the current local runtime position after the clean database, auth compatibility, session hardening, Ruffle socket proxy, banked XP, prestige, database adapter, and first feature-readiness passes.

## Current local milestone

The current target is not full feature restoration.

The current target is:

```text
Clean local database -> fresh local account -> PHP login/session -> game.php -> Ruffle SWF load -> socket proxy -> starting Nest / room state
```

That path has now been proven locally with clean local accounts against `bwps_clean`.

This means the core boot path is working well enough to continue the rewrite from a known local baseline.

## What works now

Current local trace has shown:

- The clean schema path can be imported into a modern XAMPP/MariaDB setup.
- Guarded local accounts can be created without importing old player/staff/demo rows.
- PHP login can update session/login fields for the local account.
- `game.php` can be reached after login.
- `/mainDEV663.swf` must be served from the web root for the current embedded SWF path.
- Ruffle can load the SWF in the browser.
- The Ruffle socket proxy can bridge the SWF socket path to the local Node game socket.
- The game can reach the starting Nest / room view using the local account.
- Logout now rotates session/login keys instead of leaving blank session data behind.
- Blank usernames and blank session keys are rejected by `confirmSessionKey()`.
- Banked XP can apply multiple level-ups in one pass up to level 80.
- Prestige progression exists after level 80 using lifetime XP, visible level reset, and scaled thresholds.
- Read-only identity and social-list adapters now exist for the database rewrite track.
- A clean `user_social_links` table exists beside the legacy `buddylist` table.
- First friend-request dual-write support exists, although first gameplay testing showed the client did not emit the expected friend-request packet yet.

## Current gameplay compatibility position

The clean runtime is a bootable baseline. It is not yet a full gameplay-complete server.

First local gameplay testing has shown this pattern:

```text
UI loads
        ↓
old client/server expects legacy reference data, old SWF/config routing, or old endpoint behaviour
        ↓
clean DB only has the narrow boot/account baseline
        ↓
feature silently fails, falls back, returns an old error, or behaves incompletely
```

Known examples:

- Some old map locations do not currently load as expected.
- Map/location routing appears to fall back to newer-bin equivalents in some cases.
- The Nest random teleporter currently sends the player outside Shopping Mall instead of choosing a valid random target.
- Shop buying returns Error 999 for hats/furniture.
- Starter/default apparel can display, including the default top hat, so apparel rendering itself is not completely broken.
- The issue with hats/furniture is currently treated as purchase/catalogue/inventory write flow, not a full apparel-rendering failure.
- Weevil Wheels can be played, but completion does not yet award Mulch, XP, or nest trophies.
- Lab's Lab / Daily Brainstrain needs endpoint and reward-flow audit.
- The current Buddy Tablet flow is not the desired long-term UX.
- Future social UX should restore the OG buddy list button and mailbox DM flow from the Nest mailbox instead of relying on the Buddy Tablet.

See:

```text
docs/runtime/feature-readiness-audit.md
```

## Security hardening note

CoDCrafted found and flagged the session-key exploit class fixed during the Phase 5 hardening passes.

The current protection relies on both sides of the fix:

- logout rotates old session/login keys instead of writing blank values
- `confirmSessionKey()` rejects blank usernames or blank session keys before checking the database

Both behaviours should be kept if the auth system is later replaced.

## Progression status

The old single-level XP flow has been improved.

Current progression behaviour:

```text
banked XP gained
        ↓
multiple level-ups can apply in one pass
        ↓
level 80 remains the normal run cap
        ↓
prestige can trigger after level 80
        ↓
visible level resets to 1
        ↓
prestige_count increases
        ↓
next thresholds scale upward
```

`users.xp` is treated as lifetime/banked XP. It is not reset when prestige triggers.

The prestige system requires the migration in:

```text
migrations/2026_05_17_add_prestige_system.sql
```

## What is intentionally not solved yet

Some old APIs were not fully implemented in the public source this rewrite started from. These should not be treated as blockers for the core rewrite phase.

Known future systems include:

- Achievements
- Bin pets
- Some invite/account status endpoints
- External analytics calls
- External advert calls
- Some mini-game and optional account endpoints
- Shop/payment/activation-style extras from the old site shape

For now, these can be documented or stubbed only when they block the core boot path.

Do not build full achievements, bin pets, shops, or custom features until the core local runtime is repeatable.

## Console noise that is not currently a core blocker

The browser console may still show errors from old external services, including:

- FontAwesome kit requests
- Swrve analytics requests
- SuperAwesome advert requests
- Old third-party tracking or advert domains

These should be cleaned later, but they are not proof that the local game boot path is broken.

## Real blockers vs future feature gaps

Treat these as core blockers:

- Login cannot create or maintain a session.
- The clean database cannot import.
- The local account bootstrap fails.
- `game.php` cannot load after login.
- The SWF cannot be served from the expected path.
- Ruffle cannot load the SWF at all.
- The socket proxy cannot connect to the local game socket.
- A missing local endpoint fully stops the boot path.
- A security regression allows blank session keys to authenticate.

Treat these as feature compatibility work unless they block boot:

- Map locations are missing, remapped, or falling back.
- Shop buying returns Error 999.
- Game completion does not award Mulch, XP, or trophies.
- Buddy/social buttons work inconsistently.
- Buddy Tablet opens where the OG mailbox/DM flow should eventually be restored.
- External analytics or advert failures appear in the console.
- Old promotional or account extras do not exist locally.

## Database status

Phase 5 has not completed a full database redesign.

It has completed the important groundwork:

- Clean schema split exists.
- MySQL/MariaDB import compatibility is handled through tooling.
- Runtime auth compatibility exists.
- Local account bootstrap exists.
- CI smoke tests cover the clean account bootstrap path.
- Major schema debt is documented.
- Prestige migration exists as a small runtime feature migration.
- Identity adapter exists for stable numeric user lookup.
- Social packed-list adapter exists for legacy `buddylist` parsing.
- Clean `user_social_links` migration exists beside the old table.
- Dry-run social backfill helper exists.
- First friend-request dual-write helper exists.

Known database debt remains for a later normalisation phase:

- Packed comma-separated buddy/list storage.
- Username-based relationships instead of stable numeric IDs.
- Mixed account, inventory, social, and runtime state.
- Inconsistent owner columns.
- Missing indexes and foreign keys outside the narrow bootstrap layer.
- Missing or incomplete clean reference/starter data for several gameplay systems.

These should be fixed behind compatibility adapters and reviewed seed packs, not by breaking the old SWF-facing runtime in one large pass.

## Current rule

For the rest of this phase:

```text
Do not chase every old missing feature blindly.
Keep the core boot path stable.
Document incomplete systems clearly.
Stub only when a missing endpoint blocks boot.
Use the old database as a reference source, not as dirty production seed data.
Restore feature compatibility in small passes.
Keep security fixes visible and credited.
```