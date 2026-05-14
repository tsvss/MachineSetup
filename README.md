# README.md
# 🪄 MachineSetup: The Wizard's Repository

Welcome to the automated setup repository for your development environments. This project uses magical automation (PowerShell & Bash) to transfigure a fresh machine into a powerful workstation.

## 🌟 Profiles

We support multiple "wizarding" profiles to suit different environments:

| Profile | Target | OS | Status |
| :--- | :--- | :--- | :--- |
| **Lucye** | Personal | Windows/WSL | 🧙‍♂️ Active |
| **Lysa** | Work | Windows | 🧪 Brewing |
| **MacOS** | General | macOS | 🧪 Brewing |

## 🪄 Lucye Setup (Personal)

The Lucye setup is optimized for a full-stack developer working with .NET 10, Java, Python, Angular, and Cloud technologies.

### **Summoning the Magic**

To start the setup on a fresh Windows machine (using default Windows PowerShell):

1. Open PowerShell as **Administrator**.
2. Run the following command:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   cd E:\MachineSetup\Profiles\Lucye\Windows
   .\Setup-Lucye.ps1
   ```

### **What's Inside?**

- **Core Artifacts:** .NET 10 (Elder Wand), Java (Ancient Script), VS Code (Pensieve), Docker (Suitcase).
- **WSL Chamber:** Ubuntu 24.04 with Zsh, Oh My Zsh, and shared Node tools.
- **Enchantments:** Cascadia Code Nerd Font, synced VS Code settings, and Git configuration.
- **Vaults:** Google Drive (Gringotts), 1Password (Secret Keeper).

---

## 📁 Repository Structure

- `Profiles/`: Profile-specific setup scripts and configurations.
- `Scripts/`: Shared magical helpers (Font installation, Config syncing).
- `Fonts/`: The magical typefaces required for the terminal.
- `TerminalSetup/`: Configuration for Windows Terminal and Oh My Posh.
- `vsCodeSetup/`: Visual Studio Code settings and extensions.

---

## 📜 Legal Scrolls
This project is licensed under the MIT License. Use the magic responsibly.
