# Map and Location Compatibility

This note records the current map/location direction after the first gameplay testing pass on the clean local database.

## Current decision

Use the newer Bin map as the normal server map for now.

The old/new map selector is not useful for the current rewrite baseline because:

- most players naturally gather in the newer shared areas such as Flum's Fountain
- the old-bin route adds extra compatibility work before it adds useful testing value
- the clean database/reference-data work already needs careful seed planning
- keeping one active location set makes early private testing easier

This does not delete the old map SWFs. It only makes the default map button open the newer map directly.

## Current XML path shape

The current URL path config has these map entries:

```xml
<PATH NAME="map" URL="externalUIs/mapSelection_27_03_21.swf"/>
<PATH NAME="oldMap" URL="externalUIs/mapOld_06_05_21b.swf"/>
<PATH NAME="newMap" URL="externalUIs/mapNew_140521.swf"/>
```

The compatibility direction is:

```text
map -> newMap SWF
oldMap -> keep available for reference
newMap -> keep available for explicit callers
```

That keeps the legacy assets in the repository while avoiding the selector path during normal play.

## Why not build a custom SWF now

A custom curated map SWF may be useful later, but it is not the best first fix.

Safer order:

```text
1. Use the existing newer map SWF.
2. Confirm travel works for the important rooms.
3. Fix missing DB/reference rows and server route handling.
4. Only build or edit a custom map UI after the runtime location list is stable.
```

That avoids wasting time editing Flash assets while the location definitions, room IDs, and clean reference data are still being mapped.

## Important current locations

Early private testing should prioritise the locations people are likely to use first:

```text
Nest
Flum's Fountain
Dosh Palace
Shopping Mall / shop exterior
Labs Lab
Weevil Wheels / game entry points
```

Other locations can be restored and verified gradually after the main social/testing loop feels stable.

## Dosh Palace note

Dosh Palace matters because it contains the weevil editor/changer flow.

Future work around the weevil changer can include:

```text
allowing a saved weevil definition to be applied
widening the random colour shade pool
keeping client-visible colours inside safe accepted ranges
```

Do not mix that with this map pass. First make the map route stable, then handle the weevil changer as its own compatibility feature.

## Random Nest teleporter

The Nest random teleporter currently sends the player outside Shopping Mall instead of picking a valid random target.

Treat this as a separate server/runtime compatibility fix after the map path has been simplified.

Target behaviour:

```text
teleporter click
        ↓
server chooses from a reviewed allow-list of valid new-bin locations
        ↓
client moves to that room
```

The allow-list should not include broken, mission-only, tycoon-only, or unseeded rooms until they are verified.

## What not to do

```text
do not delete oldMap yet
do not delete mapSelection yet
do not hand-edit SWF binaries until route/config fixes are tested
do not re-import the full old database just to make every location appear
do not add old-bin rooms to the private-test default loop unless they are actually useful
```

## Next pass after this

After the default map opens the newer map directly, test these manually:

```text
open map
travel to Flum's Fountain
travel to Dosh Palace
travel to Shopping Mall exterior
travel back to Nest if possible
click the Nest random teleporter
```

Capture which room names work, which ones fail, and whether failure is a missing SWF/config issue, a missing database/reference row, or a server room route issue.
