# Windows 11 Setup Scripts

This repository contains PowerShell scripts to setup `Windows 11` for development and general use.  
**Note:** _You can modify the scripts to fit your own requirements._

## Scripts Available

### 1. Complete Windows Setup (`script.ps1`)

Comprehensive Windows 11 setup script that configures the entire system.

#### Installation

If you already have `Windows 11`, run these commands in `PowerShell`:

```
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/samuelramox/windows-setup/master/script.ps1'))
```

### 2. Development Tools Installation (`install-dev-tools.ps1`)

**NEW:** Focused script for installing essential development tools using winget.

#### Quick Installation

```powershell
# Download and run the development tools installer
iwr -useb https://raw.githubusercontent.com/codebytes/windows-setup/main/install-dev-tools.ps1 | iex
```

#### Manual Installation

1. Download the script:
   ```powershell
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/codebytes/windows-setup/main/install-dev-tools.ps1" -OutFile "install-dev-tools.ps1"
   ```

2. Run the script:
   ```powershell
   .\install-dev-tools.ps1
   ```

3. To skip WSL installation:
   ```powershell
   .\install-dev-tools.ps1 -SkipWSL
   ```

#### Development Tools Included

- **Visual Studio Code** - Lightweight code editor
- **Visual Studio Community 2022** - Full-featured IDE
- **GitHub CLI** - Command-line interface for GitHub
- **GitHub Desktop** - Git GUI client
- **Docker Desktop** - Containerization platform
- **.NET 8 SDK** - .NET development framework
- **Python 3.12** - Python programming language
- **Node.js** - JavaScript runtime (includes npm)
- **LinqPad 7** - .NET code scratchpad
- **WSL** - Windows Subsystem for Linux

#### Features

- ✅ **Smart Installation Checks** - Skips already installed tools
- ✅ **Error Handling** - Comprehensive error reporting and recovery
- ✅ **Informative Output** - Clear progress indicators and status messages
- ✅ **Interactive** - Prompts for confirmation and restart
- ✅ **Well Documented** - Extensive comments and help documentation

## Complete Windows Setup Script (`script.ps1`)

The original comprehensive setup script performs the following actions:

- Remove a few pre-installed `UWP` applications:
  - Disney.37853FC22B2CE
  - Microsoft.BingNews
  - Microsoft.GetHelp
  - Microsoft.Getstarted
  - Microsoft.MicrosoftSolitaireCollection
  - Microsoft.MicrosoftOfficeHub
  - Microsoft.WindowsFeedbackHub
  - SpotifyAB.SpotifyMusic
- Install `Winget` and some apps:
  - [Git](https://gitforwindows.org/)
  - [Google Chrome](https://www.google.com/chrome/)
  - [Oh My Posh](https://ohmyposh.dev)
  - [Postman](https://www.postman.com)
  - [PowerToys](https://github.com/microsoft/PowerToys)
  - [QuickLook](https://pooi.moe/QuickLook/)
  - [Slack](https://slack.com/intl/pt-br/)
  - [Visual Studio Code](https://chocolatey.org/packages/vscode)
- Enable PUA Protection
- Disable Autoplay
- Disable Autorun for all drives
- Disable Windows Update P2P delivery optimization (WUDO) completely
- Install WSL
- Install Nerd Font via OhMyPosh

## Manual setup after installation (optional)

### Enable clipboard history

Open the `Settings` app and go to the `System group of settings`. Select the `Clipboard` tab, and turn on `Clipboard History`.

### Block non-Store apps

Settings -> Apps -> Apps & features -> The Microsoft Store only (recommended).
**Note:** _I only do this when I've installed everything I need._
