# Configure-Configs.ps1
# Standalone helper for VS Code and Git configuration

$repoRoot = (Get-Item $PSScriptRoot).Parent.FullName

# VS Code
Write-Host "✨ Syncing VS Code settings..." -ForegroundColor Cyan
$vscodeSettingsPath = "$env:APPDATA\Code\User\settings.json"
$sourceSettings = Join-Path $repoRoot "vsCodeSetup\settings.json"
if (Test-Path $sourceSettings) {
    $vscodeDir = Split-Path $vscodeSettingsPath -Parent
    if (-not (Test-Path $vscodeDir)) { New-Item -ItemType Directory -Path $vscodeDir -Force }
    Copy-Item $sourceSettings -Destination $vscodeSettingsPath -Force
}

# Git
Write-Host "✨ Applying Git configuration..." -ForegroundColor Cyan
git config --global user.name "Satya"
git config --global user.email "venkata.satya2910@gmail.com"
git config --global push.default current
git config --global push.autoSetupRemote true
git config --global pull.rebase true
git config --global core.editor "code --wait"
git config --global init.defaultBranch main
