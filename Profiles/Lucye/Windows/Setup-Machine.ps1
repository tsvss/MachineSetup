# Setup-Machine.ps1
# Comprehensive "Zero-Touch" Machine Setup Script for Windows PowerShell 5.1
# Targets: .NET 10, Java, Node.js, Angular, Gemini CLI, Google Drive, WSL (Zsh/Oh My Zsh)

$ErrorActionPreference = "Stop"

# --- Helper Functions ---

function Check-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Warning "This script must be run as Administrator."
        exit 1
    }
}

function Install-Choco {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Chocolatey..." -ForegroundColor Cyan
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    } else {
        Write-Host "Chocolatey already installed." -ForegroundColor Green
    }
}

function Install-WingetApp {
    param([string]$Id, [string]$Name)
    Write-Host "Checking $Name ($Id)..." -ForegroundColor Cyan
    # winget list can be slow/unreliable in some environments, so we try-catch the install
    # --accept-package-agreements and --accept-source-agreements are critical for zero-touch
    winget install --id $Id -e --accept-package-agreements --accept-source-agreements --silent
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully processed $Name." -ForegroundColor Green
    }
}

function Install-Fonts {
    Write-Host "Installing Cascadia Code Nerd Fonts..." -ForegroundColor Cyan
    $fontPath = Join-Path $PSScriptRoot "Fonts\CascadiaCode"
    if (Test-Path $fontPath) {
        $fonts = Get-ChildItem -Path $fontPath -Filter "*.ttf"
        $shellApp = New-Object -ComObject Shell.Application
        $fontFolder = $shellApp.Namespace(0x14) # 0x14 is the Fonts folder
        foreach ($font in $fonts) {
            $dest = Join-Path "C:\Windows\Fonts" $font.Name
            if (-not (Test-Path $dest)) {
                Write-Host "Installing font: $($font.Name)" -ForegroundColor Yellow
                $fontFolder.CopyHere($font.FullName, 0x10) # 0x10 is "Yes to all"
            }
        }
    } else {
        Write-Warning "Font path not found: $fontPath"
    }
}

function Configure-VSCode {
    Write-Host "Configuring VS Code settings..." -ForegroundColor Cyan
    $vscodeSettingsPath = "$env:APPDATA\Code\User\settings.json"
    $sourceSettings = Join-Path $PSScriptRoot "vsCodeSetup\settings.json"
    if (Test-Path $sourceSettings) {
        $vscodeDir = Split-Path $vscodeSettingsPath -Parent
        if (-not (Test-Path $vscodeDir)) { New-Item -ItemType Directory -Path $vscodeDir -Force }
        Copy-Item $sourceSettings -Destination $vscodeSettingsPath -Force
        Write-Host "VS Code settings applied." -ForegroundColor Green
    }
}

function Configure-Git {
    Write-Host "Configuring Git..." -ForegroundColor Cyan
    # Instead of running external .cmd, we do it directly for better control
    git config --global user.name "Satya"
    git config --global user.email "venkata.satya2910@gmail.com"
    git config --global push.default current
    git config --global push.autoSetupRemote true
    git config --global pull.rebase true
    git config --global core.editor "code --wait"
    git config --global init.defaultBranch main
    Write-Host "Git configuration applied." -ForegroundColor Green
}

# --- Main Execution ---

Check-Admin
Install-Choco

