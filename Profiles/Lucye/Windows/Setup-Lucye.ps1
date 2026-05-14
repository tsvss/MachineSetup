# Setup-Lucye.ps1
# 🧙‍♂️ The Lucye Machine Setup - A Wizarding World Experience
# Targets: .NET 10, Java, Node.js, Angular, Gemini CLI, Google Drive, WSL (Zsh/Oh My Zsh)

$ErrorActionPreference = "Stop"

# --- Elevation Logic ---
function Check-MuggleStatus {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Host "✨ Ministry Authorization required. Elevating script..." -ForegroundColor Cyan
        $arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
        Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command $arguments"
        exit
    }
}

function Show-Header {
    Clear-Host
    Write-Host @"
    
    .     .       .  .   . .   .   . .    +  .
      .     .  :     .    .. :. .___---------___.
           .  .   .    .  :.:. _".^ .^ ^.  '.. :"-_.
        .    .   .  .  .: :.. /| |  . . .^ ^  .^  | |
              .   .:::.::. ::\| | :  . .  .  .  : | |
         .   .   .:...:.:. .| | ^ .  . .^ ^  .^  | |
                ..:..:.. . .| |   .  .  .  .  .  | |
          .    :..:..:..:.. . \_  .  .  . ^  .  _/
               . `.:."`.;.`._ ^ _"-__..--__-"_  ^
        .       .. .. .. .. .. ..  ..  ..  ..
    
    🪄  WELCOME TO THE LUCYE MACHINE SETUP WIZARD  🪄
    "Happiness can be found even in the darkest of times, 
     if one only remembers to turn on the terminal."
"@ -ForegroundColor Yellow
}

function Cast-Spell {
    param([string]$Message)
    Write-Host "`n✨ Casting Spell: $Message..." -ForegroundColor Cyan
    Start-Sleep -Milliseconds 500
}

function Enable-MagicalFeatures {
    Cast-Spell "Enabling Windows Features (WSL, VirtualMachinePlatform, Hyper-V)"
    # Enable WSL and Virtual Machine Platform
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    
    # Try enabling Hyper-V (might fail on Home, but that's okay)
    dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V -All /LimitAccess /ALL /norestart
}

function Summon-Chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Cast-Spell "Summoning Chocolatey Package Manager"
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
}

function Transfigure-App {
    param([string]$Id, [string]$Name, [string]$Override)
    Write-Host "📜 Preparing scroll for $Name..." -ForegroundColor Gray
    if ($Override) {
        & winget install --id $Id -e --accept-package-agreements --accept-source-agreements --silent --override $Override
    } else {
        & winget install --id $Id -e --accept-package-agreements --accept-source-agreements --silent
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ $Name has been summoned successfully." -ForegroundColor Green
    } else {
        Write-Host "⚠️  $Name summon status code: $LASTEXITCODE" -ForegroundColor Yellow
    }
}

# --- Execution ---

Check-MuggleStatus
Show-Header
Enable-MagicalFeatures
Summon-Chocolatey

Cast-Spell "Summoning the Core Artifacts"
$apps = @(
    @{ Id = "Git.Git"; Name = "Git (The Map)" }
    @{ Id = "GitHub.cli"; Name = "GitHub CLI (The Owl)" }
    @{ Id = "GitHub.GitHubDesktop"; Name = "GitHub Desktop" }
    @{ Id = "Microsoft.VisualStudioCode"; Name = "VS Code (The Pensieve)"; Override = '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders"' }
    @{ Id = "Docker.DockerDesktop"; Name = "Docker (The Suitcase)" }
    @{ Id = "Canonical.Ubuntu.24.04"; Name = "WSL Ubuntu (The Hidden Room)" }
    @{ Id = "Microsoft.DotNet.SDK.10"; Name = ".NET 10 (The Elder Wand)" }
    @{ Id = "Amazon.Corretto.25.JDK"; Name = "Java (The Ancient Script)" }
    @{ Id = "Google.GoogleDrive"; Name = "Google Drive (The Gringotts Vault)" }
    @{ Id = "AgileBits.1Password"; Name = "1Password (The Secret Keeper)" }
    @{ Id = "Warp.Warp"; Name = "Warp Terminal (The Portkey)" }
    @{ Id = "Postman.Postman"; Name = "Postman" }
    @{ Id = "GnuPG.Gpg4win"; Name = "Gpg4win" }
    @{ Id = "WinMerge.WinMerge"; Name = "WinMerge" }
    @{ Id = "Notepad++.Notepad++"; Name = "Notepad++" }
    @{ Id = "Microsoft.PowerToys"; Name = "PowerToys" }
    @{ Id = "Google.Chrome"; Name = "Google Chrome" }
    @{ Id = "7zip.7zip"; Name = "7-Zip" }
    @{ Id = "Ollama.Ollama"; Name = "Ollama" }
    @{ Id = "Obsidian.Obsidian"; Name = "Obsidian" }
    @{ Id = "JanDeDobbeleer.OhMyPosh"; Name = "Oh My Posh" }
    @{ Id = "VideoLAN.VLC"; Name = "VLC" }
    @{ Id = "Zoom.Zoom"; Name = "Zoom" }
)

