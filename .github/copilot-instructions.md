# Windows 11 Setup Scripts

**ALWAYS follow these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

This repository uses **WinGet DSC** (Desired State Configuration) for automated Windows 11 system setup. The setup is declarative — a YAML file describes the desired machine state and WinGet applies it idempotently.

## Critical Platform Requirements

- **Windows 11 ONLY**: Designed exclusively for Windows 11 systems
- **DO NOT attempt to run on Linux, macOS, or other platforms** - it will fail
- **PowerShell 5.1+ required**: Script uses Windows-specific PowerShell cmdlets
- **Administrator privileges required**: `boot.ps1` automatically self-elevates

## Repository Structure

```
├── boot.ps1                  # Bootstrapper: admin elevation → WinGet repair → DSC run
├── codebytes.dev.dsc.yml     # Declarative DSC config (packages, settings, scripts)
├── codebytes.omp.json        # Oh My Posh prompt theme
├── clone-repos.ps1           # Clone personal GitHub repos via gh CLI
├── .vsconfig                 # Visual Studio workload/component selection
└── README.md
```

## Working Effectively

### Syntax Validation
```bash
pwsh -Command "\$script = Get-Content boot.ps1 -Raw; [System.Management.Automation.PSParser]::Tokenize(\$script, [ref]\$null) | Out-Null; Write-Host 'PowerShell syntax is valid'"
```

### Script Execution (Windows environments only)

```powershell
# Method 1: Direct execution (requires Administrator PowerShell)
Set-ExecutionPolicy Bypass -Scope Process -Force
.\boot.ps1

# Method 2: Remote execution from GitHub (as documented in README)
Set-ExecutionPolicy Bypass -Scope Process -Force; $script = Join-Path $env:TEMP 'windows-setup-boot.ps1'; irm 'https://raw.githubusercontent.com/codebytes/windows-setup/main/boot.ps1' | Set-Content -Path $script -Encoding UTF8; & $script
```

**NEVER CANCEL** - Full execution takes 15-30 minutes. Set timeout to 45+ minutes.

## How It Works

`boot.ps1` is the main entrypoint. It:

1. Self-elevates to Administrator
2. Ensures WinGet is installed and up to date
3. Enables `winget configure`
4. Runs `winget configure -f codebytes.dev.dsc.yml --accept-configuration-agreements`

The DSC YAML (`codebytes.dev.dsc.yml`) declares all packages, settings, and scripts:

- **Packages**: 30+ WinGet packages via `Microsoft.WinGet.DSC/WinGetPackage` resources
- **Windows Settings**: via `Microsoft.Windows.Developer/*` resources
- **Custom Actions**: bloatware removal, security hardening, profile setup via `PSDscResources/Script` blocks
- **Dev Drive**: 50 GB ReFS volume on D: via `StorageDsc/Disk`

## Common Modification Tasks

### Adding New Applications
1. Find the winget package ID: `winget search "App Name"`
2. Add a new `WinGetPackage` resource to `codebytes.dev.dsc.yml`:
   ```yaml
       - resource: Microsoft.WinGet.DSC/WinGetPackage
         id: myapp
         directives:
           description: Install My App
           allowPrerelease: true
         settings:
           id: Vendor.AppId
           source: winget
   ```

### Adding UWP Apps for Removal
1. List installed UWP apps: `Get-AppxPackage | Select-Object Name | Sort-Object Name`
2. Add the Name to the package list in the `RemoveBloatware` script block inside `codebytes.dev.dsc.yml`

### Changing Visual Studio Workloads
Edit `.vsconfig` — the DSC configuration applies it after VS installs.

### Changing the Oh My Posh Theme
Edit `codebytes.omp.json` — downloaded during DSC profile setup.

### Adding Repos to Clone
Edit the `$repos` array in `clone-repos.ps1`.

## Validation Checklist

Before committing changes:

- [ ] Validate PowerShell syntax: `pwsh -Command "...Tokenize..."`
- [ ] Validate YAML syntax: `python -c "import yaml; yaml.safe_load(open('codebytes.dev.dsc.yml'))"`
- [ ] Verify winget package IDs exist: `winget search "package.id"`
- [ ] Validate JSON files: `python -c "import json; json.load(open('codebytes.omp.json'))"`
- [ ] Test on Windows 11 VM if possible
- [ ] Update README.md if functionality changes

## Limitations in Non-Windows Environments

**DO NOT attempt these operations on Linux/macOS**:
- Running boot.ps1 directly
- Testing winget commands
- Testing Windows registry modifications
- Testing Windows Defender settings
- Testing WSL installation

**You CAN do these operations**:
- Syntax validation with pwsh
- YAML/JSON validation with python
- Code review and logical analysis
- Documentation updates

## Time Expectations

- **Syntax validation**: 5 seconds
- **Full execution**: 15-30 minutes (Windows only)
- **Manual verification**: 5-10 minutes (Windows only)

**CRITICAL**: Always set timeouts of 45+ minutes for full script execution.
