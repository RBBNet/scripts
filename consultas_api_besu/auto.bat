@echo off
setlocal enabledelayedexpansion

call enode.md_downloader.bat

:begin
node getSignerMetrics.js > %temp%\RPC-calls-auto.txt

echo. >> %temp%\RPC-calls-auto.txt
echo. >> %temp%\RPC-calls-auto.txt

node adminPeers.js >> %temp%\RPC-calls-auto.txt

set /p newState=<%temp%\RPC-calls-auto.txt
if "!newState!" neq "!prevState!" (
  cls
  type %temp%\RPC-calls-auto.txt
  set prevState=!newState!
)

timeout -t 4 > nul 2>&1
goto begin
