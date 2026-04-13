#requires -Version 5.1

<#
.SYNOPSIS
    Bootstrap a Windows 11 dev machine using WinGet DSC.

.DESCRIPTION
    Self-elevates to Administrator, ensures WinGet is ready, then applies
    the codebytes.dev.dsc.yml configuration.
#>

$ErrorActionPreference = 'Stop'

# ── Self-elevate to Administrator ──────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    $scriptFile = if ($PSCommandPath) { $PSCommandPath } else { $null }

    if (-not $scriptFile) {
        Write-Host "ERROR: Script must be run from a saved file, not piped input." -ForegroundColor Red
        Write-Host "Save to a file first, then run it." -ForegroundColor Red
        exit 1
    }

    Write-Host "Restarting as Administrator..." -ForegroundColor Yellow
    Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $scriptFile
    )
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  codebytes Dev Machine Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ── Ensure WinGet is ready ─────────────────────────────────────────────
Write-Host "Ensuring WinGet is ready..." -ForegroundColor Cyan
$ProgressPreference = 'SilentlyContinue'

try {
    Write-Host "  Installing NuGet package provider..."
    Install-PackageProvider -Name NuGet -Force -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null

    Write-Host "  Installing Microsoft.WinGet.Client module..."
    Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery -ErrorAction Stop -WarningAction SilentlyContinue

    Write-Host "  Repairing WinGet Package Manager..."
    Repair-WinGetPackageManager -Force -Latest -ErrorAction Stop

    Write-Host "  WinGet is ready." -ForegroundColor Green
}
catch {
    Write-Warning "Module approach failed: $($_.Exception.Message)"
    Write-Host "  Attempting manual WinGet installation..." -ForegroundColor Yellow

    $downloads = @(
        @{ File = 'Microsoft.VCLibs.x64.14.00.Desktop.appx'; Uri = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' },
        @{ File = 'Microsoft.UI.Xaml.2.8.x64.appx';          Uri = 'https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx' },
        @{ File = 'Microsoft.DesktopAppInstaller.msixbundle'; Uri = 'https://aka.ms/getwinget' }
    )

    foreach ($dl in $downloads) {
        $dest = Join-Path $env:TEMP $dl.File
        Write-Host "  Downloading $($dl.File)..."
        try {
            Start-BitsTransfer -Source $dl.Uri -Destination $dest -ErrorAction Stop
        } catch {
            Invoke-WebRequest -Uri $dl.Uri -OutFile $dest -ErrorAction Stop
        }
        Write-Host "  Installing $($dl.File)..."
        Add-AppxPackage $dest -ErrorAction SilentlyContinue
        Remove-Item $dest -Force -ErrorAction SilentlyContinue
    }

    Write-Host "  WinGet version: $(winget -v)" -ForegroundColor Green
}

# ── Run DSC configuration ──────────────────────────────────────────────
$dscBase = "https://raw.githubusercontent.com/codebytes/windows-setup/main/"
$dscFile = "codebytes.dev.dsc.yml"
$cacheBust = "?v=$(Get-Date -Format 'yyyyMMddHHmmss')"
$dscUrl = $dscBase + $dscFile + $cacheBust

Write-Host ""
Write-Host "Enabling WinGet configure..." -ForegroundColor Cyan
winget configure --enable 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Warning "winget configure --enable returned exit code $LASTEXITCODE. Proceeding anyway..."
}

Write-Host "Applying DSC configuration from: $dscFile" -ForegroundColor Cyan
Write-Host ""
winget configure -f $dscUrl --accept-configuration-agreements
$configExitCode = $LASTEXITCODE

Write-Host ""
if ($configExitCode -eq 0) {
    Write-Host "Done: codebytes Dev Machine Setup" -ForegroundColor Green
} else {
    Write-Host "WinGet configure exited with code $configExitCode" -ForegroundColor Yellow
    Write-Host "Some resources may have failed. Review the output above." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  NEXT STEPS:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  1. Run: gh auth login" -ForegroundColor Yellow
Write-Host "  2. Then run: .\clone-repos.ps1" -ForegroundColor Yellow
Write-Host "  3. Restart your computer" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
