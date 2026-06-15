# 🪄 MachineSetup: The Wizard's Repository

Welcome to the automated setup repository for your development environments. This project uses magical automation (PowerShell & Bash) to transfigure a fresh machine into a powerful workstation.

## 🌟 Profiles

We support multiple "wizarding" profiles to suit different environments:

| Profile | Target | OS | Status |
| :--- | :--- | :--- | :--- |
| **Lucye** | Personal | Windows/WSL | 🧙‍♂️ Active |
| **Lysa** | Work | Windows | 🧪 Brewing |
| **MacOS** | Work | MacOS | 🧙‍♂️ Active |

## 🪄 Lucye Setup (Personal Windows)

The Lucye setup is optimized for a full-stack developer working with .NET 10, Java, Python, Angular, and Cloud technologies on Windows and WSL.

### **Summoning on Windows (Zero-Git Bootstrapping)**

On a brand-new machine without Git installed, you can bootstrap the entire setup with this single command in a **Windows PowerShell** (Administrator) window:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tsvss/MachineSetup/zero-touch-setup/bootstrap.ps1'))
```

## 🪄 MacOS Setup (Professional Work)

The MacOS setup is a professional wizard's kit for work, including Teams, Outlook, Slack, and professional database tools.

### **Summoning on MacOS**

For your Mac, open the Terminal and cast this spell:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/tsvss/MachineSetup/zero-touch-setup/Profiles/MacOS/Setup-MacOS.sh)"
```

*Note: This will install Homebrew, summon professional Artifacts (Teams, Slack, etc.), and configure Zsh/Oh My Zsh automatically.*


### **Manual Summoning**

If you already have Git installed:

1. **Clone the repository:**
   ```powershell
   git clone -b zero-touch-setup https://github.com/tsvss/MachineSetup.git
   cd MachineSetup
   ```
2. **Run the central wizard:**
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\Start-Magic.ps1
   ```

### **What's Inside?**

- **Core Artifacts:** .NET 10 (Elder Wand), Java 25 (Ancient Script), VS Code (Pensieve), Docker (Suitcase).
- **WSL Chamber:** Ubuntu 24.04 with Zsh, Oh My Zsh, and shared Node tools (Angular, Gemini CLI).
- **Enchantments:** Cascadia Code Nerd Font, synced VS Code settings (Dracula), and Git configuration.
- **Vaults:** Google Drive (Gringotts), 1Password (Secret Keeper).

---

## 📁 Repository Structure

- `Profiles/`: Profile-specific setup scripts and configurations (e.g., Lucye).
- `Shared/`: Shared magical assets (Fonts, Terminal themes, VS Code settings).
- `Scripts/`: Reusable magical helpers (Font installation, Config syncing).
- `bootstrap.ps1`: The initial spark for fresh machines.
- `Start-Magic.ps1`: The central portal to select your profile.

---

## 📜 Legal Scrolls
This project is licensed under the MIT License. Use the magic responsibly.
