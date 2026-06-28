#!/bin/zsh
# Setup-MacOS.sh
# The MacOS Work Setup — Professional Developer Workstation
# Run from anywhere inside the repo: zsh Profiles/MacOS/Setup-MacOS.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ── UX helpers ────────────────────────────────────────────────────────────────

function show_header() {
    clear
    echo -e "                 \033[33m.\033[0m                  "
    echo -e "               \033[33m.   .\033[0m                "
    echo -e "             \033[33m.   :   .\033[0m              "
    echo -e "         \033[33m\` .   \\\\ | /   . '\033[0m          "
    echo -e "       \033[33m. - - - - * - - - - .\033[0m        "
    echo -e "         \033[33m. '   / | \\\\   . '\033[0m          "
    echo -e "             \033[33m.   :   .\033[0m              "
    echo -e "               \033[33m.   .\033[0m                "
    echo -e "                 \033[90m|\033[0m                  "
    echo -e "                 \033[90m|\033[0m                  "
    echo -e "                 \033[90m|\033[0m                  "
    echo -e "                 \033[90m|\033[0m                  "
    echo -e "                 \033[90m|\033[0m                  "
    echo -e "                 \033[90m|\033[0m                  "
    echo -e "                 \033[90m|\033[0m                  "
    echo -e "                 \033[90m|\033[0m                  "
    echo -e "                 \033[90m|\033[0m                  "
    echo -e "                 \033[90m|\033[0m                  "
    echo -e "                 \033[90mU\033[0m                  "
    echo ""
    echo -e "    \033[33m🪄  WELCOME TO THE MACOS WORK SETUP WIZARD  🪄\033[0m"
    echo -e "    \033[36m\"Excellence is not a skill, it is a magical attitude.\"\033[0m"
    echo ""
}

function cast_spell() {
    echo -e "\n\033[36m✨ Casting Spell: $1...\033[0m"
    sleep 1
}

# Append a line to ~/.zshrc only if it isn't already there.
function add_to_zshrc() {
    local line="$1"
    grep -qF "$line" ~/.zshrc 2>/dev/null || echo "$line" >> ~/.zshrc
}

show_header

# ── 0. Xcode Command Line Tools ───────────────────────────────────────────────
# Required by Homebrew and git. On a fresh Mac this is never present.
cast_spell "Checking Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
    echo -e "\033[33m⚠️  Xcode CLT not found — triggering installer...\033[0m"
    xcode-select --install
    echo ""
    echo -e "\033[33mComplete the Xcode CLT popup, then re-run this script.\033[0m"
    exit 0
fi
echo "  ✓ Xcode CLT present"

# ── 1. Homebrew ───────────────────────────────────────────────────────────────
cast_spell "Summoning Homebrew (The Cauldron)"
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Source brew for this session — handles Apple Silicon (/opt/homebrew) and Intel (/usr/local)
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
echo "  ✓ Homebrew ready"

# ── 2. Oh My Zsh ──────────────────────────────────────────────────────────────
# Install before any .zshrc edits: its installer resets .zshrc from its template.
cast_spell "Summoning Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "  ✓ Oh My Zsh installed"
else
    echo "  ✓ Oh My Zsh already present"
fi

# ── 3. Core formulae and casks ────────────────────────────────────────────────
cast_spell "Summoning the Core Artifacts"

formulae=(
    git
    gh
    fnm
    pure
    python@3.13
    openjdk
    dotnet-sdk
    terraform
    kubernetes-cli
    helm
    awscli
)

casks=(
    visual-studio-code
    docker
    1password
    insomnia
    google-chrome
    github
    ollama
    obsidian
    microsoft-teams
    microsoft-outlook
    slack
    pgadmin4
)

brew update

echo "  → Formulae..."
for formula in "${formulae[@]}"; do
    if brew list "$formula" &>/dev/null; then
        echo "    ✓ $formula"
    else
        brew install "$formula"
    fi
done

echo "  → Casks..."
for cask in "${casks[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
        echo "    ✓ $cask"
    else
        brew install --cask "$cask"
    fi
done

# ── 4. Node.js via fnm ────────────────────────────────────────────────────────
cast_spell "Brewing Node.js Potions"
eval "$(fnm env --use-on-cd)"
fnm install --latest
fnm use latest
fnm default latest
npm install -g @angular/cli @google/gemini-cli
echo "  ✓ Node $(node --version) via fnm, Angular CLI, Gemini CLI installed"

# ── 5. Wire tools into .zshrc ─────────────────────────────────────────────────
# These must come AFTER Oh My Zsh's installer so they're appended to the fresh template.
cast_spell "Wiring Up the Spellbook (.zshrc)"

# Homebrew PATH (persists across terminal sessions)
if [[ -f /opt/homebrew/bin/brew ]]; then
    add_to_zshrc 'eval "$(/opt/homebrew/bin/brew shellenv)"'
elif [[ -f /usr/local/bin/brew ]]; then
    add_to_zshrc 'eval "$(/usr/local/bin/brew shellenv)"'
fi

# fnm (makes `node`, `npm`, `npx` available in every new terminal)
add_to_zshrc 'eval "$(fnm env --use-on-cd)"'

# pure prompt — disable Oh My Zsh's theme engine and let pure own the prompt
sed -i '' 's/^ZSH_THEME=.*/ZSH_THEME=""/' ~/.zshrc
BREW_PREFIX="$(brew --prefix)"
add_to_zshrc "fpath+=(\"$BREW_PREFIX/share/zsh/site-functions\")"
add_to_zshrc 'autoload -U promptinit; promptinit'
add_to_zshrc 'prompt pure'

