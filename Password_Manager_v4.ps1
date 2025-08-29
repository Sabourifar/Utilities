<#
=======================================================================================================================
                                       Password Manager Utility v4 By Sabourifar
=======================================================================================================================

DESCRIPTION:
This script provides a secure password generation and management tool. It allows
users to generate strong passwords, customize character sets, and save passwords
or login information to a file.

PREREQUISITES:
- PowerShell 5.1 or later.
- Administrative privileges are not required, but the script must be allowed to run.

EXECUTION POLICY:
By default, PowerShell restricts the execution of scripts for security reasons.
If this script fails to run due to the execution policy, follow these steps:

1. Open PowerShell as Administrator.
2. Run the following command to allow script execution for the current user:
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

This command ensures that only signed scripts from trusted sources are executed,
while allowing locally created scripts (like this one) to run.

=========================================================================================================================
#>

function PasswordManager {
    # Define constants for separator line and title formatting
    $line_sep = '=' * 120
    $title = " Password Manager Utility v4 By Sabourifar "
    $left_equals = 38
    $right_equals = 39
    $title_line = ('=' * $left_equals) + $title + ('=' * $right_equals)

    # Define character sets for password generation
    $UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $LOWERCASE = "abcdefghijklmnopqrstuvwxyz"
    $NUMBERS = "0123456789"
    $SYMBOLS = "~``!@#$%^&*()-_=+{}[];:'""\|,.<>/?"

    # Track if this is the first run to control initial spacing
    $firstRun = $true

    # Display the title in cyan
    Write-Host $title_line -ForegroundColor Cyan
    Write-Host ""

    # Main loop to keep the program running until exit
    :mainloop while ($true) {
        # Add spacing only after the first iteration
        if (-not $firstRun) {
            Write-Host ""
        }
        
        # Display the main menu options
        Write-Host " # Select Configuration Method"
        Write-Host ""
        Write-Host " 1. Secure Password (Recommended)"
        Write-Host " 2. Custom Password"
        Write-Host " 0. Exit"
        Write-Host ""
        
        # Prompt for and validate main menu choice (0, 1, or 2)
        do {
            Write-Host "Enter Your Choice: " -NoNewline -ForegroundColor White
            $choice = Read-Host
            Write-Host ""
            if ($choice -notmatch '^[012]$') {
                Write-Host $line_sep -ForegroundColor White
                Write-Host ""
                Write-Host "  ==== Invalid Choice! Please select 0, 1, or 2." -ForegroundColor Red
                Write-Host ""
                Write-Host $line_sep -ForegroundColor White
                Write-Host ""
            }
        } while ($choice -notmatch '^[012]$')

        # Mark that the first run has completed
        $firstRun = $false

        # Exit the script if user selects option 0
        if ($choice -eq '0') { break }

        # Prompt for and validate password length (4-80)
        while ($true) {
            Write-Host "Enter Password Length (4-80): " -NoNewline -ForegroundColor White
            $input = Read-Host
            Write-Host ""
            try {
                $length = [int]$input
                if ($length -ge 4 -and $length -le 80) {
                    break
                } else {
                    Write-Host $line_sep -ForegroundColor White
                    Write-Host ""
                    Write-Host "  ==== Invalid Length! Please enter a number between 4 and 80." -ForegroundColor Red
                    Write-Host ""
                    Write-Host $line_sep -ForegroundColor White
                    Write-Host ""
                }
            } catch {
                Write-Host $line_sep -ForegroundColor White
                Write-Host ""
                Write-Host "  ==== Invalid Input! Please enter a numeric value." -ForegroundColor Red
                Write-Host ""
                Write-Host $line_sep -ForegroundColor White
                Write-Host ""
            }
        }

        # Set up character pool and requirements based on user choice
        if ($choice -eq '1') {
            # Secure mode: Include all character types
            $charPool = $UPPERCASE + $LOWERCASE + $NUMBERS + $SYMBOLS
            $requirements = @($true, $true, $true, $true)
        }
        else {
            # Custom mode: Prompt for character types until at least one is selected
            do {
                $requirements = @(
                    (Get-YesNo "Include Uppercase Letters?"),
                    (Get-YesNo "Include Lowercase Letters?"),
                    (Get-YesNo "Include Numbers?"),
                    (Get-YesNo "Include Symbols?")
                )
                if (-not ($requirements -contains $true)) {
                    Write-Host $line_sep -ForegroundColor White
                    Write-Host ""
                    Write-Host "  ==== Error: You must select at least one character type!" -ForegroundColor Red
                    Write-Host ""
                    Write-Host $line_sep -ForegroundColor White
                    Write-Host ""
                }
            } while (-not ($requirements -contains $true))
            # Build character pool from selected types
            $charPool = -join @(
                if ($requirements[0]) { $UPPERCASE }
                if ($requirements[1]) { $LOWERCASE }
                if ($requirements[2]) { $NUMBERS }
                if ($requirements[3]) { $SYMBOLS }
            )
        }

        # Inner loop for password generation and actions
        do {
            # Generate and display a password
            $password = SecurePassword -charPool $charPool -length $length -requirements $requirements
            
            Write-Host $line_sep -ForegroundColor White
            Write-Host ""
            Write-Host "  ==== Password: $password" -ForegroundColor Cyan
            Write-Host ""
            Write-Host $line_sep -ForegroundColor White
            
            # Display action menu options
            Write-Host ""
            Write-Host " # Select Action"
            Write-Host ""
            Write-Host " 1. Generate Another"
            Write-Host " 2. Save Password"
            Write-Host " 3. Save Login Info"
            Write-Host " 4. Main Menu"
            Write-Host " 0. Exit"
            Write-Host ""
            
            # Prompt for and validate action menu choice (0-4)
            do {
                Write-Host "Enter Your Choice: " -NoNewline -ForegroundColor White
                $action = Read-Host
                Write-Host ""
                if ($action -notmatch '^[0-4]$') {
                    Write-Host $line_sep -ForegroundColor White
                    Write-Host ""
                    Write-Host "  ==== Invalid Choice! Please select 0, 1, 2, 3, or 4." -ForegroundColor Red
                    Write-Host ""
                    Write-Host $line_sep -ForegroundColor White
                    Write-Host ""
                }
            } while ($action -notmatch '^[0-4]$')

            # Handle save actions (options 2 and 3)
            if ($action -in 2,3) {
                $file = "$PWD\Passwords.txt"
                $content = if ($action -eq '2') {
                    "Password: $password`n="
                }
                else {
		    Write-Host "Website/Title: " -NoNewline -ForegroundColor White
                    $site = Read-Host
                    Write-Host ""
		    Write-Host "Username: " -NoNewline -ForegroundColor White
                    $user = Read-Host
                    Write-Host ""
                    "Website/Title: $site`nUsername: $user`nPassword: $password`n="
                }
                
                # Attempt to save the password to a file
                try {
                    Add-Content $file $content
                    Write-Host $line_sep -ForegroundColor White
                    Write-Host ""
                    Write-Host "  ==== Saved to $file" -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host $line_sep -ForegroundColor White
                }
                catch {
                    Write-Host $line_sep -ForegroundColor White
                    Write-Host ""
                    Write-Host "  ==== Save Failed!" -ForegroundColor Red
                    Write-Host ""
                    Write-Host $line_sep -ForegroundColor White
                    Write-Host ""
                }
            }

            # Return to main menu (option 4)
            if ($action -eq '4') { 
                Write-Host $line_sep -ForegroundColor White
                continue mainloop 
            }
            # Exit the script (option 0)
            if ($action -eq '0') { break mainloop }

        } while ($action -eq '1')  # Repeat if user chooses to generate another password
    }
}

