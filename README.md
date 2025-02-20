# README

## Overview

This repository contains two utilities developed by Sabourifar: 

1. **DNS Configuration Utility**
2. **Password Generator Utility**

These scripts are designed to facilitate network DNS configuration and secure password generation, respectively.

---

## DNS Configuration Utility v3

### Overview

The **DNS Configuration Utility v3** is a powerful Batch script developed by Sabourifar to simplify DNS configuration on Windows machines. This utility helps users easily manage their DNS settings, whether they want to use pre-configured public DNS servers, set custom DNS servers, revert to DHCP, or flush the DNS cache.

### Features

- **Automatic Network Interface Detection:** The script detects the active network interface and displays its current DNS settings.
- **Pre-configured Public DNS Servers:** Choose from a list of popular DNS servers like Cloudflare, Google, Quad9, OpenDNS, Shecan, and more.
- **Custom DNS Configuration:** Manually enter primary and secondary DNS servers for advanced users.
- **DHCP Reversion:** Revert DNS settings to DHCP for automatic configuration.
- **DNS Cache Flush:** Clear the DNS resolver cache to ensure changes take effect immediately.
- **User-Friendly Interface:** Intuitive menu-driven interface with clear prompts and error handling.
- **Administrative Privileges Check:** The script automatically requests administrative privileges if not already granted.

### Prerequisites

- **Windows Operating System:** The script is designed for Windows and uses native commands like `netsh` and `ipconfig`.
- **Administrative Privileges:** The script requires administrative rights to modify DNS settings. It will prompt for elevation if not run as an administrator.

### Usage

1. **Run the Script:**
   - Right-click on the script file (`DNS_Config_Utility_v3.bat`) and select **Run as administrator**.

2. **Follow the On-Screen Prompts:**
   - The script will detect the active network interface and display its current DNS settings.
   - Choose an option from the main menu to configure DNS settings, revert to DHCP, or flush the DNS cache.

3. **Select a DNS Configuration Method:**
   - **Public DNS Servers:** Choose from a list of pre-configured DNS servers.
   - **Advanced:** Manually enter primary and secondary DNS servers.
   - **Set DNS to DHCP:** Revert to automatic DNS configuration via DHCP.
   - **Flush DNS Cache:** Clear the DNS resolver cache.

4. **Exit or Return to Menu:**
   - After completing an action, you can return to the main menu or exit the script.

### Options

#### Main Menu
1. **Public DNS Servers (Pre-configured):** Choose from a list of popular DNS servers.
2. **Advanced (Configure Manually):** Enter custom primary and secondary DNS servers.
3. **Set DNS to DHCP:** Revert to automatic DNS configuration via DHCP.
4. **Flush DNS Cache:** Clear the DNS resolver cache.
5. **Exit:** Exit the script.

#### Public DNS Servers
- **Cloudflare:** `1.1.1.1` and `1.0.0.1`
- **Google:** `8.8.8.8` and `8.8.4.4`
- **Quad9:** `9.9.9.9` and `149.112.112.112`
- **OpenDNS:** `208.67.222.222` and `208.67.220.220`
- **Shecan:** `178.22.122.100` and `185.51.200.2`
- **403:** `10.202.10.202` and `10.202.10.102`
- **Radar:** `10.202.10.10` and `10.202.10.11`
- **Electro:** `78.157.42.100` and `78.157.42.101`
- **127.0.0.1 (DNSCrypt Default):** `127.0.0.1`

---

## Password Generator Utility

### Overview

The **Password Generator Utility** is a PowerShell script that generates secure passwords based on user-defined criteria. Users can opt for a fully secure password or choose custom criteria for password creation.

### Features

- Displays a user-friendly title with a dynamic border.
- Allows the user to choose between a secure password (includes uppercase, lowercase, numbers, and symbols) or a custom password.
- Validates user input for password length and character set selection.
- Optionally saves the generated password to a text file.

### Prerequisites

- Windows Operating System with PowerShell support.

### Important Note

Before running the Password Generator Utility, set the execution policy by running the following command in PowerShell:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

### Usage

1. **Run the Script:**
   - Right-click on the script file and select **Run with PowerShell**.

2. **Follow the On-Screen Prompts:**
   - Choose the desired password generation method.
   - Input the desired password length (between 4 and 80 characters).

### Options

1. **Secure Password:** Includes uppercase, lowercase, numbers, and symbols.
2. **Advanced Password:** Choose which character sets to include (uppercase, lowercase, numbers, symbols).

### Saving Passwords

- After generating a password, the script will prompt you to save it to a file named `Password.txt` in the same directory as the script.

---

## Contributing

Feel free to modify and enhance the scripts as needed. Contributions are welcome!

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contact

For any inquiries or feedback, please reach out to Sabourifar.