foreach ($app in $apps) {
    Transfigure-App -Id $app.Id -Name $app.Name -Override $app.Override
}

Cast-Spell "Brewing Node.js Potions (Angular & Gemini CLI)"
choco install fnm -y
$env:PATH += ";$env:APPDATA\fnm"
& fnm install --latest
& fnm use default
& npm install -g @angular/cli @google/gemini-cli

Cast-Spell "Learning Terminal Charms (z, Terminal-Icons)"
if (-not (Get-Module -ListAvailable Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force -SkipPublisherCheck
}
if (-not (Get-Module -ListAvailable z)) {
    Install-Module -Name z -Repository PSGallery -Force -SkipPublisherCheck
}

Cast-Spell "Enchanting the Environment (Fonts, VS Code, Git)"
$repoRoot = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName
& "$repoRoot\Scripts\Install-Fonts.ps1"
& "$repoRoot\Scripts\Configure-Configs.ps1"

Cast-Spell "Installing VS Code Extensions"
$extensions = @(
    "dracula-theme.theme-dracula",      # Theme
    "amazonwebservices.amazon-q-vscode", # Amazon Q Developer
    "ms-dotnettools.csdevkit",          # C# Dev Kit (Modern standard)
    "ms-dotnettools.csharp",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "aaron-bond.better-comments",
    "formulahendry.auto-rename-tag",
    "naumovs.color-highlight",
    "anteprimorac.html-end-tag-labels",
    "github.vscode-pull-request-github",
    "eamodio.gitlens",                  # Stable version
    "angular.ng-template",
    "ms-playwright.playwright",
    "yzhang.markdown-all-in-one",
    "davidanson.vscode-markdownlint",
    "rangav.vscode-thunder-client"
)
foreach ($ext in $extensions) {
    Write-Host "Installing extension: $ext" -ForegroundColor Gray
    & code --install-extension $ext --force
}

Cast-Spell "Enchanting Notepad++ with Dracula Theme"
$nppThemeDir = "$env:APPDATA\Notepad++\themes"
if (Test-Path $nppThemeDir) {
    $draculaUrl = "https://raw.githubusercontent.com/dracula/notepad-plus-plus/master/generated/Dracula.xml"
    $destFile = Join-Path $nppThemeDir "Dracula.xml"
    Invoke-WebRequest -Uri $draculaUrl -OutFile $destFile
    
    $nppConfig = "$env:APPDATA\Notepad++\config.xml"
    if (Test-Path $nppConfig) {
        $xml = [xml](Get-Content $nppConfig)
        $stylerTheme = $xml.NotepadPlus.GUIConfig | Where-Object { $_.name -eq "stylerTheme" }
        if ($stylerTheme) {
            $stylerTheme.path = $destFile
            $xml.Save($nppConfig)
            Write-Host "Dracula theme applied to Notepad++ config." -ForegroundColor Green
        }
    }
}

Cast-Spell "Opening the Chamber of Secrets (WSL Setup)"
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    $distro = wsl --list --quiet | Select-String "Ubuntu"
    if ($distro) {
        Write-Host "Configuring WSL Ubuntu with Zsh and Oh My Zsh..." -ForegroundColor Yellow
        
        $wslSetupScript = Join-Path $repoRoot "Profiles\Lucye\WSL\wsl-setup.sh"
        $wslPath = "\\wsl.localhost\Ubuntu\home\$($env:USERNAME)"
        
        if (Test-Path $wslPath) {
            Copy-Item $wslSetupScript -Destination "$wslPath/.wsl-setup.sh"
            Copy-Item "$repoRoot\Shared\TerminalSetup\ConfigFiles\oh-my-posh-theme.json" -Destination "$wslPath/.oh-my-posh-theme.json"
            
            # Use WSL command to install zsh, oh-my-zsh and configure
            wsl -u root apt update
            wsl -u root apt install -y zsh curl git
            
            # Install Oh My Zsh for the user if not exists
            wsl -u $($env:USERNAME) sh -c 'if [ ! -d ~/.oh-my-zsh ]; then sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; fi'
            
            # Change shell to zsh
            wsl -u root chsh -s /usr/bin/zsh $($env:USERNAME)
            
            # Inject source command into .zshrc
            wsl -u $($env:USERNAME) sh -c 'if ! grep -q ".wsl-setup.sh" ~/.zshrc; then echo "source ~/.wsl-setup.sh" >> ~/.zshrc; fi'
            
            # Install Node/Angular/Gemini CLI in WSL via fnm (WSL version)
            wsl -u $($env:USERNAME) sh -c 'curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell'
            wsl -u $($env:USERNAME) zsh -c 'source ~/.zshrc && fnm install --latest && fnm use default && npm install -g @angular/cli @google/gemini-cli'
            
            Write-Host "WSL Ubuntu configured successfully." -ForegroundColor Green
        }
    }
}

Write-Host "`n🎆 ALL SPELLS CAST SUCCESSFULLY! YOUR LUCYE MACHINE IS READY. 🎆" -ForegroundColor Green
Write-Host "Please restart your terminal to let the magic take effect." -ForegroundColor Yellow
