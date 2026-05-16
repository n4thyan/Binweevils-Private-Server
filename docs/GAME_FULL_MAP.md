# game-full Compatibility Map

This document maps the preserved `game-full/` layer without changing it.

`game-full/` should be treated as a fragile compatibility layer. The Flash client, PHP login flow, cookies, SWF paths, and localhost URLs are tightly linked.

## Main files observed

```txt
game-full/index.php
game-full/game.php
game-full/login/login.php
game-full/register/index.php
game-full/register/create-new-weevil.php
game-full/essential/backbone.php
game-full/essential/config.php
game-full/essential/internal.php
game-full/essential/funcs.php
```

There are likely many more PHP, SWF, XML, asset, CDN-style, and mirror-cache paths under `game-full/`. This file records the first important boot/login path.

## Current browser flow

The current Electron launcher opens:

```txt
http://localhost
```

That lands on:

```txt
game-full/index.php
```

The login form posts to:

```txt
http://localhost/login/login.php
```

On success, the PHP login handler redirects to:

```txt
../game.php
```

Then `game.php` embeds:

```txt
/mainDEV663.swf?ver=1
```

with FlashVars including:

```txt
cluster=uk
loginPath=http://localhost/
autoBin=false
zone=
```

## Login page: index.php

`game-full/index.php` is the public login page.

Observed behaviour:

- includes `essential/backbone.php`
- decrypts the `err` query string with AES helper logic
- renders the returning-player login form
- posts `userID` and `password` to `/login/login.php`
- points successful login redirect toward `/game.php`
- includes old external assets/scripts such as Google Fonts, Font Awesome, SweetAlert, ad scripts, and social links

Treatment:

```txt
Status: active login shell
Risk: high
Touch now: no
Future cleanup: branding/social/ad/link cleanup after boot flow is tested
```

## Game page: game.php

`game-full/game.php` is the main Flash container page.

Observed behaviour:

- includes `essential/backbone.php`
- requires cookies named `weevil_name` and `sessionId`
- calls `confirmSessionKey()` before loading the game
- redirects to the homepage if cookies/session validation fail
- opens a WebSocket to `ws://localhost:2087`
- forwards WebSocket messages into Flash with `flashContentObject.receiveFromWS(e.data)`
- embeds `/mainDEV663.swf?ver=1`

Treatment:

```txt
Status: active game shell
Risk: very high
Touch now: no
Future cleanup: move host/ports into config only after local boot is verified
```

## Shared PHP bootstrap: essential/backbone.php

`game-full/essential/backbone.php` is the shared PHP include used by the login and game pages.

Observed includes:

```txt
essential/checksum.php
essential/config.php
essential/internal.php
essential/protections.php
essential/aes256.php
essential/funcs.php
essential/sock.php
```

Treatment:

```txt
Status: active shared bootstrap
Risk: very high
Touch now: no
```

## PHP database config: essential/config.php

`game-full/essential/config.php` currently defines local database values:

```txt
DB_HOST = localhost
DB_USER = root
DB_PASS = empty string
DB_NAME = bwps
```

Treatment:

```txt
Status: active config
Risk: high for public/VPS use
Touch now: no
Future branch: config/env-support
```

## Login handler: login/login.php

`game-full/login/login.php` handles login and logout.

Observed login behaviour:

- receives `userID` and `password`
- looks up `users.username`
- compares the submitted password with the stored database value
- checks `active`
- checks temporary ban timing through `bannedUntil`
- generates `sessionKey` and `loginKey`
- updates `lastLogin` and `loginIP`
- sets cookies named `sessionId` and `weevil_name`
- redirects to `../game.php`

Observed logout behaviour:

- clears the cookies
- clears `sessionKey` and `loginKey` in the users table
- redirects to homepage

Treatment:

```txt
Status: active auth handler
Risk: high
Touch now: no
Future cleanup: modern password handling, safer updates, safer public defaults
```

## Registration page: register/index.php

`game-full/register/index.php` renders the registration UI.

Observed behaviour:

- collects `userID` and `password`
- posts to `create-new-weevil.php`
- expects response strings such as `responseCode=2`, `responseCode=3`, and `responseCode=999`
- includes several old third-party scripts and ad/media tags

Treatment:

```txt
Status: likely active registration shell
Risk: medium/high
Touch now: no
Future cleanup: simplify dependencies after registration flow is tested
```

## Registration handler: register/create-new-weevil.php

`game-full/register/create-new-weevil.php` creates new users.

Observed behaviour:

- includes `essential/backbone.php`
- includes profanity/censor helpers
- contains a large reserved-name list
- contains old third-party verification configuration in source
- accepts `userID`, `password`, and `recap`
- inserts into `users`
- creates `sessionKey` and `loginKey`
- writes `lastLogin`, `createdAt`, and `regIP`
- calls `createBuddyListForWeevil($username)` after insert
- sets `sessionId` and `weevil_name` cookies
- redirects to `../game.php`

Important note:

The current handler appears to define reserved-name/profanity checks but does not clearly enforce all of them in the visible create flow. This should be tested and cleaned later.

Treatment:

```txt
Status: likely active registration handler
Risk: high
Touch now: no
Future cleanup: remove old third-party verification config, modern password handling, validate names, replace old seed flow
```

## Shared internal PHP: essential/internal.php

`game-full/essential/internal.php` contains many shared database functions.

Observed responsibilities:

- admin panel helpers
- moderation/game log helpers
- admin login helper
- user login helper
- session key generation
- login key generation
- session confirmation
- login details for the Flash client
- weevil stats/profile data
- chat state handling
- weevil definition validation and changes
- economy/stat updates

Treatment:

```txt
Status: active shared runtime library
Risk: very high
Touch now: no
Future cleanup: split by domain after callers are mapped
```

## Current cookie contract

The current PHP/Flash flow depends on:

```txt
weevil_name
sessionId
```

These cookies are used by:

- `game.php`
- `confirmSessionKey()`
- profile/stats helpers
- `BinWeevilsWeb.js` cookie verification

Do not rename them until the whole legacy flow is mapped.

## Current host/port contract

Observed fixed host/ports:

```txt
http://localhost
ws://localhost:2087
/mainDEV663.swf?ver=1
```

Related Node runtime mapping:

```txt
server/Main.js -> BinWeevilsWeb on 2087
server/Main.js -> BinWeevils on 9339
server/rest.js -> Express on 1122
```

Do not move ports into config until local boot is verified.

## Immediate notes before public use

Do not deploy this layer publicly as-is.

Known issues to clean later:

- legacy password comparison and insert flow
- old third-party verification config in source
- local root database config
- static localhost links throughout page templates
- external ad/social/script dependencies
- old Discord/Twitter/community links
- old author/community text in runtime pages
- IP logging in login/register rows

## Safe cleanup order

1. Confirm local boot flow with Apache/XAMPP and Node.
2. Map all PHP endpoints called by `mainDEV663.swf`.
3. Map all PHP functions called by those endpoints.
4. Move DB config to environment/local config.
5. Replace registration/login password handling.
6. Replace old runtime community links and ad scripts.
7. Split PHP helper files only after callers are mapped.
8. Explore Ruffle/browser replacement separately.

## Rule

```txt
Do not modernise game-full by mass editing. Map the client contract first.
```