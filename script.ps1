#requires -Version 5.1

<#
.SYNOPSIS
    Backward-compatible entrypoint that delegates to boot.ps1.

.DESCRIPTION
    This file preserves the existing raw-URL one-liners while the real setup
    logic now lives in boot.ps1 (WinGet DSC configuration).

    When run locally it calls the sibling boot.ps1 file.
    When downloaded remotely it fetches boot.ps1 to a temp file and runs it.
#>

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

try {
    $bootPath = Join-Path $PSScriptRoot 'boot.ps1'

    if (-not (Test-Path -Path $bootPath)) {
        $bootPath = Join-Path $env:TEMP 'windows-setup-boot.ps1'
        $bootContent = Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/codebytes/windows-setup/main/boot.ps1'
        Set-Content -Path $bootPath -Value $bootContent -Encoding UTF8
    }

    & $bootPath
    exit $LASTEXITCODE
} catch {
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
