# Changelog

This changelog tracks the current OG working-stack recovery pass.

## Current stable stack

Branch:

```text
stable/og-working-stack
```

Latest known-good tag:

```text
working-og-reward-codes
```

## 2026-05-20 recovery stack

### Session security

- Fixed blank session-key auth bypass.
- Prevented empty username/session key combinations from being accepted.
- Changed logout behaviour so old sessions are invalidated instead of being left with blank reusable values.

Tag:

```text
working-og-sessionfix
```

### Ruffle support

- Added Ruffle/browser support for running the Flash client without relying on old browser plugins.
- Added socket proxy support for the game server connection.
- Fixed FlashVars login path handling.

Tag:

```text
working-og-ruffle
```

### Chat commands and relaxed chat filter

- Added runtime chat command patching.
- Relaxed server-side chat handling.
- Added command handling while preserving normal chat.

Tag:

```text
working-og-chat-commands
```

### XP banking

- Added banked XP progression.
- Allowed a user with enough stored XP to move through multiple levels instead of only levelling once.

Tag:

```text
working-og-xp-banking
```

### Prestige system

- Added prestige progression after level 80.
- Added prestige tracking columns and trophy recording.
- Added migration file for the prestige system.

Tag:

```text
working-og-prestige
```

### Client command prefixes

- Relaxed SWF chat input restrictions to allow command prefixes and extra characters.
- Allows commands using prefixes such as `/`, `!`, and other special characters while keeping existing `cmd` command support.

Tag:

```text
working-og-chat-prefixes
```

### Nest teleporter

- Fixed nest teleporter behaviour so it chooses from the destination list instead of effectively sending players to the same destination every time.
- Changed the selection logic to choose a random destination directly.

Tag:

```text
working-og-nest-teleporter
```

### Admin and moderator commands

- Added moderator/admin-only chat command support.
- Added permission checks using moderator/admin state.
- Tested command behaviour in-game.

Tag:

```text
working-og-admin-mod-commands
```

### OG XP thresholds

- Replaced the temporary XP test curve with OG-style level 1 to 80 thresholds.
- Added a seed file for the 80-level XP table.
- Added a reset script for returning all users to level 1, XP 0, and next threshold 30.

Tag:

```text
working-og-xp-thresholds
```

### Reward codes

- Added starter reward-code seeds.
- Fixed reward-code redemption so XP, mulch, and dosh are applied correctly before the code is marked redeemed.
- Added session and user ownership checks to the redeem endpoint.
- Confirmed the in-game redeem UI receives and displays the correct reward response.

Starter codes:

```text
WELCOME2026 - 30 XP and 500 mulch
OGLEVELS    - 100 XP and 1000 mulch
NESTEGG     - 2500 mulch
```

Tag:

```text
working-og-reward-codes
```

## Development rules going forward

- Start from `stable/og-working-stack`.
- Use a feature branch for every change.
- Test in-game before merging.
- Keep the original KnowYourKnot source and database layout as the ground truth.
- Do not clean or replace the database unless there is a documented reason.
- Tag every known-good checkpoint.
- Back up htdocs, the database, and the repo after each stable feature.