echo "  ✓ Homebrew, fnm, and pure prompt wired into ~/.zshrc"

# ── 6. Configurations ─────────────────────────────────────────────────────────
cast_spell "Enchanting the Environment"

# Fonts
cp "$REPO_ROOT/Shared/Fonts/CascadiaCode/"*.ttf ~/Library/Fonts/
echo "  ✓ Cascadia Code Nerd Fonts installed to ~/Library/Fonts"

# VS Code settings
mkdir -p ~/Library/Application\ Support/Code/User/
cp "$REPO_ROOT/Shared/vsCodeSetup/settings.json" ~/Library/Application\ Support/Code/User/settings.json
# The shared settings.json uses CRLF line endings (Windows default) — fix for macOS
sed -i '' 's/"prettier.endOfLine": "crlf"/"prettier.endOfLine": "lf"/' \
    ~/Library/Application\ Support/Code/User/settings.json
echo "  ✓ VS Code settings deployed"

# Git
git config --global user.name "Satya"
git config --global user.email "YOUR_WORK_EMAIL@company.com"
git config --global push.default current
git config --global push.autoSetupRemote true
git config --global pull.rebase true
git config --global core.editor "code --wait"
git config --global init.defaultBranch main
echo "  ✓ Git configured (remember to set user.email)"

# Dev folder (macOS equivalent of the Windows E: drive)
mkdir -p ~/Developer
echo "  ✓ ~/Developer ready"

# ── 7. VS Code Extensions ─────────────────────────────────────────────────────
# brew cask places the app at /Applications; the CLI lives inside the bundle.
cast_spell "Installing VS Code Extensions"

CODE_CMD="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
if [ ! -f "$CODE_CMD" ]; then
    CODE_CMD="$(command -v code 2>/dev/null || echo "")"
fi

extensions=(
    # Theme & icons
    dracula-theme.theme-dracula
    PKief.material-icon-theme
    # AI
    amazonwebservices.amazon-q-vscode
    # .NET
    ms-dotnettools.csdevkit
    ms-dotnettools.csharp
    # Web / TS
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    aaron-bond.better-comments
    formulahendry.auto-rename-tag
    naumovs.color-highlight
    anteprimorac.html-end-tag-labels
    # Git
    github.vscode-pull-request-github
    eamodio.gitlens
    # Angular
    angular.ng-template
    ms-playwright.playwright
    # Markdown
    yzhang.markdown-all-in-one
    davidanson.vscode-markdownlint
    streetsidesoftware.code-spell-checker
    # API / HTTP
    rangav.vscode-thunder-client
    # Infrastructure
    hashicorp.terraform
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-azuretools.vscode-docker
    # YAML (used by docker-compose and GitHub Actions formatters in settings)
    redhat.vscode-yaml
)

if [ -n "$CODE_CMD" ] && [ -f "$CODE_CMD" ]; then
    for ext in "${extensions[@]}"; do
        # Skip comment lines
        [[ "$ext" == \#* ]] && continue
        "$CODE_CMD" --install-extension "$ext" --force
    done
    echo "  ✓ VS Code extensions installed"
else
    echo -e "  \033[33m⚠️  VS Code CLI not found — open VS Code to install extensions.\033[0m"
fi

# ── 8. macOS System Preferences ───────────────────────────────────────────────
cast_spell "Tuning macOS System Preferences"

# Dock: auto-hide, compact size, no recent apps clutter
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock show-recents -bool false

# Finder: show path bar, status bar, all extensions; search inside current folder
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Keyboard: fast key repeat (comfortable for developers used to fast Windows repeat)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Trackpad: tap to click (muscle memory from Windows touchpads)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Screenshots: dedicated folder instead of cluttering the Desktop
mkdir -p ~/Desktop/Screenshots
defaults write com.apple.screencapture location ~/Desktop/Screenshots

# No .DS_Store noise on network or USB drives
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
echo "  ✓ macOS system preferences applied"

# ── 9. Shell aliases ──────────────────────────────────────────────────────────
cast_spell "Mirroring the Universal Spellbook (Aliases)"
cp "$REPO_ROOT/Shared/Scripts/shell-aliases.sh" ~/.shell-aliases.sh
add_to_zshrc 'source ~/.shell-aliases.sh'
echo "  ✓ Shell aliases deployed and sourced in ~/.zshrc"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "\033[32m╔═══════════════════════════════════════════════════╗\033[0m"
echo -e "\033[32m║      🎆  ALL SPELLS CAST SUCCESSFULLY!  🎆        ║\033[0m"
echo -e "\033[32m╚═══════════════════════════════════════════════════╝\033[0m"
echo ""
echo -e "\033[33mNext steps:\033[0m"
echo -e "  1. Set your work email:  \033[36mgit config --global user.email \"you@company.com\"\033[0m"
echo -e "  2. Sign in to 1Password and Docker"
echo -e "  3. Authenticate GitHub CLI: \033[36mgh auth login\033[0m"
echo -e "  4. Authenticate AWS CLI:    \033[36maws configure\033[0m"
echo -e "  5. Restart terminal (or:    \033[36msource ~/.zshrc\033[0m)"
echo ""
echo -e "\033[36mYour MacOS Work environment is now impeccable. ✨\033[0m"