# Function to get yes/no input from the user
function Get-YesNo($prompt) {
    do {
        Write-Host "$prompt (Y/N): " -NoNewline -ForegroundColor White
        $input = Read-Host
        Write-Host ""
        if ($input -match '^[YyNn]$') { 
            return $input -match '^[Yy]$' 
        }
        Write-Host $line_sep -ForegroundColor White
        Write-Host ""
        Write-Host "  ==== Invalid Choice! Please enter Y or N." -ForegroundColor Red
        Write-Host ""
        Write-Host $line_sep -ForegroundColor White
        Write-Host ""
    } while ($true)
}

# Function to generate a password with required character types
function SecurePassword {
    param($charPool, $length, $requirements)
    
    $random = [System.Random]::new()
    
    # Initialize password with one character from each required type
    $passwordChars = [System.Collections.ArrayList]::new()
    if ($requirements[0]) { $passwordChars.Add($UPPERCASE[$random.Next(26)]) | Out-Null }
    if ($requirements[1]) { $passwordChars.Add($LOWERCASE[$random.Next(26)]) | Out-Null }
    if ($requirements[2]) { $passwordChars.Add($NUMBERS[$random.Next(10)]) | Out-Null }
    if ($requirements[3]) { $passwordChars.Add($SYMBOLS[$random.Next($SYMBOLS.Length)]) | Out-Null }
    
    # Fill remaining length with random characters from the pool
    while ($passwordChars.Count -lt $length) {
        $passwordChars.Add($charPool[$random.Next($charPool.Length)]) | Out-Null
    }
    
    # Shuffle the password characters
    $shuffled = $passwordChars | Sort-Object { Get-Random }
    return -join $shuffled
}

# Start the password manager
PasswordManager

