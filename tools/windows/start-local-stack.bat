@echo off
setlocal

REM Binweevils local test stack starter
REM Opens the Node game server, REST shim, websockify bridge, and Electron client.

set "ROOT=%~dp0..\.."
set "SERVER=%ROOT%\server"
set "ELECTRON=%ROOT%\electron"

cd /d "%ROOT%"

if exist "C:\xampp\php" set "PATH=C:\xampp\php;%PATH%"
if exist "C:\xampp\mysql\bin" set "PATH=C:\xampp\mysql\bin;%PATH%"

echo Starting Binweevils local stack from:
echo %ROOT%
echo.

start "BWPS Node Game Server" cmd /k "cd /d "%SERVER%" && node Main.js"
start "BWPS REST Shim" cmd /k "cd /d "%SERVER%" && node rest.js"
start "BWPS Websockify Bridge" cmd /k "websockify 3993 localhost:9339"
start "BWPS Electron Client" cmd /k "cd /d "%ELECTRON%" && npm.cmd start"

echo Opened local stack windows.
echo Login test account: local_demo / password123
echo.
pause
