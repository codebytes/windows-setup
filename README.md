# Windows 11 Setup Scripts

[![Windows 11](https://img.shields.io/badge/Windows-11-0078D4?logo=windows11)](https://www.microsoft.com/windows/windows-11)
[![WinGet DSC](https://img.shields.io/badge/WinGet-DSC-blue)](https://learn.microsoft.com/en-us/windows/package-manager/configuration/)

Declarative Windows 11 machine setup using [WinGet DSC](https://learn.microsoft.com/en-us/windows/package-manager/configuration/) (Desired State Configuration). One command to go from a fresh Windows install to a fully configured dev machine.

Inspired by [Scott Hanselman's wingetdevsetup](https://github.com/shanselman/wingetdevsetup).

## Quick Start

### Remote — one command from a fresh machine

Open **PowerShell** and paste:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; $script = Join-Path $env:TEMP 'windows-setup-boot.ps1'; irm 'https://raw.githubusercontent.com/codebytes/windows-setup/main/boot.ps1' | Set-Content -Path $script -Encoding UTF8; & $script
```

> The script self-elevates to Administrator — you'll see a UAC prompt if you're not already elevated.

### Local — from a cloned repo

```powershell
git clone https://github.com/codebytes/windows-setup.git
cd windows-setup
.\boot.ps1
```

## What Gets Installed

The DSC configuration (`codebytes.dev.dsc.yml`) sets up everything in one pass:

| Category | What's included |
|---|---|
| **Git & GitHub** | Git, GitHub CLI, GitHub Desktop, GitHub Copilot CLI |
| **Editors** | VS Code, Visual Studio Community 2022 (with [.vsconfig](.vsconfig) workloads) |
| **Runtimes & SDKs** | .NET 8, .NET 9, Python 3.12, Node.js |
| **Containers** | Docker Desktop |
| **Terminal & Shell** | Windows Terminal, PowerShell 7, Oh My Posh |
| **WSL** | WSL + Ubuntu 24.04 |
| **Dev Tools** | JetBrains Toolbox, UniGetUI, LINQPad 8, Azure CLI, Azure Developer CLI, Postman, Obsidian |
| **Daily Apps** | Google Chrome, Slack, QuickLook, PowerToys |
| **Windows Settings** | Show file extensions, hide taskbar widgets |
| **Security** | PUA protection, disable autoplay/autorun/delivery optimization |
| **Personalization** | Dev Drive on D:, Oh My Posh theme, CascadiaCode + Meslo Nerd Fonts, PowerShell profile |

## How It Works

```
boot.ps1                          ← you run this
  ├─ Self-elevates to Admin
  ├─ Installs / repairs WinGet
  ├─ Enables winget configure
  └─ Runs: winget configuration -f codebytes.dev.dsc.yml
                                    ↑
                        Declarative YAML that WinGet
                        processes resource-by-resource
```

**WinGet DSC** is a declarative configuration engine built into WinGet. You describe the desired state of your machine in YAML, and WinGet makes it so — installing packages, applying settings, and running scripts as needed. Resources that are already in the desired state are skipped automatically.

## After Setup

When the DSC run completes, `boot.ps1` prints these next steps:

```powershell
# 1. Authenticate with GitHub
gh auth login

# 2. Clone your repos to D:\github (or ~/source/repos if no Dev Drive)
.\clone-repos.ps1

# 3. Restart to finish WSL, Visual Studio, and other pending installs
Restart-Computer
```

## Repository Structure

```
├── boot.ps1                  # Bootstrapper: admin elevation → WinGet repair → DSC run
├── codebytes.dev.dsc.yml     # Declarative DSC config (packages, settings, scripts)
├── codebytes.omp.json        # Oh My Posh prompt theme
├── clone-repos.ps1           # Clone personal GitHub repos via gh CLI
├── .vsconfig                 # Visual Studio workload/component selection
├── script.ps1                # Backward-compat wrapper (delegates to boot.ps1)
├── install-dev-tools.ps1     # Backward-compat wrapper (delegates to boot.ps1)
└── README.md
```

## Customizing

### Add a package

1. Find the winget ID: `winget search "App Name"`
2. Add a block to `codebytes.dev.dsc.yml`:

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

### Remove a package

Delete its resource block from `codebytes.dev.dsc.yml`.

### Change Visual Studio workloads

Edit [`.vsconfig`](.vsconfig) — the DSC configuration applies it after VS installs. You can export your current workloads from the VS Installer → More → Export configuration.

### Change the Oh My Posh theme

Edit [`codebytes.omp.json`](codebytes.omp.json). The DSC profile setup downloads it at `$HOME/codebytes.$COMPUTERNAME.omp.json` during setup.

### Change which repos get cloned

Edit the `$repos` array in [`clone-repos.ps1`](clone-repos.ps1).

### Change bloatware removal list

Edit the package names in the `RemoveBloatware` script block inside `codebytes.dev.dsc.yml`. To list installed UWP apps:

```powershell
Get-AppxPackage | Select-Object Name | Sort-Object Name
```

## Backward Compatibility

The original one-liner URLs still work. Both `script.ps1` and `install-dev-tools.ps1` now delegate to `boot.ps1`:

```powershell
# These still work — they fetch and run boot.ps1 under the hood
Set-ExecutionPolicy Bypass -Scope Process -Force; $script = Join-Path $env:TEMP 'windows-setup.ps1'; irm 'https://raw.githubusercontent.com/codebytes/windows-setup/main/script.ps1' | Set-Content -Path $script -Encoding UTF8; & $script
```

## Requirements

| Requirement | Details |
|---|---|
| **OS** | Windows 11 |
| **PowerShell** | 5.1+ (built in) |
| **Admin** | Script self-elevates via UAC |
| **WinGet** | Installed/repaired automatically by `boot.ps1` |
| **Internet** | Required for package downloads and DSC config fetch |

## Dev Drive

The DSC configuration creates a 50 GB [Dev Drive](https://learn.microsoft.com/en-us/windows/dev-drive/) on **D:** using ReFS. This is a performance-optimized volume for developer workloads.

- If D: already exists, the Dev Drive step is skipped (non-destructive)
- `clone-repos.ps1` clones to `D:\github` when available, otherwise falls back to `~/source/repos`

## FAQ

**Can I re-run it safely?**
Yes. WinGet DSC is idempotent — already-installed packages and applied settings are skipped.

**What if I don't want everything?**
Fork the repo and remove resource blocks from `codebytes.dev.dsc.yml`. Each block is self-contained.

**What if WinGet isn't installed?**
`boot.ps1` handles this automatically using `Repair-WinGetPackageManager`, with a manual fallback that downloads the required dependencies.

**How long does it take?**
15–30 minutes on a fresh machine depending on internet speed. Re-runs are much faster since most packages get skipped.
