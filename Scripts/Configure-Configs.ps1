# Configure-Configs.ps1
# Standalone helper for VS Code, Git, Windows Terminal, and PowerShell configuration

$repoRoot = (Get-Item $PSScriptRoot).Parent.FullName

# VS Code
Write-Host "$([char]0x2728) Syncing VS Code settings..." -ForegroundColor Cyan
$vscodeSettingsPath = "$env:APPDATA\Code\User\settings.json"
$sourceSettings = Join-Path $repoRoot "Shared\vsCodeSetup\settings.json"
if (Test-Path $sourceSettings) {
    $vscodeDir = Split-Path $vscodeSettingsPath -Parent
    if (-not (Test-Path $vscodeDir)) { New-Item -ItemType Directory -Path $vscodeDir -Force }
    Copy-Item $sourceSettings -Destination $vscodeSettingsPath -Force
}

# Windows Terminal
Write-Host "$([char]0x2728) Syncing Windows Terminal settings..." -ForegroundColor Cyan
$wtSettingsDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$wtSourceSettings = Join-Path $repoRoot "Shared\TerminalSetup\ConfigFiles\wt_settings.json"
if (Test-Path $wtSourceSettings) {
    if (-not (Test-Path $wtSettingsDir)) {
        New-Item -ItemType Directory -Path $wtSettingsDir -Force
    }
    Copy-Item $wtSourceSettings -Destination (Join-Path $wtSettingsDir "settings.json") -Force
}

# PowerShell Profile
Write-Host "$([char]0x2728) Syncing PowerShell 7 profile..." -ForegroundColor Cyan
$pwshProfilePath = $PROFILE
if ($PSVersionTable.PSVersion.Major -lt 6) {
    # If running in Windows PowerShell, target the PowerShell 7 profile path
    $personalFolder = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments)
    $pwshProfilePath = Join-Path $personalFolder "PowerShell\Microsoft.PowerShell_profile.ps1"
}
$profileDir = Split-Path $pwshProfilePath -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force
}
$sourceProfile = Join-Path $repoRoot "Shared\TerminalSetup\ConfigFiles\powershellProfile.ps1"
if (Test-Path $sourceProfile) {
    Copy-Item $sourceProfile -Destination $pwshProfilePath -Force
}

# Oh My Posh Theme
Write-Host "$([char]0x2728) Syncing Oh My Posh theme..." -ForegroundColor Cyan
$ompDir = "C:\Users\$env:USERNAME\oh-my-posh"
if (-not (Test-Path $ompDir)) {
    New-Item -ItemType Directory -Path $ompDir -Force
}
$sourceOmpTheme = Join-Path $repoRoot "Shared\TerminalSetup\ConfigFiles\oh-my-posh-theme.json"
if (Test-Path $sourceOmpTheme) {
    Copy-Item $sourceOmpTheme -Destination "$ompDir\theme.json" -Force
}

# Git
Write-Host "$([char]0x2728) Applying Git configuration..." -ForegroundColor Cyan

# Find Git executable dynamically
$gitCmd = "git"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    $standardGitPath = "C:\Program Files\Git\cmd\git.exe"
    if (Test-Path $standardGitPath) {
        $gitCmd = $standardGitPath
    }
}

& $gitCmd config --global user.name "Satya"
& $gitCmd config --global user.email "venkata.satya2910@gmail.com"
& $gitCmd config --global push.default current
& $gitCmd config --global push.autoSetupRemote true
& $gitCmd config --global pull.rebase true
& $gitCmd config --global core.editor "code --wait"
& $gitCmd config --global init.defaultBranch main

# Configure 1Password commit signing if available
$opSshSignPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\op-ssh-sign.exe"
if (Test-Path $opSshSignPath) {
    Write-Host "$([char]0x2728) Configuring 1Password SSH commit signing..." -ForegroundColor Cyan
    & $gitCmd config --global gpg.format ssh
    & $gitCmd config --global commit.gpgsign true
    & $gitCmd config --global tag.gpgsign true
    & $gitCmd config --global gpg.ssh.program $opSshSignPath
    & $gitCmd config --global user.signingkey "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC69/jPbX0LSMtiNMtTEE9LWV16l5T0dRPoeWnV19ZzFAZerKReqUC3+NK7MkNDQb/y/b/mp8WCF29f7Exg1dyNiOuLeOW7U7jyST4O+lAPI+S5ZJJGzwtCFX+mKsRWCmS6U3m+2fhbhp7sqQ3XX2SQNI+tZz1Mtej+LJ7Y1WmFff+8CDWry7Fz+UoL+jVGsqjznY4XSFhG8V/rPR35ibBmtd1RgR93ttEUPkkUmT+w9Tp0/RhG5J/6oW1Nyxhl2LfS0/g4wYcoppG4Q1rVr2qz8EHsH0HS7liXyMTklCb3G1ErnZJzf2Uoz+bHJXOatU972auaIr/KBI+7dsoypurhKRL9Hq60wh2MpHUjCs0/CqAdzcEr7JPHHwPXTb/yiV63SnDtMFx+PjeQ5Jy+WhP1KaGHl2LY2abeDuRjPcLIz37peXEqMdARM5g6boB8oHowoNMEN+c/pQH5pL0ykCU+/Jgq3djcQ9q5WZfaEcR69GzQwJVl+jUc5J8j1vgTvfD/or8Oo5KXYhpkSgoDl/1RU6SbYBIUhs36ob3RDa2nUNx+MwCn9ue+F8of5OpbGCnhzREDX65w4jWfXhScSCTckvRj1owgUOSSzl+mviOgcheC/+lmALM9/90gQAeFrCi7RhF5SsV5MxB3c3Yp96sLGB0SK0DG6SX06X3taKlxkw=="
}

