# Setup-Lucye.ps1
# 🧙‍♂️ The Lucye Machine Setup - A Wizarding World Experience
# Targets: .NET 10, Java, Node.js, Angular, Gemini CLI, Google Drive, WSL (Zsh/Oh My Zsh)

param([switch]$Resumed)

$ErrorActionPreference = "Stop"

# --- Elevation Logic ---
function Check-MuggleStatus {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Host "$([char]0x2728) Ministry Authorization required. Elevating script..." -ForegroundColor Cyan
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$($PSCommandPath)`""
        Start-Process powershell -Verb runAs -ArgumentList $arguments
        exit
    }
}

# --- Environment Path Refresh ---
function Refresh-EnvPaths {
    Write-Host "🔄 Refreshing environment variables from registry..." -ForegroundColor Gray
    
    # 1. Update all Machine Environment Variables
    $machineVars = [Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::Machine)
    foreach ($key in $machineVars.Keys) {
        if ($key -notlike "Path") {
            [Environment]::SetEnvironmentVariable($key, $machineVars[$key], [System.EnvironmentVariableTarget]::Process)
        }
    }
    
    # 2. Update all User Environment Variables
    $userVars = [Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::User)
    foreach ($key in $userVars.Keys) {
        if ($key -notlike "Path") {
            [Environment]::SetEnvironmentVariable($key, $userVars[$key], [System.EnvironmentVariableTarget]::Process)
        }
    }
    
    # 3. Update PATH (Machine + User merged)
    $machinePath = [Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    $userPath = [Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
    $env:PATH = "$machinePath;$userPath"
}

# --- Impeccable UX: Chimes & Progress ---
function Play-Chime {
    param([int]$Type = 1)
    if ($Type -eq 1) { [Console]::Beep(440, 200); [Console]::Beep(659, 200); [Console]::Beep(880, 200) } # Success
    else { [Console]::Beep(220, 500) } # Error/Wait
}

function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "                 .                  " -ForegroundColor Yellow
    Write-Host "               .   .                " -ForegroundColor Yellow
    Write-Host "             .   :   .              " -ForegroundColor Yellow
    Write-Host "         ` .   \ | /   . '          " -ForegroundColor Yellow
    Write-Host "       . - - - - * - - - - .        " -ForegroundColor Yellow
    Write-Host "         . '   / | \   . '          " -ForegroundColor Yellow
    Write-Host "             .   :   .              " -ForegroundColor Yellow
    Write-Host "               .   .                " -ForegroundColor Yellow
    Write-Host "                 |                  " -ForegroundColor Gray
    Write-Host "                 |                  " -ForegroundColor Gray
    Write-Host "                 |                  " -ForegroundColor Gray
    Write-Host "                 |                  " -ForegroundColor Gray
    Write-Host "                 |                  " -ForegroundColor Gray
    Write-Host "                 |                  " -ForegroundColor Gray
    Write-Host "                 |                  " -ForegroundColor Gray
    Write-Host "                 |                  " -ForegroundColor Gray
    Write-Host "                 |                  " -ForegroundColor Gray
    Write-Host "                 |                  " -ForegroundColor Gray
    Write-Host "                 U                  " -ForegroundColor Gray
    Write-Host ""
    Write-Host "    $([char]0x2728)  WELCOME TO THE LUCYE MACHINE SETUP WIZARD  $([char]0x2728)" -ForegroundColor Yellow
    Write-Host "    `"Happiness can be found even in the darkest of times," -ForegroundColor Cyan
    Write-Host "     if one only remembers to turn on the terminal.`"" -ForegroundColor Cyan
    Write-Host ""
}

