# bootstrap.ps1
# 🪄 The Initial Spark: Zero-Git Bootstrapper
# This script downloads the full repository as a ZIP and starts the setup.

$ErrorActionPreference = "Stop"

$repoUrl = "https://github.com/tsvss/MachineSetup/archive/refs/heads/zero-touch-setup.zip"
$tempDir = Join-Path $env:TEMP "WizardingSetup"
$zipPath = Join-Path $env:TEMP "MachineSetup.zip"

if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "✨ Summoning the full repository archive..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $repoUrl -OutFile $zipPath -UseBasicParsing

Write-Host "📦 Extracting the magical artifacts..." -ForegroundColor Yellow
Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

$extractedDir = Get-ChildItem -Path $tempDir | Select-Object -First 1
cd $extractedDir.FullName

Write-Host "🪄 Starting the Wizard..." -ForegroundColor Green
.\Start-Magic.ps1
