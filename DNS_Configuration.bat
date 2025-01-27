@echo off
setlocal enabledelayedexpansion

:: Administrator Privileges Check
NET FILE >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo  == Requesting Administrative Privileges...
    echo.
    powershell -noprofile -command "Start-Process '%~f0' -Verb RunAs" >nul
    exit /b
)

title DNS Configuration Utility By Sabourifar

echo ======================================= DNS Configuration Utility By Sabourifar ========================================
echo.
echo  == Detecting Active Network Interface...
echo.

:: Get Active Network Interface
set "interface="
for /f "delims=" %%i in (
    'powershell -noprofile -command "(Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1).Name"'
) do (
    set "interface=%%i"
)

if not defined interface (
    echo   ==== No Active Network Interface Found
    echo.
    echo ========================================================================================================================
    echo.
    
    pause
    exit /b
)

echo   ==== Active Network Interface: %interface%
echo.

:: Get Current DNS Settings
set "primary_dns=" & set "secondary_dns="
for /f "tokens=1,2" %%a in (
    'powershell -noprofile -command "@(Get-DnsClientServerAddress -InterfaceAlias '%interface%' -AddressFamily IPv4 | %%{ $_.ServerAddresses }) -join ' '"'
) do (
    set "primary_dns=%%a"
    set "secondary_dns=%%b"
)

:: Display Current DNS Configuration
if defined primary_dns (
    echo   ==== Primary DNS: !primary_dns!
) else (
    echo   ==== Primary DNS: Not Configured
)

echo.

if defined secondary_dns (
    echo   ==== Secondary DNS: !secondary_dns!
) else (
    echo   ==== Secondary DNS: Not Configured
)

echo.

:main_menu
:: Main Program Menu
set "choice="
echo ========================================================================================================================
echo.
echo  # Select DNS Configuration Method
echo.
echo  1. Public DNS Servers (Pre Configured)
echo  2. Advanced (Configure Manually)
echo  3. Set DNS To DHCP
echo  4. Flush DNS Cache
echo.
set /p "choice=Enter Your Choice: "

if not defined choice goto main_menu
if "%choice%" geq "1" if "%choice%" leq "4" goto :choice_%choice%

echo.
echo ========================================================================================================================
echo.
echo  Invalid Selection, Please Try Again.
echo.
goto main_menu

:choice_1
call :choose_dns
goto :eof

:choice_2
call :advanced_dns
goto :eof

:choice_3
call :set_dhcp
goto :eof

:choice_4
call :flush_dns
goto :eof

:set_dhcp
echo.
echo ========================================================================================================================
echo.
echo  == Setting DNS To DHCP...
echo.
netsh interface ipv4 set dns name="%interface%" source=dhcp >nul
echo   ==== DNS Has Been Set To DHCP Successfully.
goto flush_dns

:choose_dns
:: Preconfigured DNS Selection Menu
set "dnschoice="
echo.
echo ========================================================================================================================
echo.
echo  # Select Public DNS Server
echo.
echo  1. Cloudflare
echo  2. 127.0.0.1 (DNSCrypt Default)
echo  3. Google
echo  4. Quad9
echo  5. OpenDNS
echo  6. Shecan
echo  7. 403
echo  8. Radar
echo  9. Electro
echo.
set /p "dnschoice=Enter Your Choice: "

set "NAME=" & set "DNS1=" & set "DNS2="
for %%A in (
    "1=Cloudflare=1.1.1.1=1.0.0.1"
    "2=127.0.0.1 (DNSCrypt Default)=127.0.0.1="
    "3=Google=8.8.8.8=8.8.4.4"
    "4=Quad9=9.9.9.9=149.112.112.112"
    "5=OpenDNS=208.67.222.222=208.67.220.220"
    "6=Shecan=178.22.122.100=185.51.200.2"
    "7=403=10.202.10.202=10.202.10.102"
    "8=Radar=10.202.10.10=10.202.10.11"
    "9=Electro=78.157.42.100=78.157.42.101"
) do (
    for /f "tokens=1-4 delims==" %%B in (%%A) do (
        if "%%B" == "%dnschoice%" (
            set "NAME=%%C"
            set "DNS1=%%D"
            set "DNS2=%%E"
        )
    )
)

if not defined NAME (
    echo.
    echo ========================================================================================================================
    echo.
    echo  Invalid Selection, Please Try Again.
    goto choose_dns
)
goto apply_dns

:advanced_dns
:: Custom DNS Configuration
echo.
echo ========================================================================================================================
echo.
:get_primary
set "DNS1="
set /p "DNS1=Enter The Primary DNS Server: "
if not defined DNS1 (
    echo.
    echo ========================================================================================================================
    echo.
    echo  Please Enter A Valid Primary DNS Server.
    echo.
    echo ========================================================================================================================
    echo.
    goto get_primary
)

echo.

set "DNS2="
set /p "DNS2=Enter The Secondary DNS Server (Optional): "
set "NAME=Custom"

:apply_dns
:: Apply DNS Settings
echo.
echo ========================================================================================================================
echo.
echo  == Applying DNS Settings...
echo.
netsh interface ipv4 set dns name="%interface%" static %DNS1% primary >nul
if defined DNS2 (
    if "%DNS2%" NEQ "" (
        netsh interface ipv4 add dns name="%interface%" %DNS2% index=2 >nul
    )
)

echo   ==== DNS Name: %NAME%
echo.
echo   ==== Primary DNS: %DNS1%
echo.
if defined DNS2 (
    if "%DNS2%" NEQ "" (
        echo   ==== Secondary DNS: %DNS2%
    ) else (
        echo   ==== Secondary DNS: Not Configured
    )
) else (
    echo   ==== Secondary DNS: Not Configured
)

:flush_dns
:: Flush DNS Cache
echo.
echo ========================================================================================================================
echo.
echo  == Clearing DNS Cache...
echo.
ipconfig /flushdns >nul
echo   ==== Successfully Cleared DNS Resolver Cache.
echo.
echo ========================================================================================================================
echo.

:exit_menu
:: Exit Or Return To Menu
set "userchoice="
echo  Press 1 To Return To Main Menu Or 0 To Exit.
echo.
set /p "userchoice=Enter Your Choice: "
echo.

if "%userchoice%"=="1" goto main_menu
if "%userchoice%"=="0" exit

echo ========================================================================================================================
echo.
echo  Invalid Selection, Please Try Again.
echo.
echo ========================================================================================================================
echo.
goto exit_menu
