# Runtime Feature Readiness Audit

This audit records the first post-boot gameplay testing pass against the clean local database.

It is not a bug-fix pass. It explains which systems are working, which systems are only partly working, and which systems are probably failing because the clean database does not yet include the old reference rows, player starter rows, or compatibility adapters expected by the legacy client and runtime.

## Current conclusion

The clean database is good enough for the core boot path:

```text
login -> game.php -> SWF load -> socket bridge -> starting Nest / room view
```

It is not yet feature-complete for the full old game.

The main pattern seen during testing is:

```text
UI loads
        ↓
old client/server expects legacy database state or old endpoint behaviour
        ↓
clean DB only has the narrow boot/account baseline
        ↓
feature silently fails, returns an old error, or shows incomplete behaviour
```

This does not mean the rewrite is broken. It means the clean install is currently a bootable runtime baseline, not a complete playable server.

## Tested local setup

Local accounts used:

```text
local_demo
local_friend
```

Local database:

```text
bwps_clean
```

Known working local services during the pass:

```text
Node game server: 9339
REST shim: 1122
websockify bridge: 3993 -> 9339
```

## Observed feature state

| Feature | Observed status | Notes |
| --- | --- | --- |
| Login | Working | Local clean account can enter the game. |
| Room/Nest boot | Working | The player reaches the starting room/Nest view. |
| Socket bridge | Working | Ruffle/websockify route can reach the Node socket. |
| Default apparel display | Partly working | The default top hat loads on a new weevil. Apparel rendering itself is not completely dead. |
| Buddy list panel | Opens | Buddy list opens and shows the empty-list state. |
| Friend request button | Not firing packet | Clicking the add/friend button on another user did not log `friends/send-request` on the Node server. The dual-write code was not reached. |
| Ignore button | Works enough to show feedback | The ignore button displays an ignore-list success message. |
| Invite/Nest movement | Works enough to show feedback | Invite/Nest movement can trigger room feedback such as moving to the Buddy Tablet. |
| Mailbox | Misrouted by current client flow | Clicking the Nest mailbox shows `Moved to the Buddy Tablet!`. Future goal is to restore the OG mailbox/DM flow instead of using Buddy Tablet. |
| Buddy Tablet | Present but unwanted long-term | Current ugly Buddy Tablet flow should be removed later and replaced with OG buddy list and mailbox DM behaviour. |
| Map | Partly working | Map opens and can load some locations, but only the newer-bin location set appears to work. Old map locations need route/location audit. |
| Shop buying | Broken | Buying hats/furniture gives Error 999. Default hat display works, so the issue is likely purchase/catalogue/inventory write flow, not all apparel display. |
| Furniture buying | Broken | Same purchase problem as shops. Needs item catalogue and inventory write audit. |
| Weevil Wheels | Playable but rewards missing | Game can be played, but completion does not currently award Mulch, XP, or the nest trophy. |
| Lab's Lab / Daily Brainstrain | Broken or incomplete | Daily/game reward flow needs audit. |
| Random Nest teleporter | Partly working but wrong | Teleporter always sends the player outside the Shopping Mall instead of randomising from a valid location set. |
| Level display/progression | Issue observed | Lower priority for this pass because the prestige backend has already been added. Needs separate display/runtime audit later. |
| Secret/redeem codes | Existing feature shape | Code redemption exists in the game shape, but reward-code seed data and reward mapping need review before adding tester codes. |

## Why some buttons work while others do not

The playercard can open and some buttons can work without proving the whole social system works.

Observed split:

```text
Ignore button -> shows feedback
Invite/Nest button -> shows room feedback
Friend request button -> sends no observed friends/send-request packet
```

This suggests the friend request issue is likely in one of these places:

```text
client-side button wiring
client-side gating or account/social starter state
missing legacy social/table state expected before the SWF sends the request
an alternate packet/endpoint name that has not been mapped yet
```

The current `user_social_links` dual-write cannot be blamed for this specific test because the server did not receive the friend request packet at all.

## Shop and inventory interpretation

