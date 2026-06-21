# Setup-Lucye.ps1
# ðŸ§™â€â™‚ï¸ The Lucye Machine Setup - A Wizarding World Experience
# Targets: .NET 10, Java, Node.js, Angular, Gemini CLI, Google Drive, WSL (Zsh/Oh My Zsh)

$ErrorActionPreference = "Stop"

# --- Elevation Logic ---
function Check-MuggleStatus {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Host "âœ¨ Ministry Authorization required. Elevating script..." -ForegroundColor Cyan
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$($PSCommandPath)`""
        Start-Process powershell -Verb runAs -ArgumentList $arguments
        exit
    }
}

# --- Impeccable UX: Chimes & Progress ---
function Play-Chime {
    param([int]$Type = 1)
    if ($Type -eq 1) { [Console]::Beep(440, 200); [Console]::Beep(659, 200); [Console]::Beep(880, 200) } # Success
    else { [Console]::Beep(220, 500) } # Error/Wait
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
    
    ðŸª„  WELCOME TO THE LUCYE MACHINE SETUP WIZARD  ðŸª„
    "Happiness can be found even in the darkest of times, 
     if one only remembers to turn on the terminal."
"@ -ForegroundColor Yellow
}

function Cast-Spell {
    param([string]$Message)
    Write-Host "`nâœ¨ Casting Spell: $Message..." -ForegroundColor Cyan
    Start-Sleep -Milliseconds 500
}

# --- Auto-Resume Magic ---
function Set-AutoResume {
    Cast-Spell "Preparing the Resurrection Stone (Auto-Resume after reboot)"
    $runOnceKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    $resumeCmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$($PSCommandPath)`" -Resumed"
    Set-ItemProperty -Path $runOnceKey -Name "LucyeSetupResume" -Value $resumeCmd
}

function Clear-AutoResume {
    $runOnceKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    if (Get-ItemProperty -Path $runOnceKey -Name "LucyeSetupResume" -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $runOnceKey -Name "LucyeSetupResume"
    }
}

# --- WSL & Features ---
function Enable-MagicalFeatures {
    $rebootNeeded = $false
    
    # Check if WSL is already operational
    if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
        Cast-Spell "Installing WSL Core Artifacts"
        wsl --install --no-distribution
        $rebootNeeded = $true
    }

    # Enable Hyper-V
    $hyperV = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -ErrorAction SilentlyContinue
    if ($hyperV -and $hyperV.State -ne 'Enabled') {
        Cast-Spell "Enabling Hyper-V (The Great Hall)"
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
        $rebootNeeded = $true
    }

    if ($rebootNeeded) {
        Set-AutoResume
        Play-Chime -Type 2
        Write-Host "`nðŸš¨ REBOOT REQUIRED: The environment must restart to solidify the magic." -ForegroundColor Yellow
        Write-Host "The setup will automatically resume once you log back in." -ForegroundColor Cyan
        $confirm = Read-Host "Restart now? (Y/N)"
        if ($confirm -eq 'Y') { Restart-Computer }
        else { Write-Host "Please restart manually to continue the setup."; exit }
    }
}

function Transfigure-App {
    param([string]$Id, [string]$Name, [string]$Override)
    Write-Host "ðŸ“œ Preparing scroll for $Name..." -ForegroundColor Gray
    if ($Override) {
        & winget install --id $Id -e --accept-package-agreements --accept-source-agreements --silent --override $Override
    } else {
        & winget install --id $Id -e --accept-package-agreements --accept-source-agreements --silent
    }
}

# --- Main Wizardry ---
param([switch]$Resumed)

Check-MuggleStatus
Show-Header

if (-not $Resumed) {
    Enable-MagicalFeatures
} else {
    Cast-Spell "Resuming from the Resurrection Stone... Welcome back!"
    Clear-AutoResume
}

