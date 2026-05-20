# Project scope

This project is an unofficial OG-first Bin Weevils private-server recovery and development stack.

## Source of truth

The KnowYourKnot Binweevils source remains the ground truth for the game structure, server flow, assets, database layout, and Flash client behaviour.

The goal is not to tear the project apart and rebuild it from scratch. The goal is to preserve the original working stack, understand it, and apply small improvements that are easy to test and easy to roll back.

## Current direction

The current stable branch is:

```text
stable/og-working-stack
```

This branch is intended to be the safe base for:

- local development,
- in-game testing,
- VPS deployment preparation,
- site customisation,
- future feature branches.

## Development principles

### Keep the original database stable

The original database is tightly coupled to the game. Avoid cleaning, renaming, deleting, or restructuring tables unless a change is proven necessary.

Preferred database changes are:

- small migrations,
- seed files,
- additive columns,
- clearly named scripts,
- reversible changes where possible.

Avoid broad cleanup passes.

### Keep feature branches small

Every feature should start from `stable/og-working-stack` and live on its own branch.

Examples:

```text
feature/redeem-code-seeds
feature/admin-mod-chat-commands
feature/nest-teleporter-random-destinations
```

### Test in-game before merging

A change should not be merged only because the code looks right. It should be tested through the actual game flow wherever possible.

### Tag known-good checkpoints

When a feature is tested and merged, tag the known-good state.

Examples:

```text
working-og-reward-codes
working-og-xp-thresholds
working-og-admin-mod-commands
```

### Back up after stable progress

After a stable feature lands, back up:

- `C:\xampp\htdocs`,
- the `bwps` database,
- the repo without `node_modules` and `.git`.

## Current feature stack

The current stable stack includes:

- session-key exploit fix,
- Ruffle/socket proxy support,
- relaxed chat filter and command prefixes,
- chat commands,
- admin/mod chat commands,
- XP banking,
- prestige system,
- OG level XP thresholds,
- random nest teleporter destinations,
- working starter reward codes.

## Near-term roadmap

Likely next work:

- site customisation before VPS deployment,
- applying external event-system fixes,
- refining public setup documentation,
- adding more starter/reward codes,
- fixing shop/catalogue behaviour,
- improving moderation logging,
- investigating big-weevil/mod scale commands later.

## Out of scope for this phase

For now, avoid:

- replacing the Flash client with HTML5 inside this repo,
- major database redesign,
- large untested rewrites,
- live scale packet work without confirming the SWF/client handler,
- changes that make the OG source harder to compare with upstream.