The default top hat loading is important evidence.

It means:

```text
some starter/default apparel state can render
```

It does not mean:

```text
shop buying, item catalogue, price checks, inventory inserts, and balance updates are working
```

Error 999 when buying should be treated as a purchase-pipeline problem first.

Likely areas to inspect:

```text
shop/catalogue reference tables
appareltypes / itemtype / itemtypets rows
weevilhats / weevilitems ownership inserts
mulch/dosh balance update path
client response shape expected after purchase
old PHP/internal helper behaviour
```

## Database reference-data problem

The clean database intentionally avoids importing old users, staff/demo rows, old inventories, old buddy lists, old session keys, and old player progress.

That is still the correct direction.

The new problem is that several features need clean reference/starter data before they can work:

```text
locations and map metadata
shop catalogues
apparel and furniture definitions
level and reward definitions
game reward definitions
achievement/trophy definitions
starter inventory and starter nest state
redeem code definitions
```

Do not solve this by dumping the full old database back into the clean install.

Safer approach:

```text
old bwps database = reference source
bwps_clean = clean runtime target
reviewed seed files = controlled bridge between the two
```

## Existing database docs that support this direction

The project already has seed planning docs for safe reference-data extraction:

```text
docs/database/catalogue-seed-plan.md
docs/database/catalogue-seed-export.md
docs/database/php-table-usage.md
```

Those docs already separate safe reference/catalogue tables from old player state. This audit confirms that the next gameplay work should continue that seed-and-adapter approach.

## Recommended fix order

### 1. Map and location compatibility

Reason: moving around the game makes every other feature easier to test.

Tasks:

```text
map old and new location IDs
inspect locationDefinitions XML/config files
identify why only newer-bin locations load
fix random teleporter location source
add a safe list of valid random teleporter targets
```

### 2. Shop purchase pipeline

Reason: Error 999 is a clear, repeatable failure.

Tasks:

```text
trace hat and furniture purchase endpoint/packet
confirm required catalogue tables and rows
confirm ownership insert table for hats and furniture
confirm mulch/dosh update path
add or import reviewed catalogue seed rows if missing
keep old response shape stable
```

### 3. Game reward pipeline

Reason: Weevil Wheels already runs, but reward writes are missing.

Tasks:

```text
trace game completion packet/endpoint
map reward tables and trophy tables
confirm Mulch and XP update path
confirm nest trophy insert path
add reward compatibility helper if needed
```

### 4. Daily Brainstrain and Lab's Lab

Reason: likely depends on both game definitions and reward timers.

Tasks:

```text
map endpoint/packet
check gamebraintraining table usage
check game-rewards usage
add clean seed/reference data only after review
```

### 5. Social system and Buddy Tablet replacement

Reason: the future goal is OG flow, but it is not the best first fix while core feature data is missing.

Tasks:

```text
find why friend request button sends no packet
keep packed buddylist compatibility until reads/writes are safely bridged
remove Buddy Tablet later
restore OG buddy list button flow
restore mailbox DM flow from the Nest mailbox
keep user_social_links as the future clean social table
```

### 6. Redeem codes for beta testers

Reason: useful for testing, but should wait until reward target tables are clearer.

Supported reward ideas:

```text
nest item
Mulch
Dosh
hat
XP
seed/garden item
```

Do not seed old public/private-server codes blindly. Create fresh local/tester codes after the reward mapping is known.

## Do not do yet

```text
do not import the full old dirty database
do not delete Buddy Tablet code before mapping what still depends on it
do not rewrite the whole shop system in one pass
do not move friend reads fully to user_social_links yet
do not assume every silent click is a JS bug until DB/reference state is checked
do not treat old analytics/ad failures as gameplay blockers
```

## Next concrete pass

The next safe pass should be:

```text
Map/location compatibility audit and seed plan
```

Target output:

```text
docs/runtime/map-location-compatibility.md
```

Expected follow-up after that:

```text
small location/teleporter compatibility fix or reviewed location seed
```

After maps are stable, move to:

```text
Shop purchase pipeline audit
```