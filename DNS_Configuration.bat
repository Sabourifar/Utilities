@echo off
setlocal enabledelayedexpansion

:: Check for administrator privileges and request elevation if needed
NET FILE >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo  == Requesting Administrative Privileges...
    powershell -noprofile -command "Start-Process '%~f0' -Verb RunAs" >nul
    exit /b
)

:: Set the window title
title DNS Configuration Utility v4 By Sabourifar

:: Define constants for UI elements and PowerShell command prefix
set "line_sep========================================================================================================================="
set "double_eq=  == "
set "quad_eq=  ==== "
set "pscmd=powershell -noprofile -command"

:: Display the initial title
echo ====================================== DNS Configuration Utility v4 By Sabourifar ======================================
echo.
echo %double_eq%Detecting Active Network Interface...
echo.

:: Detect the active network interface using PowerShell
set "interface="
for /f "delims=" %%i in (
    '!pscmd! "(Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1).Name"'
) do set "interface=%%i"

:: Handle case where no active interface is found
if not defined interface (
    echo %quad_eq%No Active Network Interface Found
    echo.
    goto no_interface_menu
)

:: Confirm the detected interface
echo %quad_eq%Active Network Interface: %interface%
echo.

:: Retrieve current DNS settings for the interface
set "primary_dns=" & set "secondary_dns="
for /f "tokens=1,2" %%a in (
    '!pscmd! "@(Get-DnsClientServerAddress -InterfaceAlias '%interface%' -AddressFamily IPv4 | %%{ $_.ServerAddresses }) -join ' '"'
) do set "primary_dns=%%a" & set "secondary_dns=%%b"

:: Show current DNS configuration
if defined primary_dns (
    echo %quad_eq%Primary DNS: !primary_dns!
) else (
    echo %quad_eq%Primary DNS: Not Configured
)
echo.

if defined secondary_dns (
    echo %quad_eq%Secondary DNS: !secondary_dns!
) else (
    echo %quad_eq%Secondary DNS: Not Configured
)
echo.

:main_menu
:: Display main menu and get user input
set "choice="
echo %line_sep%
echo.
echo  # Select DNS Configuration Method
echo.
echo  1. Public DNS Servers (Pre Configured)
echo  2. Advanced (Configure Manually)
echo  3. Set DNS To DHCP
echo  4. Flush DNS Cache
echo  5. Exit
echo.
set /p "choice=Enter Your Choice: "

:: Process main menu selection
if "%choice%"=="" goto invalid_main
if "%choice%"=="1" goto :choice_1
if "%choice%"=="2" goto :choice_2
if "%choice%"=="3" goto :choice_3
if "%choice%"=="4" goto :choice_4
if "%choice%"=="5" exit

:invalid_main
:: Handle invalid main menu input
echo %line_sep%
echo.
echo  Invalid Selection, Please Try Again.
echo.
goto main_menu

:no_interface_menu
:: Display limited menu when no interface is detected
set "choice="
echo %line_sep%
echo.
echo  # Only Flush DNS Cache is Available - Connect to a Network to Configure DNS
echo.
echo  1. Flush DNS Cache
echo  2. Exit
echo.
set /p "choice=Enter Your Choice: "

:: Process no-interface menu selection
if "%choice%"=="" goto invalid_no_interface
if "%choice%"=="1" goto :flush_dns
if "%choice%"=="2" exit

:invalid_no_interface
:: Handle invalid input in no-interface menu
echo %line_sep%
echo.
echo  Invalid Selection, Please Try Again.
echo.
goto no_interface_menu

:choice_1
:: Call preconfigured DNS selection subroutine
call :choose_dns
goto :exit_menu

:choice_2
:: Call manual DNS configuration subroutine
call :advanced_dns
goto :exit_menu

:choice_3
:: Call DHCP DNS setting subroutine
call :set_dhcp
goto :exit_menu

:choice_4
:: Call DNS cache flush subroutine
call :flush_dns
goto :exit_menu

