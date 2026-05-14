# Setup-Terminal.ps1
# Configures PowerShell profiles and Oh My Posh theme

$profileDir = [System.IO.Path]::GetDirectoryName($PROFILE)
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force
}

Write-Host "Configuring PowerShell profile..." -ForegroundColor Cyan
Copy-Item ".\ConfigFiles\powershellProfile.ps1" -Destination $PROFILE -Force

$ompDir = "C:\Users\$env:USERNAME\oh-my-posh"
if (-not (Test-Path $ompDir)) {
    New-Item -ItemType Directory -Path $ompDir -Force
}

Write-Host "Configuring Oh My Posh theme..." -ForegroundColor Cyan
Copy-Item ".\ConfigFiles\oh-my-posh-theme.json" -Destination "$ompDir\theme.json" -Force

Write-Host "Terminal configuration complete." -ForegroundColor Green
