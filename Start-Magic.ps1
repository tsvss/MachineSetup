# Start-Magic.ps1
# 🪄 The Wizard's Profile Selector
# The central entry point for all machine setups

$ErrorActionPreference = "Stop"

function Show-Menu {
    Clear-Host
    Write-Host @"
    
    🪄  THE WIZARD'S PROFILE SELECTOR  🪄
    "Choose your path, for the environment you select 
     will define the magic you create."

    [1] Lucye (Personal Setup - .NET 10, Java, Full-Stack)
    [2] Lysa  (Work Setup - Coming Soon)
    [3] MacOS (General Setup - Coming Soon)
    [Q] Quit

"@ -ForegroundColor Yellow
}

function Invoke-Lucye {
    Write-Host "`n🌟 Invoking the Lucye Profile..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    & ".\Profiles\Lucye\Windows\Setup-Lucye.ps1"
}

# --- Main Execution ---

while ($true) {
    Show-Menu
    $choice = Read-Host "Select a profile to summon [1-3, Q]"
    
    switch ($choice) {
        "1" { Invoke-Lucye; break }
        "2" { Write-Warning "Lysa is still brewing in the cauldron..."; Start-Sleep -Seconds 2 }
        "3" { Write-Warning "The MacOS portal is not yet open..."; Start-Sleep -Seconds 2 }
        "Q" { exit }
        default { Write-Error "Invalid selection!"; Start-Sleep -Seconds 1 }
    }
}
