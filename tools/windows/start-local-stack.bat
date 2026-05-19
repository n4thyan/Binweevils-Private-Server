@echo off
setlocal

REM Binweevils local test stack starter for the known-working chat command branch.
REM Keep XAMPP Apache and MySQL running before launching this.

set "ROOT=%~dp0..\.."
set "SERVER=%ROOT%\server"
set "ELECTRON=%ROOT%\electron"

cd /d "%ROOT%"

if exist "C:\xampp\php" set "PATH=C:\xampp\php;%PATH%"
if exist "C:\xampp\mysql\bin" set "PATH=C:\xampp\mysql\bin;%PATH%"

echo Starting Binweevils local stack from:
echo %ROOT%
echo.
echo Make sure XAMPP Apache and MySQL are already green/running.
echo.

start "BWPS Node Game Server" cmd /k "cd /d "%SERVER%" && node Main.js"
start "BWPS REST Shim" cmd /k "cd /d "%SERVER%" && node rest.js"
start "BWPS Websockify Bridge" cmd /k "websockify 3993 localhost:9339"
start "BWPS Electron Client" cmd /k "cd /d "%ELECTRON%" && npm.cmd start"

echo Opened local stack windows.
echo Test accounts usually used on bwps_clean:
echo   local_demo / local-test-password
echo   local_friend / localfriend123
echo.
pause
