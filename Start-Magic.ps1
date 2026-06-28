# Start-Magic.ps1
# 🪄 The Wizard's Profile Selector
# The central entry point for all machine setups

$ErrorActionPreference = "Stop"

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "    $([char]0x2728)  THE WIZARD'S PROFILE SELECTOR  $([char]0x2728)" -ForegroundColor Yellow
    Write-Host "    `"Choose your path, for the environment you select" -ForegroundColor Cyan
    Write-Host "     will define the magic you create.`"" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    [1] Lucye (Personal Windows Setup - .NET 10, Java, Full-Stack)" -ForegroundColor Yellow
    Write-Host "    [2] Lysa  (Work Windows Setup - Coming Soon)" -ForegroundColor Gray
    Write-Host "    [3] MacOS (Professional Work Setup - Teams, Outlook, Slack)" -ForegroundColor Yellow
    Write-Host "    [Q] Quit" -ForegroundColor Red
    Write-Host ""
}

function Invoke-Lucye {
    Write-Host "`n$([char]0x2728) Invoking the Lucye Profile..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    & ".\Profiles\Lucye\Windows\Setup-Lucye.ps1"
    
    Write-Host "`n$([char]0x2728) Setup execution finished." -ForegroundColor Gray
    Write-Host "Press any key to return to the selector menu..." -ForegroundColor Cyan
    $null = [Console]::ReadKey($true)
}

# --- Main Execution ---

while ($true) {
    Show-Menu
    $choice = Read-Host "Select a profile to summon [1-3, Q]"
    
    switch ($choice) {
        "1" { Invoke-Lucye; break }
        "2" { Write-Warning "Lysa is still brewing in the cauldron..."; Start-Sleep -Seconds 2 }
        "3" { Write-Host "`n🍎 To summon the MacOS Professional profile, please run 'Profiles/MacOS/Setup-MacOS.sh' on your Mac." -ForegroundColor Cyan; Start-Sleep -Seconds 3 }
        "Q" { exit }
        default { Write-Error "Invalid selection!"; Start-Sleep -Seconds 1 }
    }
}
