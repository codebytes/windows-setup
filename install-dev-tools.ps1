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
    - On fresh Windows installations, run 'winget --version' first to accept license agreements
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

function Write-Info    { param($m) Write-Host "[INFO] $m"    -ForegroundColor $InfoColor }
function Write-OK      { param($m) Write-Host "[OK] $m"      -ForegroundColor $SuccessColor }
function Write-Warn    { param($m) Write-Host "[WARN] $m"    -ForegroundColor $WarningColor }
function Write-ErrorX  { param($m) Write-Host "[ERROR] $m"   -ForegroundColor $ErrorColor }
function Section       { param($t) Write-Host "`n--- $t ---" -ForegroundColor $InfoColor }

function Test-Admin    { ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") }
function Test-Winget   { try { Get-Command winget -ErrorAction Stop | Out-Null; $true } catch { $false } }
function Test-App {
    param($wingetName)
    try {
        $output = winget list --name $wingetName 2>$null
        if ($output -match $wingetName) { return $true }
    } catch {}
    return $false
}

function Install-App {
    param($id, $name, $wingetName, $extraArgs = "")
    if (Test-App $wingetName) { Write-OK "$name already installed."; return $true }
    Write-Info "Installing $name..."
    $installArgs = @("install", "--id=$id", "--exact", "--silent", "--accept-package-agreements", "--accept-source-agreements")
    if ($extraArgs) { $installArgs += $extraArgs }
    $output = & winget @installArgs 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-OK "$name installed."; return $true
    }
    # Treat all known benign messages as success
    $benign = @(
        'already installed',
        'No available upgrade found',
        'No newer package versions are available',
        'No package found matching input criteria',
        'is up to date',
        'is installed and up to date',
        'Nothing to do.'
    )
    foreach ($msg in $benign) {
        if ($output -match [regex]::Escape($msg)) {
            Write-OK "$name already installed or up to date."; return $true
        }
    }
    # Only print error for true failures
    Write-ErrorX "$name failed (exit $LASTEXITCODE): $output"; return $false
}

# -----------------------------------------------------------------------------
# Main Installation Logic
# -----------------------------------------------------------------------------

function Initialize {
    Section "Development Tools Installation"
    if (-not (Test-Admin)) { Write-Warn "Some installs may need admin rights. Run as Administrator for best results." }
    if (-not (Test-Winget)) {
        Write-ErrorX "Winget not available. Install App Installer from Microsoft Store or https://aka.ms/getwinget"
        exit 1
    }
    Write-OK "Prerequisites check complete."
    if ((Read-Host "Proceed with installation? (Y/N)") -notmatch "^y") { Write-Info "Cancelled by user."; exit 0 }
}

