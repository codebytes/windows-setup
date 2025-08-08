# Development Tools Installation Script
# This script installs essential development tools using winget
# Author: Windows Setup Repository
# Version: 1.0

<#
.SYNOPSIS
    Installs essential development tools for Windows using winget package manager.

.DESCRIPTION
    This PowerShell script automates the installation of development tools including:
    - Visual Studio Code
    - Visual Studio Community
    - GitHub CLI
    - GitHub Desktop
    - Git
    - Docker Desktop
    - .NET SDK
    - Python
    - Node.js (includes npm)
    - LinqPad
    - PowerShell (latest version)
    - Azure CLI
    - Azure Developer CLI
    - Oh My Posh
    - Obsidian
    - Windows Subsystem for Linux (WSL)

    The script checks for existing installations and skips already installed tools.
    It includes comprehensive error handling and provides informative output for each step.

.PARAMETER SkipWSL
    Skip the WSL installation step (useful if WSL is already configured)

.EXAMPLE
    .\install-dev-tools.ps1
    Installs all development tools including WSL

.EXAMPLE
    .\install-dev-tools.ps1 -SkipWSL
    Installs all development tools except WSL

.NOTES
    - This script requires administrative privileges for some installations
    - Winget must be available on the system
    - Internet connection is required for downloads
#>

param(
    [switch]$SkipWSL = $false
)

# -----------------------------------------------------------------------------
# Script Configuration
# -----------------------------------------------------------------------------

# Set error action preference for better error handling
$ErrorActionPreference = "Continue"

# Define console colors for better output visibility
$InfoColor = "Cyan"
$SuccessColor = "Green"
$WarningColor = "Yellow"
$ErrorColor = "Red"

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

function Write-SectionHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor $InfoColor
    Write-Host " $Title" -ForegroundColor $InfoColor
    Write-Host "=" * 60 -ForegroundColor $InfoColor
}

function Write-StepInfo {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor $InfoColor
}

function Write-StepSuccess {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor $SuccessColor
}

function Write-StepWarning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor $WarningColor
}

function Write-StepError {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor $ErrorColor
}

