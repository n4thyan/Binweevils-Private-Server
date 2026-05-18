# Pre-VPS Change Log

This document is a quick handoff note for private testers or dev helpers reviewing the pre-VPS work.

## Current Goal

Get the server into a practical private-test state before deploying it to the VPS.

This means:

```text
usable chat
basic commands
basic moderation tools
newer-bin map default
legacy-compatible database direction documented
old auth weaknesses kept fixed
```

## PR 59: Pre-VPS Chat and Testing Prep

Main branch merge:

```text
Merge pull request #59 from n4thyan/feature/pre-vps-chat-map-polish
```

Main files changed:

```text
server/chatRuntimePatch.js
server/Main.js
game-full/binConfig/uk/URLPathsDEV.xml
docs/runtime/pre-vps-testing-plan.md
README.md
docs/ROADMAP.md
```

What changed:

```text
- Added a chat runtime patch loaded from server/Main.js.
- Added first-pass chat sanitising.
- Added simple command groundwork.
- Added optional map config alignment for DEV URL paths.
- Documented the decision to use a sanitised legacy-compatible runtime DB for private testing.
- Documented that password/session hardening must stay even if the old DB shape is used.
```

Important testing result after PR 59:

```text
The old SWF chat input appears to strip or steal symbol characters like ! and /.
Numbers may also be captured by old action hotkeys before they reach Node.
```

That means command prefixes based on symbols are not reliable from the actual Flash client.

## Follow-up PR: Chat Command and Filter Fix

Branch:

```text
fix/chat-filter-debug-and-cmd-prefix
```

Main files changed:

```text
server/chatRuntimePatch.js
docs/runtime/pre-vps-change-log.md
```

What changed:

```text
- Commands now use a typed word prefix: cmd
- No bare commands like help or online, to avoid accidental triggers in normal chat.
- Symbol commands still exist server-side, but the SWF may not let users type them.
- Broad leo-profanity dictionary filtering was removed from the runtime patch.
- The chat filter is now a small severe-slur denylist.
- Normal adult swearing such as shit, piss, fuck, bollocks should be allowed.
- Invisible/control characters remain blocked.
- HTML/XML-ish packet-breaking characters remain stripped/rejected.
- Optional raw chat debug logging was added through BW_CHAT_DEBUG=1.
```

Commands to test:

```text
cmd help
cmd ping
cmd online
cmd room
cmd where username
```

Moderator commands to test with a moderator account:

```text
cmd modhelp
cmd warn username message
cmd kick username
```

Debug mode:

```powershell
$env:BW_CHAT_DEBUG="1"
node Main.js
```

When debug is enabled, the Node console prints:

```text
[CHAT_RAW]
[CHAT_NORMALIZED]
```

Use that to confirm whether numbers/symbols are reaching Node or being swallowed by the SWF before the server sees them.

## Still Not Fixed By These Chat PRs

```text
- If the SWF itself blocks numbers or symbols, Node cannot fix that alone.
- Shop buying / Error 999 is not fixed yet.
- Furniture and hat purchase paths are not fixed yet.
- Weevil Wheels reward payout is not fixed yet.
- Daily Brainstrain / Lab's Lab rewards are not fixed yet.
- Random Nest teleporter still needs its own compatibility pass.
- Admin dashboard still needs setup/polish.
```

## Next Major Pass

Set up a legacy-compatible beta database.

The working decision is:

```text
Use the old DB shape for runtime compatibility.
Sanitise old private/player rows.
Keep old reference/game data.
Create fresh beta tester accounts.
Run newer migrations/security fixes on top.
```

Expected to help with:

```text
shops
hats
furniture
levels
game rewards
trophies
codes
catalogues
mini-game reference data
```

## Security Rule

Do not undo the newer auth hardening.

Even with the old database shape:

```text
- Keep hashed passwords.
- Keep session/login key hardening.
- Do not reuse imported old user rows.
- Do not import old passwords or old active sessions.
- Create fresh beta tester accounts only.
```
