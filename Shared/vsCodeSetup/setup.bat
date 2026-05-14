@REM copying the Files to the C Drive
echo off
cls
title CopyFilesForVSCodeCustomization
copy /b/v settings.json C:\Users\%UserName%\AppData\Roaming\Code\User\settings.json
echo Copying Complete
pause