@echo off
setlocal enabledelayedexpansion

:: Check for administrator privileges
:: Attempt to access a system directory that requires admin rights
fsutil dirty query %systemdrive% >nul 2>&1
if '%errorlevel%' NEQ '0' (
    echo  == Requesting administrative privileges...
    echo.

    :: Re-run the script with administrator privileges
    powershell -command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Set title
title DNS Configuration Utility by Sabourifar

:: Display header
echo ======================================= DNS Configuration Utility by Sabourifar ========================================
echo.

echo  == Detecting the active network interface...
echo.

:: Get the active network interface name
for /f "delims=" %%i in ('powershell -command "Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceType -ne 'Loopback' } | Select-Object -ExpandProperty Name"') do (
    set "interface=%%i"
)

:: Check if a network interface is found
if not defined interface (
    echo No active network interface found
    pause
    exit /b
)

echo   ==== Active network interface: %interface%
echo.

:: Display current DNS settings using PowerShell
for /f "tokens=*" %%a in ('powershell -command "Get-DnsClientServerAddress -InterfaceAlias '%interface%' -AddressFamily IPv4 | Select-Object -ExpandProperty ServerAddresses"') do (
    if not defined primary_dns (
        set "primary_dns=%%a"
    ) else if not defined secondary_dns (
        set "secondary_dns=%%a"
    )
)

if defined primary_dns (
    echo   ==== Primary DNS: %primary_dns%
) else (
    echo   ==== Primary DNS: Not Configured
)
echo.

if defined secondary_dns (
    echo   ==== Secondary DNS: %secondary_dns%
) else (
    echo   ==== Secondary DNS: Not Configured
)

echo.
echo.

:main_menu
:: Ask the user for DNS configuration method
echo Select a DNS configuration method:
echo.
echo 1. Public DNS Servers (Pre Configured)
echo 2. Advanced (Configure Yourself)
echo 3. Set DNS to DHCP
echo 4. Flush DNS Cache
echo.
set /p "choice=Enter your choice: "

if "%choice%" == "1" (
    goto choose_dns
) else if "%choice%" == "2" (
    goto advanced_dns
) else if "%choice%" == "3" (
    goto set_dhcp
) else if "%choice%" == "4" (
    goto flush_dns
) else (
    echo Invalid selection, please try again.
    echo.
    goto main_menu
)

:set_dhcp
echo.
echo == Setting DNS to DHCP...
echo.
netsh interface ipv4 set dns name="%interface%" source=dhcp >nul
echo   ==== DNS has been set to DHCP successfully.
echo.

:: Flush DNS after setting DHCP
goto flush_dns

:choose_dns
echo.
echo Select a Public DNS Server:
echo.
echo 1. Cloudflare
echo 2. Google
echo 3. Quad9
echo 4. OpenDNS
echo 5. Shecan
echo 6. 403
echo 7. Radar
echo 8. Electro
echo.
set /p "dnschoice=Enter your choice: "

if "%dnschoice%" == "1" (
    set NAME=Cloudflare
    set DNS1=1.1.1.1
    set DNS2=1.0.0.1
) else if "%dnschoice%" == "2" (
    set NAME=Google
    set DNS1=8.8.8.8
    set DNS2=8.8.4.4
) else if "%dnschoice%" == "3" (
    set NAME=Quad9
    set DNS1=9.9.9.9
    set DNS2=149.112.112.112
) else if "%dnschoice%" == "4" (
    set NAME=OpenDNS
    set DNS1=208.67.222.222
    set DNS2=208.67.220.220
) else if "%dnschoice%" == "5" (
    set NAME=Shecan
    set DNS1=178.22.122.100
    set DNS2=185.51.200.2
) else if "%dnschoice%" == "6" (
    set NAME=403
    set DNS1=10.202.10.202
    set DNS2=10.202.10.102
) else if "%dnschoice%" == "7" (
    set NAME=Radar
    set DNS1=10.202.10.10
    set DNS2=10.202.10.11
) else if "%dnschoice%" == "8" (
    set NAME=Electro
    set DNS1=78.157.42.100
    set DNS2=78.157.42.101
) else (
    echo Invalid selection, please try again.
    echo.
    goto choose_dns
)

goto apply_dns

:advanced_dns
echo.
set NAME=Custom
set /p "DNS1=Enter the Primary DNS server: "
echo.
set /p "DNS2=Enter the Secondary DNS server: "
goto apply_dns

:apply_dns
echo.
echo == Applying DNS settings...
echo.

:: Set DNS
netsh interface ipv4 set dns name="%interface%" static %DNS1% primary >nul
netsh interface ipv4 add dns name="%interface%" %DNS2% index=2 >nul

echo   ==== DNS servers have been configured successfully
echo.
echo    ====== DNS Name: %NAME%
echo.
echo    ====== Primary DNS: %DNS1%
echo.
echo    ====== Secondary DNS: %DNS2%
echo.

goto flush_dns

:flush_dns
echo.
echo == Clearing DNS cache...
echo.

:: Flush DNS cache
ipconfig /flushdns >nul

echo   ==== Successfully cleared the DNS resolver cache
echo.
echo.

call :ask_menu_or_exit

:ask_menu_or_exit
echo Press 1 to return to the main menu or 0 to exit.
echo.
set /p "userchoice=Enter your choice: "
echo.

if "%userchoice%" == "1" (
    goto main_menu
) else if "%userchoice%" == "0" (
    exit
) else (
    echo Invalid selection, please try again.
    echo.
    goto ask_menu_or_exit
)