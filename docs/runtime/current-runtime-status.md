# Current Runtime Status

This note records the current local runtime position after the clean database, auth compatibility, and Ruffle socket proxy passes.

## Current local milestone

The current target is not full feature restoration.

The current target is:

```text
Clean local database -> fresh local account -> PHP login/session -> game.php -> Ruffle SWF load -> socket proxy -> starting Nest / room state
```

That path has now been proven locally with a clean `local_demo` account against `bwps_clean`.

This means the core boot path is working well enough to continue the rewrite from a known local baseline.

## What works now

Current local trace has shown:

- The clean schema path can be imported into a modern XAMPP/MariaDB setup.
- A guarded local account can be created without importing old player/staff/demo rows.
- PHP login can update session/login fields for the local account.
- `game.php` can be reached after login.
- `/mainDEV663.swf` must be served from the web root for the current embedded SWF path.
- Ruffle can load the SWF in the browser.
- The Ruffle socket proxy can bridge the SWF socket path to the local Node game socket.
- The game can reach the starting Nest / room view using the local account.

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

Treat these as future feature gaps unless they block boot:

- Achievements returning an incomplete response shape.
- Bin pets missing or partially implemented.
- Optional panels showing empty state.
- External analytics or advert failures.
- Old promotional or account extras not existing locally.

## Database status

Phase 5 has not completed a full database redesign.

It has completed the important groundwork:

- Clean schema split exists.
- MySQL/MariaDB import compatibility is handled through tooling.
- Runtime auth compatibility exists.
- Local account bootstrap exists.
- CI smoke tests cover the clean account bootstrap path.
- Major schema debt is documented.

Known database debt remains for a later normalisation phase:

- Packed comma-separated buddy/list storage.
- Username-based relationships instead of stable numeric IDs.
- Mixed account, inventory, social, and runtime state.
- Inconsistent owner columns.
- Missing indexes and foreign keys outside the narrow bootstrap layer.

These should be fixed behind compatibility adapters, not by breaking the old SWF-facing runtime in one large pass.

## Current rule

For the rest of this phase:

```text
Do not chase every old missing feature.
Keep the core boot path stable.
Document incomplete systems clearly.
Stub only when a missing endpoint blocks boot.
Save proper feature rebuilding for later phases.
```
