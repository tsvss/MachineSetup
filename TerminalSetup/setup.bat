@REM copying the Files to the C Drive
echo off
cls
title CopyFilesForTerminalCustomization
copy /b/v ConfigFiles\powershellProfile.ps1 C:\Users\%UserName%\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
copy /b/v ConfigFiles\oh-my-posh-theme.json C:\Users\%UserName%\oh-my-posh\theme.json
echo Copying Complete
pause