function Install-DevTools {
    Section "Installing Development Tools"
    $tools = @(
        @{ Id="Microsoft.VisualStudioCode";        Name="Visual Studio Code"; WingetName="Microsoft.VisualStudioCode" }
        @{ Id="Microsoft.VisualStudio.2022.Enterprise"; Name="Visual Studio 2022 Enterprise"; WingetName="Microsoft.VisualStudio.2022.Enterprise" }
        @{ Id="JetBrains.Toolbox";                Name="JetBrains Toolbox"; WingetName="jetbrains.toolbox" }
        @{ Id="MartiCliment.UniGetUI";                Name="UniGetUI"; WingetName="MartiCliment.UniGetUI" }
        @{ Id="GitHub.cli";                       Name="GitHub CLI"; WingetName="GitHub.cli" }
        @{ Id="GitHub.GitHubDesktop";             Name="GitHub Desktop"; WingetName="GitHub.GitHubDesktop" }
        @{ Id="Git.Git";                          Name="Git"; WingetName="Git.Git" }
        @{ Id="Docker.DockerDesktop";             Name="Docker Desktop"; WingetName="Docker.DockerDesktop" }
        @{ Id="Microsoft.DotNet.SDK.8";           Name=".NET 8 SDK"; WingetName="Microsoft.DotNet.SDK.8" }
        @{ Id="Microsoft.DotNet.SDK.9";           Name=".NET 9 SDK"; WingetName="Microsoft.DotNet.SDK.9" }
        @{ Id="Python.Python.3.12";               Name="Python 3.12"; WingetName="Python.Python.3.12" }
        @{ Id="OpenJS.NodeJS";                    Name="Node.js (npm)"; WingetName="OpenJS.NodeJS" }
        @{ Id="LINQPad.LINQPad.7";                Name="LinqPad 7"; WingetName="LINQPad.LINQPad.7" }
        @{ Id="Microsoft.PowerShell";             Name="PowerShell (latest)"; WingetName="Microsoft.PowerShell" }
        @{ Id="Microsoft.AzureCLI";               Name="Azure CLI"; WingetName="Microsoft.AzureCLI" }
        @{ Id="Microsoft.Azd";                    Name="Azure Developer CLI"; WingetName="Microsoft.Azd" }
        @{ Id="JanDeDobbeleer.OhMyPosh";          Name="Oh My Posh"; WingetName="JanDeDobbeleer.OhMyPosh" }
        @{ Id="Obsidian.Obsidian";                Name="Obsidian"; WingetName="Obsidian.Obsidian" }
    )
    $ok = 0; $total = $tools.Count
    foreach ($t in $tools) { if (Install-App $t.Id $t.Name $t.WingetName) { $ok++ }; Write-Host "" }
    Section "Summary"
    Write-Host "$ok of $total tools installed." -ForegroundColor $InfoColor
    if ($ok -eq $total) { Write-OK "All tools installed." }
    elseif ($ok -gt 0) { Write-Warn "$($total - $ok) failed." }
    else { Write-ErrorX "No tools installed." }

    Section "Validation"
    foreach ($t in $tools) {
        $result = winget list --id $t.Id 2>$null
        if ($result -match $t.Id) {
            Write-OK "$($t.Name) is installed."
        } else {
            Write-ErrorX "$($t.Name) is NOT installed!"
        }
    }
}

function Install-WSL {
    if ($SkipWSL) { Write-Info "Skipping WSL install."; return }
    Section "Installing WSL"
    try {
        $wslVersion = wsl --version 2>$null
        if ($LASTEXITCODE -eq 0) { Write-Warn "WSL already installed."; Write-Host $wslVersion -ForegroundColor $InfoColor; return }
    } catch {}
    Write-Info "Installing WSL (may require restart)..."
    $result = Start-Process -FilePath "wsl" -ArgumentList "--install" -Wait -PassThru -NoNewWindow
    if ($result.ExitCode -eq 0) { Write-OK "WSL installed. Restart may be required." }
    else { Write-Warn "WSL install exit code: $($result.ExitCode). May be normal if partially installed." }
}

function PostInstall {
    Section "Installation Complete"
    Write-OK "Development tools installation complete!"
    Write-Host "`nNext Steps:" -ForegroundColor $InfoColor
    Write-Host "1. Restart if prompted (especially for WSL)"
    Write-Host "2. Configure your tools as needed"
    Write-Host "3. Sign in to GitHub Desktop/CLI, Azure CLI/Developer CLI"
    Write-Host "4. Configure Docker Desktop, Oh My Posh, PATH, etc."
    Write-Host "`nUseful Commands:" -ForegroundColor $InfoColor
    Write-Host "- winget list"
    Write-Host "- winget upgrade --all"
    Write-Host "- gh auth login"
    Write-Host "- az login"
    Write-Host "- azd auth login"
    Write-Host "- node --version && npm --version"
    Write-Host "- python --version"
    Write-Host "- dotnet --version"
    Write-Host "- $PSVersionTable.PSVersion"
    Write-Host "- oh-my-posh init pwsh | Invoke-Expression"
    Write-Host ""
    # No reboot at the end
}

# -----------------------------------------------------------------------------
# Script Execution
# -----------------------------------------------------------------------------

try {
    Initialize
    Install-DevTools
    Install-WSL
    PostInstall
} catch {
    Write-ErrorX "Unexpected error: $($_.Exception.Message)"
    Write-ErrorX "Stack trace: $($_.ScriptStackTrace)"
    exit 1
} finally {
    Write-Host ""
    Write-Host "Script execution completed." -ForegroundColor $InfoColor
}