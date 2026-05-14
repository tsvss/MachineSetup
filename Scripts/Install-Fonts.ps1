# Install-Fonts.ps1
# Standalone helper for font installation

$fontPath = Join-Path (Get-Item $PSScriptRoot).Parent.FullName "Fonts\CascadiaCode"
if (Test-Path $fontPath) {
    Write-Host "✨ Installing Cascadia Code Nerd Fonts..." -ForegroundColor Cyan
    $fonts = Get-ChildItem -Path $fontPath -Filter "*.ttf"
    $shellApp = New-Object -ComObject Shell.Application
    $fontFolder = $shellApp.Namespace(0x14)
    foreach ($font in $fonts) {
        $dest = Join-Path "C:\Windows\Fonts" $font.Name
        if (-not (Test-Path $dest)) {
            Write-Host "📜 Transfiguring font: $($font.Name)" -ForegroundColor Yellow
            $fontFolder.CopyHere($font.FullName, 0x10)
        }
    }
}