function Cast-Spell {
    param([string]$Message)
    Write-Host "`n$([char]0x2728) Casting Spell: $Message..." -ForegroundColor Cyan
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

# --- Setup Result Tracking ---
$Script:SetupResults = [System.Collections.ArrayList]@()

function Add-SetupResult {
    param([string]$Category, [string]$Name, [string]$Status)
    $null = $Script:SetupResults.Add([PSCustomObject]@{ Category = $Category; Name = $Name; Status = $Status })
}

function Show-SetupSummary {
    function Write-ResultSection {
        param([string]$Title, [object[]]$Items)
        if (-not $Items -or $Items.Count -eq 0) { return }
        $installed = @($Items | Where-Object { $_.Status -eq 'Installed' })
        $skipped   = @($Items | Where-Object { $_.Status -eq 'Skipped' })
        $failed    = @($Items | Where-Object { $_.Status -eq 'Failed' })
        Write-Host "`n  $Title" -ForegroundColor Magenta
        Write-Host ("  " + ([char]0x2500) * 52) -ForegroundColor DarkGray
        Write-Host "  ✅ Installed: $($installed.Count)   ✨ Already present: $($skipped.Count)   ❌ Failed: $($failed.Count)" -ForegroundColor Cyan
        if ($installed.Count -gt 0) {
            Write-Host "  New     : $($installed.Name -join ', ')" -ForegroundColor Green
        }
        if ($failed.Count -gt 0) {
            Write-Host "  Failed  : $($failed.Name -join ', ')" -ForegroundColor Red
        }
    }

    $apps  = @($Script:SetupResults | Where-Object { $_.Category -eq 'App' })
    $tools = @($Script:SetupResults | Where-Object { $_.Category -eq 'Tool' })
    $exts  = @($Script:SetupResults | Where-Object { $_.Category -eq 'Extension' })

    Write-Host ""
    Write-Host "  $([char]0x2554)$([char]0x2550)" + ("$([char]0x2550)" * 50) + "$([char]0x2550)$([char]0x2557)" -ForegroundColor Yellow
    Write-Host "  $([char]0x2551)       $([char]0x1F386)  SETUP COMPLETE $([char]0x2014) SUMMARY  $([char]0x1F386)       $([char]0x2551)" -ForegroundColor Yellow
    Write-Host "  $([char]0x255A)$([char]0x2550)" + ("$([char]0x2550)" * 50) + "$([char]0x2550)$([char]0x255D)" -ForegroundColor Yellow

    Write-ResultSection "Applications (Winget)" $apps
    Write-ResultSection "CLI Tools (Chocolatey)" $tools
    Write-ResultSection "VS Code Extensions" $exts

    Write-Host ""
    Write-Host "  Your Lucye environment is now impeccable. $([char]0x1F9D9)$([char]0x200D)$([char]0x2642)$([char]0xFE0F)$([char]0x2728)" -ForegroundColor Cyan
    Write-Host ""
}

# --- WSL & Features ---
function Enable-Feature-Via-Dism {
    param([string]$FeatureName, [string]$DisplayName)
    
    $stdOutFile = [System.IO.Path]::GetTempFileName()
    $stdErrFile = [System.IO.Path]::GetTempFileName()
    $rebootRequired = $false
    try {
        $process = Start-Process dism.exe -ArgumentList "/online", "/enable-feature", "/featurename:$FeatureName", "/all", "/norestart" -NoNewWindow -PassThru -Wait -RedirectStandardOutput $stdOutFile -RedirectStandardError $stdErrFile
        if ($process.ExitCode -eq 3010) {
            Cast-Spell "Enabling $DisplayName (Reboot will be required)"
            $rebootRequired = $true
        }
    } catch {} finally {
        if (Test-Path $stdOutFile) { Remove-Item $stdOutFile -Force }
        if (Test-Path $stdErrFile) { Remove-Item $stdErrFile -Force }
    }
    return $rebootRequired
}

function Enable-MagicalFeatures {
    $rebootNeeded = $false
    
    # Check if Hardware Virtualization is enabled in BIOS
    $sysInfo = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue
    if ($sysInfo -and $sysInfo.VirtualizationFirmwareEnabled -eq $false) {
        Write-Host ""
        Write-Host "$([char]0x26a0) WARNING: Hardware Virtualization (Intel VT-x / AMD-V) is disabled in your BIOS/UEFI!" -ForegroundColor Red
        Write-Host "For WSL 2 and Virtual Machines to work, you must reboot your PC, enter your BIOS/UEFI settings, and enable Virtualization Technology." -ForegroundColor Yellow
        Write-Host "Press any key to acknowledge and continue setup anyway..." -ForegroundColor Cyan
        $null = [Console]::ReadKey($true)
    }
    
    # 1. Check if WSL is already operational
    $wslCheck = $false
    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        & wsl --status >$null 2>&1
        if ($LASTEXITCODE -eq 0) {
            $wslCheck = $true
        }
    }
    
    # 2. If WSL is not operational, enable required features
    if (-not $wslCheck) {
        $r1 = Enable-Feature-Via-Dism -FeatureName "Microsoft-Windows-Subsystem-Linux" -DisplayName "Windows Subsystem for Linux (WSL)"
        $r2 = Enable-Feature-Via-Dism -FeatureName "VirtualMachinePlatform" -DisplayName "Virtual Machine Platform (Required for WSL 2)"
        $rebootNeeded = $rebootNeeded -or $r1 -or $r2
    }

    # 3. Enable Hyper-V (Only on Pro/Enterprise; will fail silently on Home)
    $r3 = Enable-Feature-Via-Dism -FeatureName "Microsoft-Hyper-V-All" -DisplayName "Hyper-V (The Great Hall)"
    $rebootNeeded = $rebootNeeded -or $r3

    # 4. If features are enabled (or already enabled) but WSL kernel is still missing, trigger wsl --install
    if (-not $wslCheck -and -not $rebootNeeded) {
        Cast-Spell "Installing WSL Core Components"
        & wsl --install --no-distribution
        & wsl --update
        $rebootNeeded = $true
    }

    if ($rebootNeeded) {
        Set-AutoResume
        Play-Chime -Type 2
        Write-Host "`n$([char]0x26a0) REBOOT REQUIRED: The environment must restart to solidify the magic." -ForegroundColor Yellow
        Write-Host "The setup will automatically resume once you log back in." -ForegroundColor Cyan
        $confirm = Read-Host "Restart now? (Y/N)"
        if ($confirm -eq 'Y') { Restart-Computer }
        else { Write-Host "Please restart manually to continue the setup."; exit }
    }
}

