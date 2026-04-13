# Windows 11 Setup Scripts

Declarative Windows 11 machine setup using [WinGet DSC](https://learn.microsoft.com/en-us/windows/package-manager/configuration/) (Desired State Configuration). Inspired by [Scott Hanselman's wingetdevsetup](https://github.com/shanselman/wingetdevsetup).

## Quick Start

### One-command install (recommended)

Open PowerShell as Administrator and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; $script = Join-Path $env:TEMP 'windows-setup-boot.ps1'; irm 'https://raw.githubusercontent.com/codebytes/windows-setup/main/boot.ps1' | Set-Content -Path $script -Encoding UTF8; & $script
```

### Backward-compatible one-liner

The original `script.ps1` URL still works — it delegates to `boot.ps1`:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; $script = Join-Path $env:TEMP 'windows-setup.ps1'; irm 'https://raw.githubusercontent.com/codebytes/windows-setup/main/script.ps1' | Set-Content -Path $script -Encoding UTF8; & $script
```

## How It Works

The setup uses **WinGet DSC** — a declarative YAML configuration that describes the desired state of your machine. WinGet handles the idempotent install/configure logic.

### `boot.ps1`

The bootstrapper script that:

1. Self-elevates to Administrator
2. Ensures WinGet is installed and up to date (using `Repair-WinGetPackageManager` with manual fallback)
3. Enables `winget configure`
4. Runs the DSC configuration from `codebytes.dev.dsc.yml`
5. Shows next steps

### `codebytes.dev.dsc.yml`

The declarative configuration that installs and configures everything:

| Category | Tools |
|---|---|
| **Git & GitHub** | Git, GitHub CLI, GitHub Desktop, GitHub Copilot CLI |
| **Editors** | VS Code, Visual Studio Community 2022 (+ .vsconfig workloads) |
| **Runtimes & SDKs** | .NET 8, .NET 9, Python 3.12, Node.js |
| **Containers** | Docker Desktop |
| **Terminal & Shell** | Windows Terminal, PowerShell 7, Oh My Posh |
| **WSL** | WSL + Ubuntu 24.04 |
| **Dev Tools** | JetBrains Toolbox, UniGetUI, LINQPad 8, Azure CLI, Azure Developer CLI, Postman, Obsidian |
| **Daily Apps** | Google Chrome, Slack, QuickLook, PowerToys |
| **Windows Settings** | Show file extensions, hide taskbar widgets |
| **Security** | PUA protection, disable autoplay/autorun/delivery optimization |
| **Personalization** | Dev Drive (D:), PowerShell profile, Oh My Posh theme, Nerd Fonts |

### Post-Setup

After the DSC configuration completes:

```powershell
# 1. Authenticate with GitHub
gh auth login

# 2. Clone your repos
.\clone-repos.ps1

# 3. Restart your computer
Restart-Computer
```

## Repository Structure

```
├── boot.ps1                  # Main bootstrapper (admin elevation + WinGet + DSC)
├── codebytes.dev.dsc.yml     # Declarative DSC configuration (all packages + settings)
├── codebytes.omp.json        # Oh My Posh theme
├── clone-repos.ps1           # Clone personal repos after gh auth
├── .vsconfig                 # Visual Studio workload configuration
├── script.ps1                # Backward-compat wrapper → boot.ps1
├── install-dev-tools.ps1     # Backward-compat wrapper → boot.ps1
└── README.md
```

## Customizing

### Adding packages

Add a new `WinGetPackage` resource to `codebytes.dev.dsc.yml`:

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

Find the winget package ID with `winget search "App Name"`.

### Adding repos to clone

Edit the `$repos` array in `clone-repos.ps1`.

### Changing the Oh My Posh theme

Edit `codebytes.omp.json` — the DSC configuration downloads it during setup.

### Changing Visual Studio workloads

Edit `.vsconfig` — the DSC configuration applies it after VS installs.

### Removing bloatware

Edit the package list in the `RemoveBloatware` script block inside `codebytes.dev.dsc.yml`.

## Local Usage

```powershell
# Run the full setup
.\boot.ps1

# Or use the backward-compat entrypoints
.\script.ps1
.\install-dev-tools.ps1
```

## Notes

- **Windows 11 only** — uses Windows-specific PowerShell cmdlets and WinGet DSC
- **Administrator required** — `boot.ps1` self-elevates automatically
- **WinGet required** — if missing, the bootstrapper installs it automatically
- **Dev Drive** — creates a 50 GB ReFS Dev Drive on D: (only if D: doesn't already exist)
- **Idempotent** — safe to re-run; WinGet DSC skips already-installed packages
