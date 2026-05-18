# Pre-VPS Testing Plan

This note records the current direction before opening the server to a small private test group.

## Current direction

Use a legacy-compatible runtime database as the practical testing base.

That means the old database shape remains the runtime contract for now, because the old PHP, Node server, and SWFs expect that shape.

The long-term database work is still valid, but it should happen in small compatibility-safe passes instead of replacing the database all at once.

## Database rule

Use the old full database as the feature reference base, then sanitise it.

Keep useful reference/game data:

```text
levels
hats/apparel definitions
furniture/nest item definitions
garden/seed definitions
shop/catalogue rows
game reward definitions
trophy/achievement definitions
quest and mini-game reference rows
```

Remove old private/runtime player data:

```text
old users
old passwords
old sessions/login keys
old buddy lists
old inventories
old nests
old redeemed code history
old player progress/logs
old staff/demo/player accounts
```

## Security rule

Legacy-compatible database does not mean legacy auth.

Keep the newer password/session hardening:

```text
hashed passwords
rotated session/login keys
blank username/session-key rejection
no reuse of old imported user rows
fresh beta tester accounts only
```

Any old auth weakness should stay removed even if the runtime database uses the older table shape.

## Pre-VPS priorities

Before putting the server on the VPS for friends to test:

```text
1. Make chat usable with normal punctuation and numbers.
2. Keep invisible/control characters blocked so chat cannot be malformed.
3. Add simple chat commands with ! and / prefixes.
4. Keep basic moderator/admin flow available.
5. Use a sanitised old database for fuller feature compatibility.
6. Create fresh beta tester accounts.
7. Test common rooms, chat, shops, games, rewards, and codes.
```

## Chat policy

The chat should be relaxed enough for normal testers.

Allowed direction:

```text
letters
numbers
normal punctuation
basic symbols
spaces
```

Blocked direction:

```text
HTML tags
control characters
zero-width/invisible Unicode
formatting override characters
characters likely to break XML/chat packet shape
```

Profanity filtering should be a moderation helper, not a total chat blocker. For private testing, filtered words can be cleaned/replaced rather than instantly killing the chat flow.

## Chat commands

Commands should support both prefix styles:

```text
!help
/help
!online
/online
!room
/room
```

Normal messages without a prefix should continue to send as normal chat.

## Map selector note

The normal `URLPaths.xml` map path already points at the newer map. DEV config should match that direction too, so if the client loads the DEV URL paths it does not keep falling back to the old/new selector.

This is a convenience fix only. The New Bin locations themselves already work.

## Still not solved by this pass

```text
random Nest teleporter always going to Shopping Mall
Daily Brainstrain / Lab's Lab rewards
Weevil Wheels reward payout
shop Error 999 purchase paths
beta reward code setup
full admin dashboard polish
```

Those are next compatibility passes after the chat/database direction is stable.