function Transfigure-App {
    param([string]$Id, [string]$Name, [string]$Override, [int]$CurrentIndex, [int]$TotalCount)
    
    $prefix = "[$CurrentIndex/$TotalCount]"
    Write-Host "`n$prefix $([char]0x2728) Summoning $Name..." -ForegroundColor Cyan
    
    # 1. Check if already installed
    Write-Host "   $([char]0x25c6) Status: Checking spellbook..." -ForegroundColor Gray
    $installed = $false
    try {
        $check = & winget list --id $Id -e --accept-source-agreements 2>$null
        if ($LASTEXITCODE -eq 0 -and $check -match [regex]::Escape($Id)) {
            $installed = $true
        }
    } catch {}
    
    if ($installed) {
        Write-Host "$([char]27)[1A$([char]27)[2K   ✨ $Name is already present in your spellbook." -ForegroundColor Gray
        Add-SetupResult -Category 'App' -Name $Name -Status 'Skipped'
        return
    }

    # 2. Install package
    Write-Host "$([char]27)[1A$([char]27)[2K   ⚡ Status: Casting transfiguration spell (Installing)..." -ForegroundColor Yellow

    $processStart = Get-Date
    $stdOutFile = [System.IO.Path]::GetTempFileName()
    $stdErrFile = [System.IO.Path]::GetTempFileName()

    try {
        $params = @("install", "--id", $Id, "-e", "--accept-package-agreements", "--accept-source-agreements", "--silent")
        if ($Override) {
            $params += @("--override", $Override)
        }

        $process = Start-Process winget -ArgumentList $params -NoNewWindow -PassThru -Wait -RedirectStandardOutput $stdOutFile -RedirectStandardError $stdErrFile

        $duration = [Math]::Round(((Get-Date) - $processStart).TotalSeconds, 1)

        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            Write-Host "$([char]27)[1A$([char]27)[2K   ✅ $Name successfully transfigured! ($duration s)" -ForegroundColor Green
            Add-SetupResult -Category 'App' -Name $Name -Status 'Installed'
        } else {
            $errContent = Get-Content $stdErrFile -Raw
            $outContent = Get-Content $stdOutFile -Raw
            Write-Host "$([char]27)[1A$([char]27)[2K   ❌ Failed to summon $Name (Exit code: $($process.ExitCode))." -ForegroundColor Red
            Add-SetupResult -Category 'App' -Name $Name -Status 'Failed'
            if ($errContent) {
                Write-Host "      Details: $($errContent.Trim())" -ForegroundColor DarkRed
            } elseif ($outContent -match "Installer failed with exit code") {
                $lines = $outContent -split "`r?`n" | Where-Object { $_ -match "failed with exit code" }
                if ($lines) {
                    Write-Host "      Details: $($lines[0].Trim())" -ForegroundColor DarkRed
                } else {
                    Write-Host "      Details: Installer failed." -ForegroundColor DarkRed
                }
            } else {
                Write-Host "      Details: Unknown installation error." -ForegroundColor DarkRed
            }
        }
    } catch {
        Write-Host "$([char]27)[1A$([char]27)[2K   ❌ Spell interrupted for $Name. $_" -ForegroundColor Red
        Add-SetupResult -Category 'App' -Name $Name -Status 'Failed'
    } finally {
        if (Test-Path $stdOutFile) { Remove-Item $stdOutFile -Force }
        if (Test-Path $stdErrFile) { Remove-Item $stdErrFile -Force }
    }
}

