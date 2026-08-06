@echo off
setlocal

set ATTEMPTS=0
set MAXATTEMPTS=5

:wait

set /a ATTEMPTS+=1

echo.
echo Waiting for PDD share... Attempt %ATTEMPTS% of %MAXATTEMPTS%

if exist "\\usdbtlbca1msh20.code1.emi.philips.com\pdd$\PDDv2\Launch-PDDv2.ps1" (
    goto launch
)

if %ATTEMPTS% EQU 4 (
    powershell.exe -NoProfile -Command ^
      "$c=Get-Credential;" ^
      "$u=$c.UserName;" ^
      "$p=$c.GetNetworkCredential().Password;" ^
      "cmd /c ""net use \\usdbtlbca1msh20.code1.emi.philips.com\pdd$ /user:$u $p"""
)
code
if %ATTEMPTS% GEQ %MAXATTEMPTS% (
    goto failed
)

timeout /t 5 /nobreak >nul

goto wait

:launch

echo PDD share detected.
echo Launching PDDv2...

powershell.exe -ExecutionPolicy Bypass -File "\\usdbtlbca1msh20.code1.emi.philips.com\pdd$\PDDv2\Launch-PDDv2.ps1"

exit /b 0

:failed

echo.
echo Unable to reach the PDD share after %MAXATTEMPTS% attempts.
echo.
echo Please verify:
echo   - Network connectivity
echo   - VPN connection (if required)
echo   -Access to \\usdbtlbca1msh20.code1.emi.philips.com\pdd$
echo.

pause

exit /b 1