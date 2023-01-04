# Machine Setup Automation
Repository contains the automation scripts to setup the windows PC with the required software.

## Prerequisite
- Winget (_Can be found on Microsoft store as `App Installer`_)

Admin previlages to run the scripts

## Software Installation
Run the [SoftwareInstallation.bat](SoftwareInstallations.bat) to install the following software.
### Development Environment
- Visual Studio 2022 (Community)
- Visual Studio Code
- Git
- GitHub Desktop
- GitHub CLI
- Docker Desktop
- Microsoft Powershell
- WinMerge

### Communication
- Microsoft Teams
- Whatsapp
- Zoom

### Browsers
- Google Chrome

### Misc
- 7 Zip
- Notepad ++
- Oh My Posh (Terminal Customization)
- Google Drive
- Microsoft Powertoys
- Twillio Authy 
- VLC

## Terminal Customization
1. Install the Fonts
    - Install the fonts from the [Fonts](./Fonts/CascadiaCode/) folder
2. Open the Terminal[^1] and set the Poweshell as the default profile in the settings
3. Make necessary changes to [Power shell profile](./TerminalSetup/ConfigFiles/powershellProfile.ps1), for the frequently used commands and processes
4. Run the [Setup.bat](./TerminalSetup/Setup.bat) to copy and configure the Terminal with Oh-My-Posh theme
5. Run the [InstallPackages.ps1](./TerminalSetup/InstallPackages.ps1) in the terminal to install the additional packages required by the powershell


[^1]: Install the terminal from [here](https://github.com/microsoft/terminal/releases), if not present by default
