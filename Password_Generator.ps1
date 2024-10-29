# If the script is not running, please open PowerShell as Administrator and run the following command:
# Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

function Get-Password {
    # Function to display the title with a dynamic border
    function Show-Title {
        # Get the width of the console window
        $consoleWidth = $Host.UI.RawUI.WindowSize.Width

        # Define the title text
        $title = " Password Generator Utility by Sabourifar "

        # Calculate the border and centered title
        $border = "=" * $consoleWidth
        $padding = ($consoleWidth - $title.Length) / 2
        $centeredTitle = $title.PadLeft($title.Length + [math]::Floor($padding)).PadRight($consoleWidth)

        # Display the border and centered title
        Write-Host $border -ForegroundColor White
        Write-Host $centeredTitle -ForegroundColor Cyan
        Write-Host $border -ForegroundColor White
    }

    # Function to ask for Yes or No and validate input
    function Get-YesOrNo($prompt) {
        do {
            Write-Host "$prompt (Y/N): " -ForegroundColor White -NoNewline
            $response = Read-Host
            if ($response -match '^[YyNn]$') {
                return $response -match '^[Yy]$'
            } else {
                Write-Host "Please enter Y or y / N or n." -ForegroundColor Red
            }
        } while ($true)
    }

    # Display the title
    Show-Title

    # Display the options first, then prompt for the choice
    Write-Host "`n1. Secure (Includes Uppercase, Lowercase, Numbers, and Symbols)" -ForegroundColor White
    Write-Host "2. Advanced (Choose Yourself)" -ForegroundColor White
    do {
        $choice = Read-Host "`nChoose an option"
        if ($choice -match '^[12]$') {
            break
        }
        Write-Host "Please enter 1 for Secure or 2 for Advanced." -ForegroundColor Red
    } while ($true)

    # Ask for the password length and validate the input
    do {
        Write-Host "`nPassword Length (4-80): " -ForegroundColor White -NoNewline
        $lengthInput = Read-Host
        
        if ($lengthInput -match '^\d+$') {
            $length = [int]$lengthInput
            if ($length -ge 4 -and $length -le 80) {
                break
            }
        }

        Write-Host "Please enter a valid number between 4 and 80." -ForegroundColor Red
    } while ($true)

    # Define character sets
    $uppercaseChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $lowercaseChars = "abcdefghijklmnopqrstuvwxyz"
    $numberChars = "1234567890"
    $symbolChars = "~``!@#$%^&*()-_=+{}[];:'""\|,.<>/?"

    # Build the character pool based on user choice
    $charPool = ""
    if ($choice -eq '1') {
        # Secure option includes all character types
        $charPool = $uppercaseChars + $lowercaseChars + $numberChars + $symbolChars
    } elseif ($choice -eq '2') {
        # Advanced option lets the user choose character types
        $includeUppercase = Get-YesOrNo "`nInclude Uppercase?"
        $includeLowercase = Get-YesOrNo "`nInclude Lowercase?"
        $includeNumbers = Get-YesOrNo "`nInclude Numbers?"
        $includeSymbols = Get-YesOrNo "`nInclude Symbols?"

        if ($includeUppercase) { $charPool += $uppercaseChars }
        if ($includeLowercase) { $charPool += $lowercaseChars }
        if ($includeNumbers) { $charPool += $numberChars }
        if ($includeSymbols) { $charPool += $symbolChars }

        # Ensure at least one character set is selected
        if ($charPool.Length -eq 0) {
            Write-Host "You must select at least one character set (uppercase, lowercase, numbers, symbols)." -ForegroundColor Red
            return
        }
    }

    # Generate the password by randomly selecting characters from the pool
    $random = New-Object System.Random
    $password = -join (1..$length | ForEach-Object { $charPool[$random.Next(0, $charPool.Length)] })

    # Output the generated password
    Write-Host "`nGenerated Password: $password" -ForegroundColor Cyan

    # Ask if the user wants to save the password
    if (Get-YesOrNo "`nDo you want to save this password to a file?") {
        # Save the password to a text file in the same directory as the script
        $scriptDir = Get-Location
        $filePath = Join-Path $scriptDir "Password.txt"
        try {
            $password | Out-File -FilePath $filePath -Encoding UTF8 -Force
            Write-Host "`nPassword saved to $filePath" -ForegroundColor Cyan
        } catch {
            Write-Host "`nFailed to save the password. Please check file permissions." -ForegroundColor Red
        }
    }

    # Prompt user to press 0 to exit
    do {
        Write-Host "`nPress 0 to exit..." -ForegroundColor Yellow -NoNewline
        $exitKey = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
    } while ($exitKey -ne '0')
}

# Call the function to run the password generator
Get-Password
