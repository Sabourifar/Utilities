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
title DNS Configuration Utility v6 By Sabourifar

:: Define constants for UI elements and PowerShell command prefix
set "line_sep========================================================================================================================="
set "double_eq=  == "
set "quad_eq=  ==== "
set "pscmd=powershell -noprofile -command"
set "invalid_msg=Invalid Selection, Please Try Again."

:: Define message variables for consistency
set "applying_msg=Applying DNS Settings"
set "clearing_msg=Clearing DNS Cache"
set "cleared_msg=Successfully Cleared DNS Resolver Cache"

:: Define DNS provider database (Name=Primary=Secondary)
set "dns_providers[1]=Cloudflare=1.1.1.1=1.0.0.1"
set "dns_providers[2]=Google=8.8.8.8=8.8.4.4"
set "dns_providers[3]=Quad9=9.9.9.9=149.112.112.112"
set "dns_providers[4]=OpenDNS=208.67.222.222=208.67.220.220"
set "dns_providers[5]=UltraDNS=64.6.64.6=64.6.65.6"
set "dns_providers[6]=UltraDNS2=156.154.70.2=156.154.71.2"
set "dns_providers[7]=NTT=129.250.35.250=129.250.35.251"
set "dns_providers[8]=Shecan=178.22.122.100=185.51.200.2"
set "dns_providers[9]=Begzar=185.55.226.26=185.55.225.25"
set "dns_providers[10]=Radar=10.202.10.10=10.202.10.11"
set "dns_providers[11]=Electro=78.157.42.100=78.157.42.101"
set "dns_providers[12]=DNSCrypt=127.0.0.1="
set "dns_count=12"

:: Display the initial title
echo ====================================== DNS Configuration Utility v6 By Sabourifar ======================================
echo.

:: Detect and display DNS configuration
call :detect_and_show_dns
if not defined interface goto no_interface_menu

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
echo  5. Current DNS Configuration
echo  0. Exit
echo.
set /p "choice=Enter Your Choice: "
echo.

:: Process main menu selection
if "%choice%"=="" goto invalid_main
if "%choice%"=="1" goto :choice_1
if "%choice%"=="2" goto :choice_2
if "%choice%"=="3" goto :choice_3
if "%choice%"=="4" goto :choice_4
if "%choice%"=="5" goto :choice_5
if "%choice%"=="0" exit

:invalid_main
:: Handle invalid main menu input
echo %line_sep%
echo.
echo  %invalid_msg%
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
echo  0. Exit
echo.
set /p "choice=Enter Your Choice: "
echo.

:: Process no-interface menu selection
if "%choice%"=="" goto invalid_no_interface
if "%choice%"=="1" goto :flush_dns
if "%choice%"=="0" exit

:invalid_no_interface
:: Handle invalid input in no-interface menu
echo %line_sep%
echo.
echo  %invalid_msg%
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

:choice_5
:: Current DNS configuration with proper formatting
echo %line_sep%
echo.
call :detect_and_show_dns
echo %line_sep%
echo.
goto :exit_menu

:detect_and_show_dns
:: Unified routine for detecting and displaying DNS configuration
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
    exit /b
)

:: Confirm the detected interface
echo %quad_eq%Active Network Interface: %interface%
echo.

:: Check if DNS is set to DHCP
set "is_dhcp=0"
for /f "tokens=*" %%a in ('netsh interface ipv4 show dnsservers "%interface%" ^| findstr /i "dhcp"') do set "is_dhcp=1"

:: Retrieve current DNS settings for the interface
set "primary_dns=" & set "secondary_dns="
for /f "tokens=1,2" %%a in (
    '!pscmd! "@(Get-DnsClientServerAddress -InterfaceAlias '%interface%' -AddressFamily IPv4 | %%{ $_.ServerAddresses }) -join ' '"'
) do set "primary_dns=%%a" & set "secondary_dns=%%b"

:: If DNS is set to DHCP, show DHCP as the DNS name
if !is_dhcp! EQU 1 (
    echo %quad_eq%DNS Name: DHCP
    echo %quad_eq%Primary DNS: %primary_dns%
    if defined secondary_dns (
        echo %quad_eq%Secondary DNS: %secondary_dns%
    ) else (
        echo %quad_eq%Secondary DNS: Not Configured
    )
    echo.
    exit /b
)

