# Ruffle Socket Proxy Runbook

This runbook documents the local Ruffle socket bridge needed for the Flash runtime to talk to the Node game socket.

The working approach was provided from CorruptBandit's Ruffle setup notes and adapted for this rewrite.

## Why this exists

The old Flash client tries to open a socket connection to:

```text
127.0.0.1:9339
```

Modern browsers cannot expose raw Flash sockets directly through Ruffle. Ruffle needs a WebSocket proxy target instead.

The bridge is:

```text
Ruffle/SWF
  -> ws://localhost:3993
  -> websockify
  -> localhost:9339
  -> Node game socket
```

## Game page config

`game-full/game.php` now defines the Ruffle socket proxy before loading Ruffle:

```html
<script>
    window.RufflePlayer = window.RufflePlayer || {};
    window.RufflePlayer.config = {
        socketProxy: [
            {
                host: "127.0.0.1",
                port: 9339,
                proxyUrl: "ws://localhost:3993",
            }
        ]
    };
</script>
<script src="https://unpkg.com/@ruffle-rs/ruffle"></script>
```

The `host` and `port` values must match the socket address the SWF tries to connect to.

The `proxyUrl` value must match the WebSocket bridge started by `websockify`.

## Required local services

Keep these running for local browser/Ruffle testing:

```text
XAMPP Apache
XAMPP MySQL/MariaDB
Node game/web socket server
Node REST shim
websockify bridge
```

Known local ports:

```text
80     Apache HTTP
3306   MySQL/MariaDB
9339   Node game socket
2087   Node web socket helper
1122   Node REST shim
3993   websockify WebSocket bridge
```

## Start order

### 1. Start XAMPP

Start:

```text
Apache
MySQL
```

### 2. Start the Node game/web socket server

From the server folder:

```powershell
cd C:\xampp\htdocs\Binweevils-main\server
node Main.js
```

Expected running ports:

```text
9339
2087
```

### 3. Start the Node REST shim

In another PowerShell window:

```powershell
cd C:\xampp\htdocs\Binweevils-main\server
node rest.js
```

Expected running port:

```text
1122
```

If `rest.js` complains about `morgan` during local testing, install it temporarily in the served copy:

```powershell
npm.cmd install morgan --no-save
```

Do not run `npm audit fix` or `npm audit fix --force` as part of this local trace.

### 4. Start websockify

In another PowerShell window:

```powershell
websockify 3993 localhost:9339
```

If Windows cannot find `websockify`, install it in your local Python environment:

```powershell
py -m pip install websockify
```

Then try again:

```powershell
websockify 3993 localhost:9339
```

## Confirm ports

Use this check:

```powershell
$ports = 80,3306,9339,2087,1122,3993

Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
  Where-Object { $ports -contains $_.LocalPort } |
  ForEach-Object {
    $p = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
    [PSCustomObject]@{
      Port = $_.LocalPort
      PID = $_.OwningProcess
      Process = $p.ProcessName
      Path = $p.Path
    }
  } |
  Sort-Object Port |
  Format-Table -Auto
```

Expected process shape:

```text
80     httpd
3306   mysqld
1122   node
2087   node
3993   python or websockify process
9339   node
```

## Recommended local URL

Use one host consistently while tracing.

Recommended:

```text
http://127.0.0.1/
```

Avoid switching between `localhost` and `127.0.0.1` during the same trace unless the bug being tested is specifically host/origin related.

## What this does not solve by itself

This only bridges the SWF socket path.

It does not automatically implement every old HTTP fallback endpoint.

If the game still posts to:

```text
/BlueBox/HttpBox.do
```

then that is a separate BlueBox/HTTP polling compatibility issue. Keep that evidence separate from the Ruffle socket bridge.

## Good result

A good result after this setup is one of these:

```text
The game reaches a later screen than before
The Node game socket logs a real connection from Ruffle/websockify
The old BlueBox polling behaviour changes or reduces
The next blocker is clearer and not caused by missing socket bridging
```

## Capture if it still fails

Send back:

```text
Current browser URL
First red browser console error
First failed Network request
websockify terminal output
node Main.js terminal output
node rest.js terminal output
BlueBox log tail if the local capture shim is still present
```
