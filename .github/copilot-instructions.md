# Windows 11 Setup Script

**ALWAYS follow these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

This repository contains a PowerShell script for automated Windows 11 system setup and configuration. The script removes bloatware, installs essential applications, configures security settings, and sets up WSL.

## Critical Platform Requirements

- **Windows 11 ONLY**: This script is designed exclusively for Windows 11 systems
- **DO NOT attempt to run this script on Linux, macOS, or other platforms** - it will fail
- **PowerShell 5.1+ required**: Script uses Windows-specific PowerShell cmdlets
- **Administrator privileges required**: Script automatically self-elevates to admin

## Repository Structure

```
/home/runner/work/windows-setup/windows-setup/
├── README.md           # Project documentation
├── script.ps1         # Main Windows 11 setup script
└── .github/
    └── copilot-instructions.md  # This file
```

## Working Effectively

### Syntax Validation (Linux/Non-Windows environments)
When working on non-Windows systems, you can validate PowerShell syntax:

```bash
# Validate PowerShell syntax (works on Linux with pwsh installed)
cd /home/runner/work/windows-setup/windows-setup
pwsh -Command "\$script = Get-Content script.ps1 -Raw; [System.Management.Automation.PSParser]::Tokenize(\$script, [ref]\$null) | Out-Null; Write-Host 'PowerShell syntax is valid'"
```

**NEVER CANCEL** - Syntax validation completes in under 5 seconds.

### Script Execution (Windows environments only)

```powershell
# Method 1: Direct execution (requires Administrator PowerShell)
Set-ExecutionPolicy Bypass -Scope Process -Force
.\script.ps1

# Method 2: Remote execution from GitHub (as documented in README)
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/samuelramox/windows-setup/master/script.ps1'))
```

**NEVER CANCEL** - Full script execution takes 15-30 minutes depending on internet speed and system performance. Set timeout to 45+ minutes.

## Manual Validation Requirements

### On Windows Systems
After running the script, ALWAYS validate these scenarios:

1. **Application Installation Verification**:
   ```powershell
   # Verify winget installations completed
   winget list Git.Git
   winget list Google.Chrome
   winget list Microsoft.VisualStudioCode
   winget list JanDeDobbeleer.OhMyPosh
   ```

2. **UWP App Removal Verification**:
   ```powershell
   # Check that bloatware was removed
   Get-AppxPackage | Where-Object {$_.Name -like "*Disney*" -or $_.Name -like "*BingNews*" -or $_.Name -like "*Solitaire*"}
   # Should return no results if successful
   ```

3. **WSL Installation Verification**:
   ```powershell
   # Verify WSL is installed
   wsl --status
   wsl --list --online
   ```

4. **Registry Settings Verification**:
   ```powershell
   # Check autoplay disabled
   Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay"
   
   # Check autorun disabled
   Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun"
   ```

### On Non-Windows Systems
Since the script cannot be executed:

1. **Syntax Validation**: Use the pwsh command shown above
2. **Code Review**: Manually review script.ps1 for logical errors
3. **Documentation Review**: Ensure README.md matches script functionality

## Script Functionality Overview

The script performs these operations in sequence:

1. **Self-elevation to Administrator** (automatic)
2. **UWP App Removal** (~2 minutes):
   - Disney.37853FC22B2CE
   - Microsoft.BingNews, GetHelp, Getstarted
   - Microsoft.MicrosoftSolitaireCollection, MicrosoftOfficeHub
   - Microsoft.WindowsFeedbackHub
   - SpotifyAB.SpotifyMusic
3. **Winget Installation** (~3 minutes) - if not present
4. **Application Installation** (~10-15 minutes):
   - Git for Windows, Google Chrome
   - Oh My Posh, PowerToys, Visual Studio Code
   - Postman, Slack, QuickLook
5. **Security Configuration** (~1 minute):
   - Enable PUA Protection in Windows Defender
6. **System Configuration** (~1 minute):
   - Disable Autoplay and Autorun
   - Disable Windows Update P2P optimization
7. **WSL Installation** (~5-10 minutes)
8. **Nerd Font Installation** (~2 minutes)
9. **System Restart** (required)

**NEVER CANCEL** any of these operations - the script includes interactive prompts and automatic retries.

## Common Modification Tasks

### Adding New Applications
To add applications to the winget installation list:

1. Find the winget package ID: `winget search "App Name"`
2. Add to the `$Apps` array in script.ps1:
   ```powershell
   $Apps= @(
     "Google.Chrome",
     "JanDeDobbeleer.OhMyPosh",
     # ... existing apps ...
     "NewVendor.NewApp"  # Add here
   )
   ```

### Adding UWP Apps for Removal
To remove additional UWP bloatware:

1. List installed UWP apps: `Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName`
2. Add the Name to `$uwpRubbishApps` array in script.ps1

### Modifying Registry Settings
Always test registry changes on a virtual machine first:

1. Use `Test-Path` to check if registry key exists
2. Use `New-Item` to create missing registry paths
3. Use `Set-ItemProperty` to modify values

## Validation Checklist

Before committing changes to script.ps1:

- [ ] Validate PowerShell syntax using pwsh command
- [ ] Review all registry paths for typos
- [ ] Verify all winget package IDs exist: `winget search "package.id"`
- [ ] Test on Windows 11 VM if possible
- [ ] Update README.md if functionality changes
- [ ] Ensure script maintains self-elevation logic

## Limitations in Non-Windows Environments

**DO NOT attempt these operations on Linux/macOS**:
- Running script.ps1 directly
- Testing winget commands
- Testing Windows registry modifications
- Testing Windows Defender settings
- Testing WSL installation
- Testing UWP app removal

**You CAN do these operations**:
- Syntax validation with pwsh
- Code review and logical analysis
- Documentation updates
- File structure modifications

## Error Handling

The script includes built-in error handling:
- Self-elevation for admin privileges
- Conditional installation (checks if apps already exist)
- Interactive prompts for manual intervention
- Automatic retry mechanisms for network operations

When modifying the script, maintain these patterns:
```powershell
# Check if command exists before using
if (Check-Command -cmdname 'commandname') {
  # Command exists logic
} else {
  # Installation logic
}

# Test registry paths before modification
If (!(Test-Path "HKLM:\Path\To\Key")) {
  New-Item -Path "HKLM:\Path\To\Key" | Out-Null
}
```

## Time Expectations

- **Syntax validation**: 5 seconds
- **Full script execution**: 15-30 minutes (Windows only)
- **Manual verification**: 5-10 minutes (Windows only)
- **Code review**: 10-15 minutes (any platform)

**CRITICAL**: Always set timeouts of 45+ minutes for full script execution and 60+ minutes if including verification steps.