function Test-AdminRights {
    <#
    .SYNOPSIS
        Checks if the current PowerShell session has administrator privileges
    #>
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

function Test-WingetAvailable {
    <#
    .SYNOPSIS
        Checks if winget is available on the system
    #>
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Test-AppInstalled {
    <#
    .SYNOPSIS
        Checks if an application is already installed using winget
    .PARAMETER AppId
        The winget application ID to check
    #>
    param([string]$AppId)
    
    try {
        $result = winget list --id $AppId --exact 2>$null
        return $LASTEXITCODE -eq 0
    }
    catch {
        return $false
    }
}

function Install-WingetApp {
    <#
    .SYNOPSIS
        Installs an application using winget with error handling
    .PARAMETER AppId
        The winget application ID to install
    .PARAMETER AppName
        Human-readable name of the application
    .PARAMETER AdditionalArgs
        Additional arguments to pass to winget install
    #>
    param(
        [string]$AppId,
        [string]$AppName,
        [string]$AdditionalArgs = ""
    )
    
    Write-StepInfo "Installing $AppName..."
    
    # Check if already installed
    if (Test-AppInstalled -AppId $AppId) {
        Write-StepWarning "$AppName is already installed. Skipping installation."
        return $true
    }
    
    try {
        $installArgs = "install --id=$AppId --exact --silent --accept-package-agreements --accept-source-agreements"
        if ($AdditionalArgs) {
            $installArgs += " $AdditionalArgs"
        }
        
        Write-StepInfo "Running: winget $installArgs"
        $result = Start-Process -FilePath "winget" -ArgumentList $installArgs -Wait -PassThru -NoNewWindow
        
        if ($result.ExitCode -eq 0) {
            Write-StepSuccess "$AppName installed successfully."
            return $true
        }
        else {
            Write-StepError "$AppName installation failed with exit code: $($result.ExitCode)"
            return $false
        }
    }
    catch {
        Write-StepError "Error installing $AppName`: $($_.Exception.Message)"
        return $false
    }
}

# -----------------------------------------------------------------------------
# Main Installation Logic
# -----------------------------------------------------------------------------

function Initialize-Script {
    <#
    .SYNOPSIS
        Initializes the script by checking prerequisites
    #>
    Write-SectionHeader "Development Tools Installation Script"
    Write-Host "This script will install essential development tools using winget." -ForegroundColor $InfoColor
    Write-Host ""
    
    # Check for administrator rights
    if (-not (Test-AdminRights)) {
        Write-StepWarning "Some installations may require administrator privileges."
        Write-StepInfo "Consider running PowerShell as Administrator for best results."
    }
    
    # Check for winget availability
    if (-not (Test-WingetAvailable)) {
        Write-StepError "Winget is not available on this system."
        Write-StepError "Please install the Microsoft App Installer from the Microsoft Store."
        Write-StepError "Or visit: https://aka.ms/getwinget"
        exit 1
    }
    
    Write-StepSuccess "Prerequisites check completed."
    
    # Ask for confirmation
    Write-Host ""
    $response = Read-Host "Do you want to proceed with the installation? (Y/N)"
    if ($response -notlike "Y*" -and $response -notlike "y*") {
        Write-StepInfo "Installation cancelled by user."
        exit 0
    }
}

function Install-DevelopmentTools {
    <#
    .SYNOPSIS
        Installs all development tools
    #>
    Write-SectionHeader "Installing Development Tools"
    
    # Define development tools to install
    $tools = @(
        @{
            Id = "Microsoft.VisualStudioCode"
            Name = "Visual Studio Code"
            Args = ""
        },
        @{
            Id = "Microsoft.VisualStudio.2022.Community"
            Name = "Visual Studio Community 2022"
            Args = ""
        },
        @{
            Id = "GitHub.cli"
            Name = "GitHub CLI"
            Args = ""
        },
        @{
            Id = "GitHub.GitHubDesktop"
            Name = "GitHub Desktop"
            Args = ""
        },
        @{
            Id = "Git.Git"
            Name = "Git"
            Args = ""
        },
        @{
            Id = "Docker.DockerDesktop"
            Name = "Docker Desktop"
            Args = ""
        },
        @{
            Id = "Microsoft.DotNet.SDK.8"
            Name = ".NET 8 SDK"
            Args = ""
        },
        @{
            Id = "Python.Python.3.12"
            Name = "Python 3.12"
            Args = ""
        },
        @{
            Id = "OpenJS.NodeJS"
            Name = "Node.js (includes npm)"
            Args = ""
        },
        @{
            Id = "LINQPad.LINQPad.7"
            Name = "LinqPad 7"
            Args = ""
        },
        @{
            Id = "Microsoft.PowerShell"
            Name = "PowerShell (latest version)"
            Args = ""
        },
        @{
            Id = "Microsoft.AzureCLI"
            Name = "Azure CLI"
            Args = ""
        },
        @{
            Id = "Microsoft.Azd"
            Name = "Azure Developer CLI"
            Args = ""
        },
        @{
            Id = "JanDeDobbeleer.OhMyPosh"
            Name = "Oh My Posh"
            Args = ""
        },
        @{
            Id = "Obsidian.Obsidian"
            Name = "Obsidian"
            Args = ""
        }
    )
    
    $successCount = 0
    $totalCount = $tools.Count
    
    foreach ($tool in $tools) {
        if (Install-WingetApp -AppId $tool.Id -AppName $tool.Name -AdditionalArgs $tool.Args) {
            $successCount++
        }
        Write-Host "" # Add spacing between installations
    }
    
    Write-SectionHeader "Development Tools Installation Summary"
    Write-Host "Successfully installed: $successCount out of $totalCount tools" -ForegroundColor $InfoColor
    
    if ($successCount -eq $totalCount) {
        Write-StepSuccess "All development tools were installed successfully!"
    }
    elseif ($successCount -gt 0) {
        Write-StepWarning "Some tools were installed successfully, but $($totalCount - $successCount) failed."
    }
    else {
        Write-StepError "No tools were installed successfully."
    }
}

function Install-WSL {
    <#
    .SYNOPSIS
        Installs Windows Subsystem for Linux (WSL)
    #>
    if ($SkipWSL) {
        Write-StepInfo "Skipping WSL installation as requested."
        return
    }
    
    Write-SectionHeader "Installing Windows Subsystem for Linux (WSL)"
    
    try {
        # Check if WSL is already installed
        $wslVersion = wsl --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-StepWarning "WSL is already installed. Skipping installation."
            Write-Host "Current WSL version info:"
            Write-Host $wslVersion -ForegroundColor $InfoColor
            return
        }
    }
    catch {
        # WSL command not found, proceed with installation
    }
    
    Write-StepInfo "Installing WSL..."
    Write-StepInfo "This may take several minutes and might require a system restart."
    
    try {
        $result = Start-Process -FilePath "wsl" -ArgumentList "--install" -Wait -PassThru -NoNewWindow
        
        if ($result.ExitCode -eq 0) {
            Write-StepSuccess "WSL installation completed successfully."
            Write-StepInfo "A system restart may be required to complete the WSL installation."
        }
        else {
            Write-StepWarning "WSL installation completed with exit code: $($result.ExitCode)"
            Write-StepInfo "This might be normal if WSL was already partially installed."
        }
    }
    catch {
        Write-StepError "Error installing WSL: $($_.Exception.Message)"
        Write-StepInfo "You can manually install WSL using: wsl --install"
    }
}

function Show-PostInstallationInfo {
    <#
    .SYNOPSIS
        Shows post-installation information and next steps
    #>
    Write-SectionHeader "Installation Complete"
    
    Write-Host "🎉 Development tools installation is complete!" -ForegroundColor $SuccessColor
    Write-Host ""
    
    Write-Host "Next Steps:" -ForegroundColor $InfoColor
    Write-Host "1. Restart your computer if prompted (especially for WSL)" -ForegroundColor $InfoColor
    Write-Host "2. Configure your development tools as needed" -ForegroundColor $InfoColor
    Write-Host "3. Sign in to GitHub Desktop and GitHub CLI" -ForegroundColor $InfoColor
    Write-Host "4. Sign in to Azure CLI and Azure Developer CLI" -ForegroundColor $InfoColor
    Write-Host "5. Configure Docker Desktop" -ForegroundColor $InfoColor
    Write-Host "6. Set up Oh My Posh theme for PowerShell" -ForegroundColor $InfoColor
    Write-Host "7. Update Windows PATH if needed for command-line tools" -ForegroundColor $InfoColor
    Write-Host ""
    
    Write-Host "Useful Commands:" -ForegroundColor $InfoColor
    Write-Host "- Check installed versions: winget list" -ForegroundColor $InfoColor
    Write-Host "- Update all tools: winget upgrade --all" -ForegroundColor $InfoColor
    Write-Host "- GitHub CLI login: gh auth login" -ForegroundColor $InfoColor
    Write-Host "- Azure CLI login: az login" -ForegroundColor $InfoColor
    Write-Host "- Azure Developer CLI login: azd auth login" -ForegroundColor $InfoColor
    Write-Host "- Check Node.js/npm: node --version && npm --version" -ForegroundColor $InfoColor
    Write-Host "- Check Python: python --version" -ForegroundColor $InfoColor
    Write-Host "- Check .NET: dotnet --version" -ForegroundColor $InfoColor
    Write-Host "- Check PowerShell: `$PSVersionTable.PSVersion" -ForegroundColor $InfoColor
    Write-Host "- Configure Oh My Posh: oh-my-posh init pwsh | Invoke-Expression" -ForegroundColor $InfoColor
    Write-Host ""
    
    $restart = Read-Host "Do you want to restart your computer now? (Y/N)"
    if ($restart -like "Y*" -or $restart -like "y*") {
        Write-StepInfo "Restarting computer in 10 seconds... Press Ctrl+C to cancel."
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
}

# -----------------------------------------------------------------------------
# Script Execution
# -----------------------------------------------------------------------------

try {
    # Initialize and check prerequisites
    Initialize-Script
    
    # Install development tools
    Install-DevelopmentTools
    
    # Install WSL (unless skipped)
    Install-WSL
    
    # Show completion information
    Show-PostInstallationInfo
}
catch {
    Write-StepError "An unexpected error occurred: $($_.Exception.Message)"
    Write-StepError "Stack trace: $($_.ScriptStackTrace)"
    exit 1
}
finally {
    Write-Host ""
    Write-Host "Script execution completed." -ForegroundColor $InfoColor
}