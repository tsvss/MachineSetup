# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A zero-touch machine setup system that bootstraps a fresh Windows or macOS machine into a fully configured developer workstation. Scripts are not "apps" to build or test — they are run on target machines. There is no build step, no test suite, and no linter.

## Entry Points

| Scenario | Entry Point |
|---|---|
| Fresh Windows (no Git) | `bootstrap.ps1` — downloads repo as ZIP, runs `Start-Magic.ps1` |
| Windows with Git | `Start-Magic.ps1` — interactive profile selector |
| macOS | `Profiles/MacOS/Setup-MacOS.sh` — run directly in Terminal |

## Running a Setup Script

All scripts require elevated privileges. To manually run a profile on Windows:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Start-Magic.ps1
# Select [1] for Lucye
```

To run individual helper scripts standalone (from repo root):

```powershell
.\Scripts\Install-Fonts.ps1
.\Scripts\Configure-Configs.ps1
```

## Architecture

### Profiles

Each profile in `Profiles/` is a self-contained wizard for a specific machine persona:

- **Lucye** (`Profiles/Lucye/Windows/Setup-Lucye.ps1`): Personal Windows. Installs winget apps, Chocolatey tools, WSL/Ubuntu-24.04 with Zsh+Oh My Zsh, Node via fnm, Angular CLI, Gemini CLI, and then delegates to `Scripts/Install-Fonts.ps1` and `Scripts/Configure-Configs.ps1`.
- **MacOS** (`Profiles/MacOS/Setup-MacOS.sh`): Work macOS. Installs Homebrew, brew formulae/casks, Oh My Zsh, fnm/Node, and copies configs directly.
- **Lysa**: Not yet implemented.

### Shared Assets (consumed by profiles)

- `Shared/TerminalSetup/ConfigFiles/powershellProfile.ps1` — The PowerShell 7 profile deployed to `$PROFILE`. Contains all git/navigation/Angular aliases and PSReadLine configuration.
- `Shared/TerminalSetup/ConfigFiles/oh-my-posh-theme.json` — Oh My Posh prompt theme, deployed to `~/oh-my-posh/theme.json` (Windows) or `~/.oh-my-posh-theme.json` (Unix).
- `Shared/Scripts/shell-aliases.sh` — Universal shell aliases mirroring the PowerShell profile functions, deployed to `~/.shell-aliases.sh` and sourced from `.zshrc`.
- `Shared/vsCodeSetup/settings.json` — VS Code settings, deployed to the per-OS user settings path.
- `Shared/Fonts/CascadiaCode/` — Cascadia Code Nerd Font TTF files.

### Helper Scripts (reusable, called by profiles)

- `Scripts/Install-Fonts.ps1` — Installs Cascadia Code Nerd Fonts into `C:\Windows\Fonts` via Shell.Application COM.
- `Scripts/Configure-Configs.ps1` — Syncs VS Code settings, Windows Terminal settings, PowerShell profile, Oh My Posh theme, and global Git config. Also wires up 1Password SSH commit signing if the op-ssh-sign.exe is present.

### Auto-Resume After Reboot (Windows)

`Setup-Lucye.ps1` uses `HKCU\...\RunOnce` to set a resume command before rebooting (needed for enabling WSL/Hyper-V features). On re-login, the script continues from where it left off using the `-Resumed` switch parameter.

## Key Conventions

**Idempotency**: Every install step checks if the tool is already present before installing. `winget list --id` for winget apps, `Get-Command` for Chocolatey tools, directory checks for WSL plugins.

**Path refresh**: `Refresh-EnvPaths` is called after winget and Chocolatey install blocks to make newly installed tools immediately available in the same session without a new terminal.

**Config deployment pattern**: Configs live in `Shared/` as source-of-truth. Scripts copy them to their OS-specific destination at install time. Editing a config here does not update a running machine — the setup script must be re-run or the file manually re-copied.

**WSL file transfer**: Files are piped via stdin (`Get-Content | wsl sh -c "cat > ~/.file"`) rather than writing to `\\wsl.localhost\` paths, to avoid Windows permission issues with WSL filesystem.

**Git commit style**: Conventional commits (`feat:`, `fix:`, `docs:`, `chore:`, etc.). The PowerShell profile includes wrapper functions (`gfeat`, `gfix`, `gdocs`, etc.) that enforce this format.

## Profile-Specific Notes

### Lucye (Windows)
- Dev projects live on a VHD mounted at `E:` (`D:\VHD\DevDrive.vhdx`). The `dev`/`projects` alias mounts it if needed.
- SSL certs for Angular dev server are at `D:\SSLCert\localhost.key` and `D:\SSLCert\localhost.crt`.
- The `ignite` command starts `ng serve --ssl` using those certs.
- WSL default distro: `Ubuntu-24.04`, default user matches the Windows login username.
- 1Password SSH signing is auto-configured if `op-ssh-sign.exe` exists at `$env:LOCALAPPDATA\Microsoft\WindowsApps\`.

### MacOS
- `REPO_ROOT` is derived as two directories up from the script location (`dirname $(dirname $(pwd))`). The script must be run from inside the repo, not from an arbitrary directory.
- Java (openjdk) and .NET SDK are installed via brew formulae without a version pin.