# 1. Package Managers
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Cast-Spell "Summoning Chocolatey"
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# 2. Core Apps
Cast-Spell "Summoning the Core Artifacts"
$apps = @(
    @{ Id = "Git.Git"; Name = "Git" }
    @{ Id = "GitHub.cli"; Name = "GitHub CLI" }
    @{ Id = "Microsoft.VisualStudioCode"; Name = "VS Code"; Override = '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders"' }
    @{ Id = "Docker.DockerDesktop"; Name = "Docker" }
    @{ Id = "Canonical.Ubuntu.24.04"; Name = "WSL Ubuntu" }
    @{ Id = "Microsoft.DotNet.SDK.10"; Name = ".NET 10" }
    @{ Id = "Amazon.Corretto.25.JDK"; Name = "Java 25" }
    @{ Id = "Google.GoogleDrive"; Name = "Google Drive" }
    @{ Id = "AgileBits.1Password"; Name = "1Password" }
    @{ Id = "Warp.Warp"; Name = "Warp" }
    @{ Id = "Postman.Postman"; Name = "Postman" }
    @{ Id = "WinMerge.WinMerge"; Name = "WinMerge" }
    @{ Id = "Notepad++.Notepad++"; Name = "Notepad++" }
    @{ Id = "Microsoft.PowerToys"; Name = "PowerToys" }
    @{ Id = "Google.Chrome"; Name = "Google Chrome" }
    @{ Id = "7zip.7zip"; Name = "7-Zip" }
    @{ Id = "Ollama.Ollama"; Name = "Ollama" }
    @{ Id = "Obsidian.Obsidian"; Name = "Obsidian" }
    @{ Id = "JanDeDobbeleer.OhMyPosh"; Name = "Oh My Posh" }
    @{ Id = "Microsoft.PowerShell"; Name = "PowerShell 7" }
    @{ Id = "GitHub.GitHubDesktop"; Name = "GitHub Desktop" }
    @{ Id = "Python.Python.3.13"; Name = "Python 3.13" }
    @{ Id = "GoLang.Go"; Name = "Go" }
    @{ Id = "Amazon.AWSCLI"; Name = "AWS CLI" }
    @{ Id = "Kubernetes.minikube"; Name = "Minikube" }
    @{ Id = "Helm.Helm"; Name = "Helm" }
    @{ Id = "Anthropic.Claude"; Name = "Claude" }
    @{ Id = "Notion.Notion"; Name = "Notion" }
    @{ Id = "JetBrains.WebStorm"; Name = "WebStorm" }
    @{ Id = "GnuPG.Gpg4win"; Name = "Gpg4win" }
    @{ Id = "Microsoft.VisualStudio.Community"; Name = "Visual Studio 2026 Community" }
    @{ Id = "VideoLAN.VLC"; Name = "VLC" }
    @{ Id = "Microsoft.Teams"; Name = "Microsoft Teams" }
)

foreach ($app in $apps) {
    Transfigure-App -Id $app.Id -Name $app.Name -Override $app.Override
}

# 3. Fast Node Manager & Other Command Line Tools
Cast-Spell "Brewing Chocolatey Potions"
$chocoApps = @(
    @{ Id = "fnm"; Command = "fnm" }
    @{ Id = "jq"; Command = "jq" }
    @{ Id = "k3d"; Command = "k3d" }
    @{ Id = "k9s"; Command = "k9s" }
    @{ Id = "kubernetes-cli"; Command = "kubectl" }
    @{ Id = "terraform"; Command = "terraform" }
    @{ Id = "terraformer"; Command = "terraformer" }
)
foreach ($app in $chocoApps) {
    if (-not (Get-Command $app.Command -ErrorAction SilentlyContinue)) {
        choco install $app.Id -y
    }
}
$env:PATH += ";$env:APPDATA\fnm"
& fnm install --latest
& fnm use default
& npm install -g @angular/cli @google/gemini-cli

# 4. Configurations
Cast-Spell "Enchanting the Environment"
$repoRoot = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName
& "$repoRoot\Scripts\Install-Fonts.ps1"
& "$repoRoot\Scripts\Configure-Configs.ps1"