:: Look up DNS provider names
set "primary_name=Unknown"
set "secondary_name=Unknown"
set "both_same_provider=0"

:: Check if both DNS match a single provider
for /l %%i in (1,1,%dns_count%) do (
    for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
        if "!primary_dns!"=="%%b" if "!secondary_dns!"=="%%c" (
            set "primary_name=%%a"
            set "secondary_name=%%a"
            set "both_same_provider=1"
        )
    )
)

:: If not both from same provider, check individually
if !both_same_provider! EQU 0 (
    :: Check primary DNS
    for /l %%i in (1,1,%dns_count%) do (
        for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
            if "!primary_dns!"=="%%b" set "primary_name=%%a"
            if "!primary_dns!"=="%%c" set "primary_name=%%a"
        )
    )
    
    :: Check secondary DNS
    for /l %%i in (1,1,%dns_count%) do (
        for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
            if "!secondary_dns!"=="%%b" set "secondary_name=%%a"
            if "!secondary_dns!"=="%%c" set "secondary_name=%%a"
        )
    )
)

:: Display DNS configuration based on recognition results
if !both_same_provider! EQU 1 (
    :: Both DNS from same provider
    echo %quad_eq%DNS Name: !primary_name!
    echo %quad_eq%Primary DNS: !primary_dns!
    if defined secondary_dns (
        echo %quad_eq%Secondary DNS: !secondary_dns!
    ) else (
        echo %quad_eq%Secondary DNS: Not Configured
    )
) else (
    :: Different providers or unknown
    if defined primary_dns (
        if "!primary_name!" NEQ "Unknown" (
            echo %quad_eq%Primary DNS Name: !primary_name!
        )
        echo %quad_eq%Primary DNS: !primary_dns!
    ) else (
        echo %quad_eq%Primary DNS: Not Configured
    )
    echo.
    if defined secondary_dns (
        if "!secondary_name!" NEQ "Unknown" (
            echo %quad_eq%Secondary DNS Name: !secondary_name!
        )
        echo %quad_eq%Secondary DNS: !secondary_dns!
    ) else (
        echo %quad_eq%Secondary DNS: Not Configured
    )
)
echo.
exit /b

:set_dhcp
:: Set DNS to obtain automatically via DHCP and flush cache
echo %line_sep%
echo.
echo %double_eq%!applying_msg!...
echo.
netsh interface ipv4 set dns name="%interface%" source=dhcp >nul

:: Show the updated DNS configuration
call :detect_and_show_dns

:: Add line separator before clearing DNS cache
echo %line_sep%
echo.

:: Flush DNS cache
echo %double_eq%!clearing_msg!...
echo.
ipconfig /flushdns >nul
echo %quad_eq%!cleared_msg!.
echo.
echo %line_sep%
echo.
exit /b

:choose_dns
:: Display preconfigured DNS options and get user selection
:retry_dns
set "dnschoice="
echo %line_sep%
echo.
echo  # Select Public DNS Server
echo.
echo  1. Cloudflare
echo  2. Google
echo  3. Quad9
echo  4. OpenDNS
echo  5. UltraDNS
echo  6. UltraDNS2
echo  7. NTT
echo  8. Shecan
echo  9. Begzar
echo  10. Radar
echo  11. Electro
echo  12. DNSCrypt
echo  0. Return to menu
echo.
set /p "dnschoice=Enter Your Choice: "
echo.

:: Map user choice to DNS settings using the provider database
set "NAME=" & set "DNS1=" & set "DNS2="
if "%dnschoice%"=="0" goto main_menu

:: Convert input to number and validate
set /a num=dnschoice 2>nul
if errorlevel 1 goto invalid_dns
if !num! lss 1 goto invalid_dns
if !num! gtr %dns_count% goto invalid_dns

for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%dnschoice%]!") do (
    set "NAME=%%a"
    set "DNS1=%%b"
    set "DNS2=%%c"
)

goto apply_dns

:invalid_dns
:: Handle invalid DNS selection
echo %line_sep%
echo.
echo  %invalid_msg%
echo.
goto retry_dns

