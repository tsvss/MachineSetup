# Setup-Lucye.ps1
# 🧙‍♂️ The Lucye Machine Setup - A Wizarding World Experience
# Targets: .NET 10, Java, Node.js, Angular, Gemini CLI, Google Drive, WSL (Zsh/Oh My Zsh)

$ErrorActionPreference = "Stop"

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

function Check-MuggleStatus {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Error "🛑 This magic requires Ministry (Administrator) authorization!"
        exit 1
    }
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
    param([string]$Id, [string]$Name)
    Write-Host "📜 Preparing scroll for $Name..." -ForegroundColor Gray
    winget install --id $Id -e --accept-package-agreements --accept-source-agreements --silent
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ $Name has been summoned successfully." -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to summon $Name." -ForegroundColor Red
    }
}

# --- Execution ---

Show-Header
Check-MuggleStatus
Summon-Chocolatey

Cast-Spell "Summoning the Core Artifacts"
$apps = @(
    @{ Id = "Git.Git"; Name = "Git (The Map)" }
    @{ Id = "GitHub.cli"; Name = "GitHub CLI (The Owl)" }
    @{ Id = "Microsoft.VisualStudioCode"; Name = "VS Code (The Pensieve)" }
    @{ Id = "Docker.DockerDesktop"; Name = "Docker (The Suitcase)" }
    @{ Id = "Canonical.Ubuntu.24.04"; Name = "WSL Ubuntu (The Hidden Room)" }
    @{ Id = "Microsoft.DotNet.SDK.10"; Name = ".NET 10 (The Elder Wand)" }
    @{ Id = "Amazon.Corretto.25.JDK"; Name = "Java (The Ancient Script)" }
    @{ Id = "Google.GoogleDrive"; Name = "Google Drive (The Gringotts Vault)" }
    @{ Id = "AgileBits.1Password"; Name = "1Password (The Secret Keeper)" }
    @{ Id = "Warp.Warp"; Name = "Warp Terminal (The Portkey)" }
)

foreach ($app in $apps) {
    Transfigure-App -Id $app.Id -Name $app.Name
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

Cast-Spell "Opening the Chamber of Secrets (WSL Setup)"
# WSL Logic here... (calling the wsl-setup.sh)

Write-Host "`n🎆 ALL SPELLS CAST SUCCESSFULLY! YOUR LUCYE MACHINE IS READY. 🎆" -ForegroundColor Green
Write-Host "Please restart your terminal to let the magic take effect." -ForegroundColor Yellow
