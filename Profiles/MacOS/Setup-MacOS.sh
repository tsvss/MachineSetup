#!/bin/zsh
# Setup-MacOS.sh
# 🧙‍♂️ The MacOS Work Setup - A Professional Wizarding Experience
# Targets: .NET 10, Java, Node.js, Angular, Gemini CLI, Slack, Teams, Outlook, Insomnia

# --- Impeccable UX: Header & Progress ---
function show_header() {
    clear
    echo -e "\033[33m"
    cat << "EOF"
    
    .     .       .  .   . .   .   . .    +  .
      .     .  :     .    .. :. .___---------___.
           .  .   .    .  :.:. _".^ .^ ^.  '.. :"-_.
        .    .   .  .  .: :.. /| |  . . .^ ^  .^  | |
              .   .:::.::. ::\| | :  . .  .  .  : | |
         .   .   .:...:.:. .| | ^ .  . .^ ^  .^  | |
                ..:..:.. . .| |   .  .  .  .  .  | |
          .    :..:..:..:.. . \_  .  .  . ^  .  _/
               . `.:."`.;.`._ ^ _"-__..--__-"_  ^
        .       .. .. .. .. .. ..  ..  ..  ..
    
    🪄  WELCOME TO THE MACOS WORK SETUP WIZARD  🪄
    "Excellence is not a skill, it is a magical attitude."
EOF
    echo -e "\033[0m"
}

function cast_spell() {
    echo -e "\n\033[36m✨ Casting Spell: $1...\033[0m"
    sleep 1
}

# --- Execution ---

show_header

# 1. Homebrew
if ! command -v brew &> /dev/null; then
    cast_spell "Summoning Homebrew (The Cauldron)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Core Apps & Artifacts
cast_spell "Summoning the Core Artifacts"

# Casks
casks=(
    visual-studio-code
    docker
    1password
    warp
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

# Formulae
formulae=(
    git
    gh
    fnm
    python@3.13
    openjdk
    dotnet-sdk
    terraform
    kubernetes-cli
    helm
    awscli
)

brew update
for formula in "${formulae[@]}"; do
    brew install "$formula"
done

for cask in "${casks[@]}"; do
    brew install --cask "$cask"
done

# 3. Node & Global Tools
cast_spell "Brewing Node.js Potions"
eval "$(fnm env --use-on-cd)"
fnm install --latest
fnm use default
npm install -g @angular/cli @google/gemini-cli

# 4. Zsh & Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    cast_spell "Summoning Oh My Zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 5. Configurations & Fonts
cast_spell "Enchanting the Environment"
REPO_ROOT=$(dirname $(dirname $(pwd)))

# Fonts
cp "$REPO_ROOT/Shared/Fonts/CascadiaCode/"*.ttf ~/Library/Fonts/

# VS Code Sync
mkdir -p ~/Library/Application\ Support/Code/User/
cp "$REPO_ROOT/Shared/vsCodeSetup/settings.json" ~/Library/Application\ Support/Code/User/

# Git Config
git config --global user.name "Satya"
git config --global user.email "venkata.satya2910@gmail.com"
git config --global push.default current
git config --global push.autoSetupRemote true
git config --global pull.rebase true
git config --global core.editor "code --wait"
git config --global init.defaultBranch main

# 6. VS Code Extensions
cast_spell "Installing VS Code Extensions"
extensions=(
    dracula-theme.theme-dracula
    amazonwebservices.amazon-q-vscode
    ms-dotnettools.csdevkit
    ms-dotnettools.csharp
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    aaron-bond.better-comments
    formulahendry.auto-rename-tag
    naumovs.color-highlight
    anteprimorac.html-end-tag-labels
    github.vscode-pull-request-github
    eamodio.gitlens
    angular.ng-template
    ms-playwright.playwright
    yzhang.markdown-all-in-one
    davidanson.vscode-markdownlint
    rangav.vscode-thunder-client
)
for ext in "${extensions[@]}"; do
    code --install-extension "$ext" --force
done

# 7. Mac Specific Magic (Aliases)
cast_spell "Mirroring the Universal Spellbook (Aliases)"
cp "$REPO_ROOT/Shared/Scripts/shell-aliases.sh" ~/.shell-aliases.sh
if ! grep -q ".shell-aliases.sh" ~/.zshrc; then
    echo "source ~/.shell-aliases.sh" >> ~/.zshrc
fi

echo -e "\n\033[32m🎆 ALL SPELLS CAST SUCCESSFULLY! 🎆\033[0m"
echo -e "\033[33mYour MacOS Work environment is now impeccable.\033[0m"