# 5. VS Code Extensions
Cast-Spell "Installing VS Code Extensions"
$extensions = @(
    "4ops.terraform",
    "aaron-bond.better-comments",
    "aliasadidev.nugetpackagemanagergui",
    "amazonwebservices.amazon-q-vscode",
    "analogjs.vscode-analog",
    "angular.ng-template",
    "anteprimorac.html-end-tag-labels",
    "davidanson.vscode-markdownlint",
    "dbaeumer.vscode-eslint",
    "docker.docker",
    "dotjoshjohnson.xml",
    "dracula-theme.theme-dracula",
    "eamodio.gitlens",
    "eriklynd.json-tools",
    "esbenp.prettier-vscode",
    "fernandoescolar.vscode-solution-explorer",
    "formulahendry.auto-rename-tag",
    "geeebe.duplicate",
    "github.copilot",
    "github.copilot-chat",
    "github.remotehub",
    "github.vscode-github-actions",
    "github.vscode-pull-request-github",
    "grapecity.gc-excelviewer",
    "hashicorp.terraform",
    "hbenl.vscode-jasmine-test-adapter",
    "hbenl.vscode-test-explorer",
    "johnpapa.angular-essentials",
    "johnpapa.angular2",
    "johnpapa.vscode-peacock",
    "johnpapa.winteriscoming",
    "knisterpeter.vscode-commitizen",
    "lucono.karma-test-explorer",
    "mechatroner.rainbow-csv",
    "mikeburgh.xml-format",
    "mintlify.document",
    "ms-azuretools.vscode-containers",
    "ms-azuretools.vscode-docker",
    "ms-dotnettools.csdevkit",
    "ms-dotnettools.csharp",
    "ms-dotnettools.vscode-dotnet-runtime",
    "ms-kubernetes-tools.vscode-kubernetes-tools",
    "ms-playwright.playwright",
    "ms-python.debugpy",
    "ms-python.isort",
    "ms-python.python",
    "ms-python.vscode-pylance",
    "ms-python.vscode-python-envs",
    "ms-vscode-remote.remote-containers",
    "ms-vscode-remote.remote-wsl",
    "ms-vscode.azure-repos",
    "ms-vscode.powershell",
    "ms-vscode.remote-repositories",
    "ms-vscode.test-adapter-converter",
    "nativescript.nativescript",
    "naumovs.color-highlight",
    "pkief.material-icon-theme",
    "rangav.vscode-thunder-client",
    "redhat.vscode-yaml",
    "streetsidesoftware.code-spell-checker",
    "stylelint.vscode-stylelint",
    "tonybaloney.vscode-pets",
    "yzhang.markdown-all-in-one"
)
foreach ($ext in $extensions) { & code --install-extension $ext --force }

# 6. Notepad++ Dracula
Cast-Spell "Enchanting Notepad++ with Dracula"
$nppThemeDir = "$env:APPDATA\Notepad++\themes"
if (Test-Path $nppThemeDir) {
    $draculaUrl = "https://raw.githubusercontent.com/dracula/notepad-plus-plus/master/generated/Dracula.xml"
    Invoke-WebRequest -Uri $draculaUrl -OutFile (Join-Path $nppThemeDir "Dracula.xml")
}

# 7. WSL Zsh/Oh My Zsh
Cast-Spell "Opening the Chamber of Secrets (WSL Setup)"
# Ensure Ubuntu is registered
Start-Sleep -Seconds 5
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    wsl -u root apt update
    wsl -u root apt install -y zsh curl git
    wsl -u $($env:USERNAME) sh -c 'if [ ! -d ~/.oh-my-zsh ]; then sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; fi'
    wsl -u root chsh -s /usr/bin/zsh $($env:USERNAME)
    
    # Mirror config to WSL
    $wslPath = "\\wsl.localhost\Ubuntu\home\$($env:USERNAME)"
    if (Test-Path $wslPath) {
        Copy-Item "$repoRoot\Shared\Scripts\shell-aliases.sh" -Destination "$wslPath/.shell-aliases.sh"
        Copy-Item "$repoRoot\Shared\TerminalSetup\ConfigFiles\oh-my-posh-theme.json" -Destination "$wslPath/.oh-my-posh-theme.json"
        wsl -u $($env:USERNAME) sh -c 'if ! grep -q ".shell-aliases.sh" ~/.zshrc; then echo "source ~/.shell-aliases.sh" >> ~/.zshrc; fi'
        wsl -u $($env:USERNAME) zsh -c 'source ~/.zshrc && curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell && export PATH=$HOME/.local/share/fnm:$PATH && fnm install --latest && fnm use default && npm install -g @angular/cli @google/gemini-cli'
    }
}

Play-Chime -Type 1
Write-Host "`nðŸŽ† ALL SPELLS CAST SUCCESSFULLY! ðŸŽ†" -ForegroundColor Green
Write-Host "Your Lucye environment is now impeccable." -ForegroundColor Yellow