# --- Main Wizardry ---

Check-MuggleStatus
Show-Header

# Pre-flight: disk space check
$_sysDriveLetter = $env:SystemDrive.TrimEnd(':')
$_freeGB = try { [Math]::Round((Get-PSDrive $_sysDriveLetter -ErrorAction Stop).Free / 1GB, 1) } catch { $null }
if ($_freeGB -ne $null -and $_freeGB -lt 20) {
    Write-Host "`n$([char]0x26A0)  WARNING: $($env:SystemDrive) has only $_freeGB GB free. 20 GB+ recommended." -ForegroundColor Yellow
    $confirm = Read-Host "Continue anyway? (Y/N)"
    if ($confirm -ne 'Y') { exit }
}

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
    Refresh-EnvPaths
}

# 2. Core Apps
Cast-Spell "Summoning the Core Artifacts"
$apps = @(
    @{ Id = "Git.Git"; Name = "Git" }
    @{ Id = "GitHub.cli"; Name = "GitHub CLI" }
    @{ Id = "Microsoft.VisualStudioCode"; Name = "VS Code"; Override = '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders"' }
    @{ Id = "Docker.DockerDesktop"; Name = "Docker" }
    @{ Id = "Microsoft.DotNet.SDK.10"; Name = ".NET 10" }
    @{ Id = "Amazon.Corretto.25.JDK"; Name = "Java 25" }
    @{ Id = "Google.GoogleDrive"; Name = "Google Drive" }
    @{ Id = "AgileBits.1Password"; Name = "1Password" }
    # @{ Id = "Warp.Warp"; Name = "Warp" }
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

$appCount = 1
$totalApps = $apps.Count
foreach ($app in $apps) {
    $override = $null
    if ($app.ContainsKey('Override')) { $override = $app['Override'] }
    Transfigure-App -Id $app['Id'] -Name $app['Name'] -Override $override -CurrentIndex $appCount -TotalCount $totalApps
    $appCount++
}
Refresh-EnvPaths

# 3. Fast Node Manager & Other Command Line Tools
Cast-Spell "Brewing Chocolatey Potions"
$chocoApps = @(
    @{ Id = "fnm"; Command = "fnm" }
    @{ Id = "fzf"; Command = "fzf" }
    @{ Id = "jq"; Command = "jq" }
    @{ Id = "k3d"; Command = "k3d" }
    @{ Id = "k9s"; Command = "k9s" }
    @{ Id = "kubernetes-cli"; Command = "kubectl" }
    @{ Id = "terraform"; Command = "terraform" }
    @{ Id = "terraformer"; Command = "terraformer" }
)
$chocoCurrent = 1
$chocoTotal = $chocoApps.Count
foreach ($app in $chocoApps) {
    $prefix = "[$chocoCurrent/$chocoTotal]"
    Write-Host "`n$prefix $([char]0x2728) Summoning $($app['Id']) (via Chocolatey)..." -ForegroundColor Cyan
    Write-Host "   $([char]0x25c6) Status: Checking spellbook..." -ForegroundColor Gray
    
    $installed = $false
    if (Get-Command $app['Command'] -ErrorAction SilentlyContinue) {
        $installed = $true
    }
    
    if ($installed) {
        Write-Host "$([char]27)[1A$([char]27)[2K   ✨ $($app['Id']) is already present in your spellbook." -ForegroundColor Gray
        Add-SetupResult -Category 'Tool' -Name $app['Id'] -Status 'Skipped'
    } else {
        Write-Host "$([char]27)[1A$([char]27)[2K   ⚡ Status: Casting transfiguration spell (Installing)..." -ForegroundColor Yellow
        $processStart = Get-Date
        $stdOutFile = [System.IO.Path]::GetTempFileName()
        $stdErrFile = [System.IO.Path]::GetTempFileName()
        try {
            $process = Start-Process choco -ArgumentList @("install", $app['Id'], "-y") -NoNewWindow -PassThru -Wait -RedirectStandardOutput $stdOutFile -RedirectStandardError $stdErrFile
            $duration = [Math]::Round(((Get-Date) - $processStart).TotalSeconds, 1)
            if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
                Write-Host "$([char]27)[1A$([char]27)[2K   ✅ $($app['Id']) successfully transfigured! ($duration s)" -ForegroundColor Green
                Add-SetupResult -Category 'Tool' -Name $app['Id'] -Status 'Installed'
            } else {
                Write-Host "$([char]27)[1A$([char]27)[2K   ❌ Failed to summon $($app['Id']) (Exit code: $($process.ExitCode))." -ForegroundColor Red
                Add-SetupResult -Category 'Tool' -Name $app['Id'] -Status 'Failed'
                $errContent = Get-Content $stdErrFile -Raw
                if ($errContent) {
                    Write-Host "      Details: $($errContent.Trim())" -ForegroundColor DarkRed
                }
            }
        } catch {
            Write-Host "$([char]27)[1A$([char]27)[2K   ❌ Spell interrupted for $($app['Id']). $_" -ForegroundColor Red
            Add-SetupResult -Category 'Tool' -Name $app['Id'] -Status 'Failed'
        } finally {
            if (Test-Path $stdOutFile) { Remove-Item $stdOutFile -Force }
            if (Test-Path $stdErrFile) { Remove-Item $stdErrFile -Force }
        }
    }
    $chocoCurrent++
}
Refresh-EnvPaths
$env:PATH += ";$env:APPDATA\fnm"
fnm env --use-on-cd | Out-String | Invoke-Expression
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
    # Removed: "4ops.terraform"       (superseded by hashicorp.terraform below)
    # Removed: "hbenl.vscode-jasmine-test-adapter" (Jasmine less common; built-in testing sufficient)
    # Removed: "hbenl.vscode-test-explorer"        (VS Code built-in test UI now covers this)
    # Removed: "ms-vscode.test-adapter-converter"  (only needed by test-explorer above)
    # Removed: "johnpapa.winteriscoming"            (theme not used; Dracula is active)
    # Removed: "mintlify.document"                 (GitHub Copilot handles doc generation)
    # Removed: "knisterpeter.vscode-commitizen"    (superseded by custom git commit functions)
    # Removed: "ms-vscode.azure-repos"             (GitHub-focused workflow; not Azure DevOps)
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
    "johnpapa.angular-essentials",
    "johnpapa.angular2",
    "johnpapa.vscode-peacock",
    "lucono.karma-test-explorer",
    "mechatroner.rainbow-csv",
    "mikeburgh.xml-format",
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
    "ms-vscode.powershell",
    "ms-vscode.remote-repositories",
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
$installedExts = @()
if (Get-Command code -ErrorAction SilentlyContinue) {
    $installedExts = & code --list-extensions 2>$null
}
$missingExtensions = @()
foreach ($ext in $extensions) {
    if ($installedExts -notcontains $ext) {
        $missingExtensions += $ext
    }
}
foreach ($ext in ($extensions | Where-Object { $installedExts -contains $_ })) {
    Add-SetupResult -Category 'Extension' -Name $ext -Status 'Skipped'
}
if ($missingExtensions.Count -gt 0) {
    $extCurrent = 1
    $extTotal = $missingExtensions.Count
    foreach ($ext in $missingExtensions) {
        $prefix = "[$extCurrent/$extTotal]"
        Write-Host "`n$prefix $([char]0x2728) Installing VS Code extension: $ext..." -ForegroundColor Cyan
        & code --install-extension $ext --force
        if ($LASTEXITCODE -eq 0) {
            Add-SetupResult -Category 'Extension' -Name $ext -Status 'Installed'
        } else {
            Add-SetupResult -Category 'Extension' -Name $ext -Status 'Failed'
        }
        $extCurrent++
    }
} else {
    Write-Host "`n$([char]0x2728) All VS Code extensions are already installed." -ForegroundColor Gray
}

