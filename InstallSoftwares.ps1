
Function CheckRunAsAdministrator()
{
    #Get current user context
    $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())

    #Check user is running the script is member of Administrator Group
    if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
    {
        if ($dirpath -ne $null) {
            Set-Location -Path $dirpath
        }
        $curDir = Get-Location
        Write-host "Script is running with Administrator privileges!"
        Write-Host "Current Working Directory: $curDir"
    }
    else
    {
        $curDir = Get-Location
        #Create a new Elevated process to Start PowerShell
        $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
                
        # Specify the current script path and name as a parameter
        $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "' -dirpath '" + $curDir + "'"

        #Set the Process to elevated
        $ElevatedProcess.Verb = "runas"

        #Start the new elevated process
        [System.Diagnostics.Process]::Start($ElevatedProcess)

        #Exit from the current, unelevated, process
        Exit

    }
}


Function Install-Chocolatey()
{
    Write-Host "Installing Chocolatey Package Management ";
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));
}

Function Install-ChocolateyApps
{
    $chocoApps = @(
        "fnm"
    )
    foreach ($appName in $chocoApps) {
        choco install $appName -y;
    }
}

CheckRunAsAdministrator
Install-Chocolatey
Install-ChocolateyApps