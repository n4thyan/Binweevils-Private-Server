# Architecture Notes

These notes describe the current imported layout. They are not a final architecture.

The project is being treated as a working compatibility base first, then modernised in small passes.

## Current Top-Level Layout

```txt
electron/      Legacy desktop launcher/client wrapper
game-full/     Preserved Flash/site compatibility layer
server/        Node/socket/private server layer
bwps.sql       Imported database dump
.env.example   Future environment/config template
docs/          Rewrite planning and technical notes
```

## Compatibility First

The existing game works because the client expects specific paths, filenames, endpoints, XML files, and response shapes.

Do not rename or move fragile files until the dependency chain is mapped.

Fragile areas include:

```txt
game-full/
game-full/php2/
game-full/externalUIs/
game-full/fixedCam/
game-full/cdn.binw.net/
main_*.swf
core*.swf
crossdomain.xml
flashpolicy.xml
```

## game-full/

This is the preserved game/site compatibility layer.

It may contain Flash files, copied web paths, CDN-style folders, PHP endpoints, XML configs, images, sounds, rooms, shops, and other assets expected by the original client.

For now, this folder should be treated as fragile.

Cleanup here should be limited to clear documentation, safe config extraction, and known dead files only.

## server/

This appears to hold the server-side Node/socket layer used by the private server.

Future work should map:

- Entry point
- Socket events
- Room handling
- Database usage
- Login/register flow
- Chat flow
- Moderation hooks
- Hardcoded config values

Once mapped, it can be modernised without changing the client-facing behaviour too early.

## electron/

This is the legacy desktop wrapper/client launcher area.

It can probably be modernised later or replaced with a browser/Ruffle option, but it should not be removed until the working launch flow is documented.

## Database

The current `bwps.sql` should be treated as an imported dump, not the final clean database format.

Future target:

```txt
database/schema.sql       Tables only
database/seed.example.sql Safe demo data only
```

Runtime data such as old user accounts, old staff accounts, old celeb/demo accounts, old bans, old buddy lists, and old private server records should be cleaned later.

## Modernisation Direction

The likely future structure is:

```txt
docs/
scripts/
database/
server/
public/
legacy/
```

But this should only happen after the current paths are mapped and tested.

## Rule

```txt
Preserve first. Modernise second. Rewrite only when the old behaviour is understood.
```