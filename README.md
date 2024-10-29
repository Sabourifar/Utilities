Here’s a README file for the two provided scripts, outlining their purpose, usage, and functionality:

---

# README

## Overview

This repository contains two utilities developed by Sabourifar: 

1. **DNS Configuration Utility** (Batch Script)
2. **Password Generator Utility** (PowerShell Script)

These scripts are designed to facilitate network DNS configuration and secure password generation, respectively.

---

## Script 1: DNS Configuration Utility

### Description

The **DNS Configuration Utility** is a Batch script that helps users configure DNS settings on their Windows machine. The script provides options to set public DNS servers, revert to DHCP, or flush the DNS cache.

### Features
- Detects the active network interface.
- Displays current DNS settings.
- Offers options to set public DNS servers (Cloudflare, Google, Quad9, etc.), configure custom DNS settings, or revert to DHCP.
- Flushes the DNS cache after changes are made.

### Prerequisites
- Windows Operating System
- Administrative privileges (the script requests these if not already granted).

### Usage

1. **Run the Script:**
   - Right-click on the script and select **Run as administrator**.

2. **Follow the On-Screen Prompts:**
   - The script will display the active network interface and current DNS settings.
   - Choose one of the available options by entering the corresponding number.

### Options
1. **Public DNS Servers (Pre-configured)**
2. **Advanced (Configure Yourself)**
3. **Set DNS to DHCP**
4. **Flush DNS Cache**

---

## Script 2: Password Generator Utility

### Description

The **Password Generator Utility** is a PowerShell script that generates secure passwords based on user-defined criteria. Users can opt for a fully secure password or choose custom criteria for password creation.

### Features
- Displays a user-friendly title with a dynamic border.
- Allows the user to choose between a secure password (includes uppercase, lowercase, numbers, and symbols) or a custom password.
- Validates user input for password length and character set selection.
- Optionally saves the generated password to a text file.

### Prerequisites
- Windows Operating System with PowerShell support.

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