# --- Core Runtimes & Tools ---
$apps = @(
    @{ Id = "Git.Git"; Name = "Git" }
    @{ Id = "GitHub.cli"; Name = "GitHub CLI" }
    @{ Id = "GitHub.GitHubDesktop"; Name = "GitHub Desktop" }
    @{ Id = "Microsoft.VisualStudioCode"; Name = "VS Code" }
    @{ Id = "Docker.DockerDesktop"; Name = "Docker Desktop" }
    @{ Id = "Canonical.Ubuntu.24.04"; Name = "WSL Ubuntu" }
    @{ Id = "GoLang.Go"; Name = "GoLang" }
    @{ Id = "Python.Python.3.12"; Name = "Python 3.12" }
    @{ Id = "Microsoft.DotNet.SDK.10"; Name = ".NET 10 SDK" }
    @{ Id = "Amazon.Corretto.25.JDK"; Name = "Java (Amazon Corretto 25)" }
    @{ Id = "Google.GoogleDrive"; Name = "Google Drive" }
    
    # --- Cloud & DevOps ---
    @{ Id = "Microsoft.AzureCLI"; Name = "Azure CLI" }
    @{ Id = "Amazon.AWSCLI"; Name = "AWS CLI" }
    @{ Id = "Hashicorp.Terraform"; Name = "Terraform" }
    @{ Id = "Kubernetes.kubectl"; Name = "Kubectl" }
    @{ Id = "Helm.Helm"; Name = "Helm" }

    # --- Productivity & Utilities ---
    @{ Id = "AgileBits.1Password"; Name = "1Password" }
    @{ Id = "Google.Antigravity"; Name = "Google Antigravity" }
    @{ Id = "Google.Chrome"; Name = "Google Chrome" }
    @{ Id = "Warp.Warp"; Name = "Warp" }
    @{ Id = "Obsidian.Obsidian"; Name = "Obsidian" }
    @{ Id = "Ollama.Ollama"; Name = "Ollama" }
    @{ Id = "Microsoft.PowerToys"; Name = "PowerToys" }
    @{ Id = "JanDeDobbeleer.OhMyPosh"; Name = "Oh My Posh" }
    @{ Id = "Postman.Postman"; Name = "Postman" }
    @{ Id = "7zip.7zip"; Name = "7-Zip" }
    @{ Id = "Notepad++.Notepad++"; Name = "Notepad++" }
    @{ Id = "WinMerge.WinMerge"; Name = "WinMerge" }
)

foreach ($app in $apps) {
    Install-WingetApp -Id $app.Id -Name $app.Name
}

# --- Choco Apps (fnm) ---
Write-Host "Installing fnm via Chocolatey..." -ForegroundColor Cyan
choco install fnm -y

# --- Global Tools (Node) ---
Write-Host "Installing Global Tools (Node, Angular, Gemini CLI)..." -ForegroundColor Cyan
$env:PATH += ";$env:APPDATA\fnm"
& fnm install --latest
& fnm use default

# Angular CLI
Write-Host "Installing Angular CLI..." -ForegroundColor Yellow
& npm install -g @angular/cli

# Gemini CLI
Write-Host "Installing Gemini CLI..." -ForegroundColor Yellow
& npm install -g @google/gemini-cli

# --- Component Configurations ---
Install-Fonts
Configure-VSCode
Configure-Git

# Terminal & Profile
Push-Location .\TerminalSetup
& .\Setup-Terminal.ps1
Pop-Location

# --- WSL Setup ---
Write-Host "Configuring WSL Ubuntu..." -ForegroundColor Cyan
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    $distro = wsl --list --quiet | Select-String "Ubuntu"
    if ($distro) {
        Write-Host "Installing Zsh and Oh My Zsh in WSL Ubuntu..." -ForegroundColor Yellow
        
        # Prepare WSL setup script
        $wslSetupScript = Join-Path $PSScriptRoot "wsl-setup.sh"
        $wslPath = "\\wsl.localhost\Ubuntu\home\$($env:USERNAME)"
        
        if (Test-Path $wslPath) {
            Copy-Item $wslSetupScript -Destination "$wslPath/.wsl-setup.sh"
            Copy-Item ".\TerminalSetup\ConfigFiles\oh-my-posh-theme.json" -Destination "$wslPath/.oh-my-posh-theme.json"
            
            # Use WSL command to install zsh, oh-my-zsh and configure
            wsl -u root apt update
            wsl -u root apt install -y zsh curl git
            
            # Install Oh My Zsh for the user if not exists
            wsl -u $($env:USERNAME) sh -c 'if [ ! -d ~/.oh-my-zsh ]; then sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; fi'
            
            # Change shell to zsh
            wsl -u root chsh -s /usr/bin/zsh $($env:USERNAME)
            
            # Inject source command into .zshrc
            wsl -u $($env:USERNAME) sh -c 'if ! grep -q ".wsl-setup.sh" ~/.zshrc; then echo "source ~/.wsl-setup.sh" >> ~/.zshrc; fi'
            
            # Install Node/Angular in WSL via fnm (WSL version)
            wsl -u $($env:USERNAME) sh -c 'curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell'
            wsl -u $($env:USERNAME) zsh -c 'source ~/.zshrc && fnm install --latest && fnm use default && npm install -g @angular/cli @google/gemini-cli'
            
            Write-Host "WSL Ubuntu configured with Zsh, Oh My Zsh, and Dev Tools." -ForegroundColor Green
        }
    }
}

Write-Host "`n✅ Setup Complete! Please restart your terminal." -ForegroundColor Green
