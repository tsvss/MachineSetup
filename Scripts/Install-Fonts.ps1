# Install-Fonts.ps1
# Standalone helper for font installation

$fontPath = Join-Path (Get-Item $PSScriptRoot).Parent.FullName "Shared\Fonts\CascadiaCode"
if (Test-Path $fontPath) {
    Write-Host "$([char]0x2728) Installing Cascadia Code Nerd Fonts..." -ForegroundColor Cyan
    $fonts = Get-ChildItem -Path $fontPath -Filter "*.ttf"
    $shellApp = New-Object -ComObject Shell.Application
    $fontFolder = $shellApp.Namespace(0x14)
    foreach ($font in $fonts) {
        $dest = Join-Path "C:\Windows\Fonts" $font.Name
        if (-not (Test-Path $dest)) {
            Write-Host " [Font] Transfiguring font: $($font.Name)" -ForegroundColor Yellow
            $fontFolder.CopyHere($font.FullName, 0x10)
        }
    }
}