:advanced_dns
:: Prompt for custom DNS server addresses with validation
echo %line_sep%
echo.
:get_primary
set "DNS1="
set /p "DNS1=Enter The Primary DNS Server: "
echo.

:: Validate primary DNS
if not defined DNS1 (
    echo %line_sep%
    echo.
    echo  Invalid DNS Format. Please Enter A Valid IP Address ^(Format: X.X.X.X^)
    echo.
    goto get_primary
)

call :validate_ip "!DNS1!"
if !ERRORLEVEL! NEQ 0 (
    echo %line_sep%
    echo.
    echo  Invalid DNS Format. Please Enter A Valid IP Address ^(Format: X.X.X.X^)
    echo.
    goto get_primary
)

:get_secondary
set "DNS2="
set /p "DNS2=Enter The Secondary DNS Server (Optional): "
echo.

:: Validate secondary DNS if provided
if defined DNS2 if "!DNS2!" NEQ "" (
    call :validate_ip "!DNS2!"
    if !ERRORLEVEL! NEQ 0 (
        echo %line_sep%
        echo.
        echo  Invalid DNS Format. Please Enter A Valid IP Address ^(Format: X.X.X.X^)
        echo.
        goto get_secondary
    )
)

:: Check if entered DNS matches known providers
set "custom_name="
set "found_provider=0"

:: Check if both match a provider
for /l %%i in (1,1,%dns_count%) do (
    for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
        if "!DNS1!"=="%%b" if "!DNS2!"=="%%c" (
            set "custom_name=%%a"
            set "found_provider=1"
        )
    )
)

if !found_provider! EQU 1 (
    set "NAME=!custom_name! (Manual)"
) else (
    set "NAME=Custom"
)

goto apply_dns

:validate_ip
:: Validate IP address format (X.X.X.X where each X is 0-255)
set "ip=%~1"
set "valid=1"

:: Check if it has exactly 3 dots
for /f "tokens=1-4 delims=." %%a in ("!ip!") do (
    set "oct1=%%a"
    set "oct2=%%b"
    set "oct3=%%c"
    set "oct4=%%d"
)

if not defined oct4 set "valid=0"
if not defined oct3 set "valid=0"
if not defined oct2 set "valid=0"
if not defined oct1 set "valid=0"

:: Check each octet
if !valid! EQU 1 (
    for %%o in (!oct1! !oct2! !oct3! !oct4!) do (
        :: Check if it's a number
        echo %%o| findstr /r "^[0-9]*$" >nul
        if !ERRORLEVEL! NEQ 0 set "valid=0"
        :: Check range 0-255
        if %%o LSS 0 set "valid=0"
        if %%o GTR 255 set "valid=0"
        :: Check for leading zeros
        if "%%o" NEQ "0" if "%%o" GEQ "00" if "%%o" LEQ "09" set "valid=0"
    )
)

if !valid! EQU 0 (
    exit /b 1
) else (
    exit /b 0
)

:apply_dns
:: Apply the selected or entered DNS settings to the interface
echo %line_sep%
echo.
echo %double_eq%!applying_msg!...
echo.
netsh interface ipv4 set dns name="%interface%" static %DNS1% primary >nul
if defined DNS2 if "%DNS2%" NEQ "" (
    netsh interface ipv4 add dns name="%interface%" %DNS2% index=2 >nul
)

:: Show the updated DNS configuration
call :detect_and_show_dns

:: Add line separator before clearing DNS cache
echo %line_sep%
echo.

:: Flush DNS cache
echo %double_eq%!clearing_msg!...
echo.
ipconfig /flushdns >nul
echo %quad_eq%!cleared_msg!.
echo.
echo %line_sep%
echo.
exit /b

:flush_dns
:: Clear the DNS cache with consistent formatting
echo %line_sep%
echo.
echo %double_eq%!clearing_msg!...
echo.
ipconfig /flushdns >nul
echo %quad_eq%!cleared_msg!.
echo.
echo %line_sep%
echo.

:exit_menu
:: Offer options to return to menu or exit
set "userchoice="
echo  1. Return to menu
echo  0. Exit
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
echo  %invalid_msg%
echo.
echo %line_sep%
echo.
goto exit_menu