Cast-Spell "Enchanting Notepad++ with Dracula"
$nppDir = "$env:APPDATA\Notepad++"
$nppThemeDir = "$nppDir\themes"
if (-not (Test-Path $nppThemeDir)) {
    try {
        New-Item -ItemType Directory -Path $nppThemeDir -Force | Out-Null
    } catch {
        Write-Warning "Could not create Notepad++ themes folder."
    }
}
if (Test-Path $nppThemeDir) {
    $draculaUrl = "https://raw.githubusercontent.com/dracula/notepad-plus-plus/master/generated/Dracula.xml"
    try {
        Invoke-WebRequest -Uri $draculaUrl -OutFile (Join-Path $nppThemeDir "Dracula.xml") -UseBasicParsing
    } catch {
        Write-Warning "Could not download Notepad++ Dracula theme: $_"
    }
}

# 7. WSL Zsh/Oh My Zsh
Cast-Spell "Opening the Chamber of Secrets (WSL Setup)"
# Ensure Ubuntu is registered
Start-Sleep -Seconds 5
try {
    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        # Get the logged-in user instead of SYSTEM
        $loggedInUser = (Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue).UserName
        if ($loggedInUser) {
            $realUser = $loggedInUser.Split('\')[-1]
        } else {
            $realUser = $env:USERNAME
        }

        # Check if Ubuntu-24.04 is installed/registered
        $null = & wsl -d Ubuntu-24.04 -u root echo "test" 2>&1
        $isRegistered = ($LASTEXITCODE -eq 0)
        
        # If not registered, install and register it natively via WSL
        if (-not $isRegistered) {
            Write-Host "   $([char]0x25c6) Installing and registering Ubuntu-24.04 distribution..." -ForegroundColor Yellow
            & wsl --install -d Ubuntu-24.04 --no-launch
            Start-Sleep -Seconds 5
        }
        
        # 1. Update packages and install core zsh/curl/git (must be done before creating the user so zsh shell exists)
        Write-Host "   $([char]0x25c6) Updating packages and installing zsh/curl/git..." -ForegroundColor Yellow
        & wsl -d Ubuntu-24.04 -u root apt update
        & wsl -d Ubuntu-24.04 -u root apt install -y zsh curl git
        
        # 2. Create user if it doesn't exist
        Write-Host "   $([char]0x25c6) Setting up UNIX user account ($realUser)..." -ForegroundColor Yellow
        & wsl -d Ubuntu-24.04 -u root id -u $realUser >$null 2>&1
        if ($LASTEXITCODE -ne 0) {
            & wsl -d Ubuntu-24.04 -u root useradd -m -s /usr/bin/zsh -G sudo $realUser
            & wsl -d Ubuntu-24.04 -u root sh -c "echo '$realUser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$realUser"
            & wsl -d Ubuntu-24.04 -u root sh -c "printf '[user]\ndefault=$realUser\n' > /etc/wsl.conf"
        }
        
        # 3. Install Oh My Zsh if not present (using clean unix pipeline to prevent syntax issues)
        Write-Host "   $([char]0x25c6) Installing Oh My Zsh..." -ForegroundColor Yellow
        & wsl -d Ubuntu-24.04 -u $realUser bash -c 'if [ ! -d ~/.oh-my-zsh ]; then curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash -s -- --unattended; fi'
        
        # 4. Set default shell to zsh for user
        & wsl -d Ubuntu-24.04 -u root chsh -s /usr/bin/zsh $realUser

        # 5. Install Zsh plugins (autosuggestions, syntax highlighting, history-substring-search)
        Write-Host "   $([char]0x25c6) Installing Zsh plugins..." -ForegroundColor Yellow
        & wsl -d Ubuntu-24.04 -u $realUser bash -c 'mkdir -p ~/.oh-my-zsh/custom/plugins && if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions; fi'
        & wsl -d Ubuntu-24.04 -u $realUser bash -c 'if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting; fi'
        & wsl -d Ubuntu-24.04 -u $realUser bash -c 'if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search ]; then git clone https://github.com/zsh-users/zsh-history-substring-search ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search; fi'

        # Install fzf via apt
        Write-Host "   $([char]0x25c6) Installing fzf..." -ForegroundColor Yellow
        & wsl -d Ubuntu-24.04 -u root apt install -y fzf

        # 6. Install Oh My Posh in WSL
        Write-Host "   $([char]0x25c6) Installing Oh My Posh..." -ForegroundColor Yellow
        & wsl -d Ubuntu-24.04 -u $realUser bash -c 'if [ ! -f ~/.local/bin/oh-my-posh ]; then mkdir -p ~/.local/bin && curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin; fi'

        # 7. Mirror config to WSL using stdin redirection to bypass \\wsl.localhost write permissions
        Write-Host "   $([char]0x25c6) Mirroring config templates to WSL home..." -ForegroundColor Yellow
        $aliasesContent = Get-Content "$repoRoot\Shared\Scripts\shell-aliases.sh" -Raw
        $aliasesContent | & wsl -d Ubuntu-24.04 -u $realUser sh -c "cat > ~/.shell-aliases.sh"
        
        $ompThemeContent = Get-Content "$repoRoot\Shared\TerminalSetup\ConfigFiles\oh-my-posh-theme.json" -Raw
        $ompThemeContent | & wsl -d Ubuntu-24.04 -u $realUser sh -c "cat > ~/.oh-my-posh-theme.json"

        # 8. Create a premium .zshrc matching PowerShell profile capabilities
        Write-Host "   $([char]0x25c6) Configuring .zshrc with premium capabilities..." -ForegroundColor Yellow
        $zshrcContent = @'
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Disable default theme since we use Oh My Posh
ZSH_THEME=""

# Enable plugins
plugins=(git z zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)

source $ZSH/oh-my-zsh.sh

# User paths
export PATH="$HOME/.local/bin:$HOME/.local/share/fnm:$PATH"

# Initialize FNM (Fast Node Manager)
if [ -d "$HOME/.local/share/fnm" ] || [ -f "$HOME/.local/share/fnm/fnm" ]; then
  eval "$(fnm env --use-on-cd)"
fi

# Initialize Oh My Posh
if [ -f "$HOME/.local/bin/oh-my-posh" ]; then
  eval "$(oh-my-posh init zsh --config ~/.oh-my-posh-theme.json)"
fi

# History substring search keybindings (via zsh-history-substring-search plugin)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Initialize fzf if available (key bindings: Ctrl+R history, Ctrl+T file search, Alt+C cd)
if command -v fzf > /dev/null 2>&1; then
  [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
  [ -f /usr/share/doc/fzf/examples/completion.zsh ]   && source /usr/share/doc/fzf/examples/completion.zsh
fi

# Source universal aliases
if [ -f "$HOME/.shell-aliases.sh" ]; then
  source "$HOME/.shell-aliases.sh"
fi
'@

        # Backup existing .zshrc if it exists and write the new one
        & wsl -d Ubuntu-24.04 -u $realUser bash -c 'if [ -f ~/.zshrc ] && [ ! -f ~/.zshrc.bak ]; then cp ~/.zshrc ~/.zshrc.bak; fi'
        $zshrcContent | & wsl -d Ubuntu-24.04 -u $realUser sh -c "cat > ~/.zshrc"
        
        # Clean up line endings (CRLF to LF) for copied files to prevent shell syntax errors
        & wsl -d Ubuntu-24.04 -u $realUser sh -c "sed -i 's/\r$//' ~/.shell-aliases.sh"
        & wsl -d Ubuntu-24.04 -u $realUser sh -c "sed -i 's/\r$//' ~/.oh-my-posh-theme.json"
        & wsl -d Ubuntu-24.04 -u $realUser sh -c "sed -i 's/\r$//' ~/.zshrc"
        
        # 9. Initialize FNM, install Node, and global packages
        Write-Host "   $([char]0x25c6) Initializing FNM and installing global Node packages..." -ForegroundColor Yellow
        & wsl -d Ubuntu-24.04 -u $realUser zsh -c 'curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell && export PATH=$HOME/.local/share/fnm:$PATH && fnm install --latest && fnm use default && npm install -g @angular/cli @google/gemini-cli'
    } else {
        Write-Warning "WSL command not found on the system."
    }
} catch {
    Write-Warning "WSL configuration spell failed: $_"
}

Play-Chime -Type 1
Show-SetupSummary
