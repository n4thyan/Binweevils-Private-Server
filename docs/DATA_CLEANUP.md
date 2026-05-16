# Runtime Data Cleanup Plan

This file tracks cleanup for old runtime data.

The goal is to remove old private-server state while keeping proper project credits in documentation.

## Keep

Keep documentation credit for:

- Original reference repo
- Original private server work
- Original game rights holders
- Rewrite maintainers

Keep real Bin Weevils NPC/game content if the client needs it.

## Clean Later

Audit and clean:

- Old moderator usernames
- Old staff usernames
- Old celeb/demo accounts from older private server communities
- Old test accounts
- Old default passwords
- Old bans
- Old buddy lists
- Old private profile data
- Old server/community names inside runtime configs
- Old Discord invite references
- Hardcoded local paths
- Hardcoded database credentials

## Likely Places to Check

```txt
bwps.sql
server/
game-full/php2/
game-full/php/
game-full/login/
game-full/register/
game-full/profilePics/
game-full/gallery/
```

## Replacement Data

Use safe local examples instead of old real/community data.

Example names:

```txt
admin
moderator
demo_weevil
test_weevil
shop_tester
nest_tester
room_tester
```

## Future Database Target

```txt
database/schema.sql
database/seed.example.sql
```

`schema.sql` should contain table structure only.

`seed.example.sql` should contain safe local demo data only.

## Rule

```txt
Credits stay in docs.
Old runtime people/account data gets removed from code, configs, and seed files.
```