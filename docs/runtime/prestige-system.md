# Prestige system follow-up

This follows PR #55, which already fixed banked XP levelling up to the current level 80 cap.

## Behaviour

```text
level 80 reached
extra XP keeps building
        ↓
prestige_count increases
display level resets to 1
        ↓
XP thresholds scale upward
        ↓
prestige trophies can be earned again per prestige run
```

## Storage

The system keeps `users.xp` as lifetime/banked XP. It does not reset XP on prestige.

New columns:

- `users.prestige_count`
- `users.prestige_xp_base`

New table:

- `prestige_trophies`

`prestige_xp_base` is the player's XP at the moment they prestige. The next run uses absolute thresholds above that base value, so existing XP does not instantly re-level the player back to 80.

## Scaling

Each prestige run increases the XP delta between display levels by 35%.

Formula used by the runtime hook:

```text
scaled_delta = round(raw_level_delta * (1 + prestige_count * 0.35))
```

Example:

- Prestige 1 = 1.35x level gaps
- Prestige 2 = 1.70x level gaps
- Prestige 3 = 2.05x level gaps

## Runtime approach

The hook is included from `game-full/essential/backbone.php` after `internal.php`.

It does not redeclare `levelWeevil()`. This keeps the PR #55 code intact and avoids a risky large rewrite of `internal.php`.

The hook runs at shutdown and checks the logged-in weevil. It can:

- trigger a prestige when level 80 is reached
- correct `xp1` / `xp2` onto prestige-scaled thresholds
- advance through multiple prestige levels if enough extra XP has been banked
- record one prestige trophy row per prestige count + display level

## Install

Run:

```sql
SOURCE migrations/2026_05_17_add_prestige_system.sql;
```

Then make sure `game-full/essential/prestige.php` exists and `backbone.php` includes it after `internal.php`.
