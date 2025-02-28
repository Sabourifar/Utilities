# README

## Overview

This repository contains two utilities developed by Sabourifar: 

1. **DNS Configuration Utility**
2. **Password Manager Utility**

These scripts are designed to facilitate network DNS configuration and secure password generation/management, respectively.

---

## DNS Configuration Utility v4

### Overview

The **DNS Configuration Utility v4** is a Batch script developed by Sabourifar to simplify DNS configuration on Windows machines. This utility helps users manage DNS settings with pre-configured public servers, custom configurations, DHCP reversion, or DNS cache flushing.

### Features

- **Automatic Network Interface Detection:** Detects the active network interface and displays current DNS settings.
- **Pre-configured Public DNS Servers:** Options include Cloudflare, Google, Quad9, OpenDNS, and more.
- **Custom DNS Configuration:** Manually set primary and secondary DNS servers.
- **DHCP Reversion:** Revert to automatic DNS settings via DHCP.
- **DNS Cache Flush:** Clear the DNS resolver cache.
- **User-Friendly Interface:** Menu-driven with clear prompts and error handling.
- **Administrative Privileges Check:** Auto-requests elevation if needed.

### Prerequisites

- **Windows Operating System:** Uses native `netsh` and `ipconfig` commands.
- **Administrative Privileges:** Required for DNS modifications; elevation prompted if necessary.

### Usage

1. **Run the Script:**
   - Right-click `DNS_Config_Utility_v4.bat` and select **Run as administrator**.
2. **Follow Prompts:**
   - View active interface and current DNS settings.
   - Choose a configuration method from the menu.
3. **Options:**
   - Select public DNS, set custom servers, revert to DHCP, or flush cache.
4. **Exit or Continue:**
   - Return to the menu or exit after an action.

### Options

#### Main Menu
1. **Public DNS Servers:** Pre-configured options.
2. **Advanced:** Manual DNS entry.
3. **Set DNS to DHCP:** Automatic configuration.
4. **Flush DNS Cache:** Clear the cache.
5. **Exit:** Close the script.

#### Public DNS Servers
- **127.0.0.1 (DNSCrypt Default):** `127.0.0.1`
- **Cloudflare:** `1.1.1.1`, `1.0.0.1`
- **Google:** `8.8.8.8`, `8.8.4.4`
- **Quad9:** `9.9.9.9`, `149.112.112.112`
- **OpenDNS:** `208.67.222.222`, `208.67.220.220`
- **Shecan:** `178.22.122.100`, `185.51.200.2`
- **403:** `10.202.10.202`, `10.202.10.102`
- **Radar:** `10.202.10.10`, `10.202.10.11`
- **Electro:** `78.157.42.100`, `78.157.42.101`

---

## Password Manager Utility v2

### Overview

The **Password Manager Utility v2** is a PowerShell script that generates secure passwords and manages login information. It offers secure or custom password generation with options to save passwords or full login details.

### Features

- **Secure Passwords:** Includes all character types (uppercase, lowercase, numbers, symbols).
- **Custom Passwords:** User selects character types.
- **Login Info Management:** Save passwords with website/title and username.
- **Persistent Interface:** Runs until explicitly exited.
- **File Saving:** Outputs to `Passwords.txt` in the script directory.

### Prerequisites

- **Windows with PowerShell:** Requires PowerShell 5.1 or later.

### Execution Policy

Run this command in PowerShell as Administrator to enable script execution:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

### Usage

1. **Run the Script:**
   - Right-click `Password_Manager_v2.ps1` and select **Run with PowerShell**.
2. **Main Menu:**
   - Choose secure/custom password generation or exit.
3. **Set Length:** Enter 4-80 characters.
4. **Action Menu:**
   - Generate another, save password/login info, return to menu, or exit.

### Options

#### Main Menu
1. **Secure Password:** All character types included.
2. **Custom Password:** Choose character sets.
3. **Exit:** Close the script.

#### Action Menu
1. **Generate Another:** Create a new password.
2. **Save Password:** Save to `Passwords.txt`.
3. **Save Login Info:** Include website/title and username.
4. **Main Menu:** Return to initial menu.
5. **Exit:** Close the script.

---

## Contributing

Feel free to modify and enhance the scripts. Contributions are welcome!

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contact

For inquiries or feedback, reach out to Sabourifar.