:set_dhcp
:: Set DNS to obtain automatically via DHCP and flush cache
echo %line_sep%
echo.
echo %double_eq%Setting DNS To DHCP...
echo.
netsh interface ipv4 set dns name="%interface%" source=dhcp >nul
echo %quad_eq%DNS Has Been Set To DHCP Successfully.
goto flush_dns

:choose_dns
:: Display preconfigured DNS options and get user selection
:retry_dns
set "dnschoice="
echo %line_sep%
echo.
echo  # Select Public DNS Server
echo.
echo  0. 127.0.0.1 (DNSCrypt Default)
echo  1. Cloudflare
echo  2. Google
echo  3. Quad9
echo  4. OpenDNS
echo  5. Shecan
echo  6. 403
echo  7. Radar
echo  8. Electro
echo.
set /p "dnschoice=Enter Your Choice: "

:: Map user choice to DNS settings
set "NAME=" & set "DNS1=" & set "DNS2="
for %%A in (
    "0=127.0.0.1 (DNSCrypt Default)=127.0.0.1="
    "1=Cloudflare=1.1.1.1=1.0.0.1"
    "2=Google=8.8.8.8=8.8.4.4"
    "3=Quad9=9.9.9.9=149.112.112.112"
    "4=OpenDNS=208.67.222.222=208.67.220.220"
    "5=Shecan=178.22.122.100=185.51.200.2"
    "6=403=10.202.10.202=10.202.10.102"
    "7=Radar=10.202.10.10=10.202.10.11"
    "8=Electro=78.157.42.100=78.157.42.101"
) do for /f "tokens=1-4 delims==" %%B in (%%A) do if "%%B" == "%dnschoice%" (
    set "NAME=%%C" & set "DNS1=%%D" & set "DNS2=%%E"
)

if not defined NAME goto invalid_dns
goto apply_dns

:invalid_dns
:: Handle invalid DNS selection
echo %line_sep%
echo.
echo  Invalid Selection, Please Try Again.
goto retry_dns

:advanced_dns
:: Prompt for custom DNS server addresses
echo %line_sep%
echo.
:get_primary
set "DNS1="
set /p "DNS1=Enter The Primary DNS Server: "
if not defined DNS1 (
    echo %line_sep%
    echo.
    echo  Please Enter A Valid Primary DNS Server.
    echo.
    goto get_primary
)

set "DNS2="
set /p "DNS2=Enter The Secondary DNS Server (Optional): "
set "NAME=Custom"

:apply_dns
:: Apply the selected or entered DNS settings to the interface
echo %line_sep%
echo.
echo %double_eq%Applying DNS Settings...
echo.
netsh interface ipv4 set dns name="%interface%" static %DNS1% primary >nul
if defined DNS2 if "%DNS2%" NEQ "" (
    netsh interface ipv4 add dns name="%interface%" %DNS2% index=2 >nul
)

echo %quad_eq%DNS Name: %NAME%
echo.
echo %quad_eq%Primary DNS: %DNS1%
echo.
if defined DNS2 if "%DNS2%" NEQ "" (
    echo %quad_eq%Secondary DNS: %DNS2%
) else (
    echo %quad_eq%Secondary DNS: Not Configured
)

:flush_dns
:: Clear the DNS cache
echo %line_sep%
echo.
echo %double_eq%Clearing DNS Cache...
echo.
ipconfig /flushdns >nul
echo %quad_eq%Successfully Cleared DNS Resolver Cache.
echo %line_sep%
echo.

:exit_menu
:: Offer options to return to menu or exit
set "userchoice="
echo  Press 1 To Return To Previous Menu Or 0 To Exit.
echo.
set /p "userchoice=Enter Your Choice: "
echo.

:: Process exit menu choice
if "%userchoice%"=="1" (
    if not defined interface (
        goto no_interface_menu
    ) else (
        goto main_menu
    )
)
if "%userchoice%"=="0" exit

:: Handle invalid exit menu input
echo %line_sep%
echo.
echo  Invalid Selection, Please Try Again.
echo %line_sep%
echo.
goto exit_menu
