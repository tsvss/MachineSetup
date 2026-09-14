# Install-Fonts.ps1
# Standalone helper for font installation

$fontPath = Join-Path (Get-Item $PSScriptRoot).Parent.FullName "Shared\Fonts\CascadiaCode"
if (Test-Path $fontPath) {
    Write-Host "$([char]0x2728) Installing Cascadia Code Nerd Fonts..." -ForegroundColor Cyan
    $fonts = Get-ChildItem -Path $fontPath -Filter "*.ttf"
    $shellApp = New-Object -ComObject Shell.Application
    $fontFolder = $shellApp.Namespace(0x14)
    # 0x4 = no progress dialog, 0x10 = yes to all, 0x400 = no error UI
    $copyFlags = 0x4 -bor 0x10 -bor 0x400
    foreach ($font in $fonts) {
        $dest = Join-Path "C:\Windows\Fonts" $font.Name
        Write-Host " [Font] Transfiguring font: $($font.Name)" -ForegroundColor Yellow
        if (Test-Path $dest) {
            Remove-Item $dest -Force -ErrorAction SilentlyContinue
        }
        try {
            $fontFolder.CopyHere($font.FullName, $copyFlags)
        } catch {
            Write-Warning "Could not install font $($font.Name): $_"
        }
    }
}

