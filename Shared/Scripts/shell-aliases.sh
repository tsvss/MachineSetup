#!/bin/bash
# shell-aliases.sh
# Universal shell aliases and helpers for WSL, MacOS, and Linux

# region Navigation & FS helpers
alias ..='cd ..'
alias ....='cd ../../'
alias ......='cd ../../../'

function rmf() {
    echo "🗑️ Removing: $1 (recursive, force)"
    rm -rf "$1"
}

function nf() {
    echo "📁 Creating and switching to new folder: $1"
    mkdir -p "$1" && cd "$1"
}

# Adaptation for Windows drives in WSL
PROJECT_ROOT="/mnt/e"
alias projects="cd $PROJECT_ROOT && echo '📂 Switched to project root: $PROJECT_ROOT'"
alias dev="cd $PROJECT_ROOT && echo '💽 Switched to dev drive root: $PROJECT_ROOT'"

# endregion Navigation & FS helpers

# region Git helpers
alias gswitch='git switch'
alias gb='git checkout -b'
alias gbt='git checkout -b task/$1'

function gs() {
    echo "🔁 Checking out '$1' and pulling latest ⬇️..."
    git checkout "$1" && git pull
}

alias gmaster='gs master'
alias gmain='gs main'
alias gdev='gs develop'

function grb() {
    echo "⬇️ Fetching from origin..."
    git fetch
    echo "🔁 Rebasing current branch onto origin/$1..."
    git rebase "origin/$1"
}

function gco() {
    echo "📦 Staging all changes..."
    git add .
    if [ -n "$2" ]; then
        echo "📝 Committing: $1 (with description)"
        git commit -m "$1" -m "$2"
    else
        echo "📝 Committing: $1"
        git commit -m "$1"
    fi
}

function goblivion() {
    echo "⚠️🧹 Deleting all local branches except those containing 'main'."
    git branch | grep -v "main" | xargs git branch -D
}

function gfeat() {
    local msg="feat"
    if [ -n "$3" ]; then msg="feat($3)"; fi
    gco "$msg: $1" "$2"
}

function gfix() {
    local msg="fix"
    if [ -n "$3" ]; then msg="fix($3)"; fi
    gco "$msg: $1" "$2"
}

function gtest() {
    local msg="test"
    if [ -n "$3" ]; then msg="test($3)"; fi
    gco "$msg: $1" "$2"
}

function gdocs() {
    local msg="docs"
    if [ -n "$3" ]; then msg="docs($3)"; fi
    gco "$msg: $1" "$2"
}

function gstyle() {
    local msg="style"
    if [ -n "$3" ]; then msg="style($3)"; fi
    gco "$msg: $1" "$2"
}

function grefactor() {
    local msg="refactor"
    if [ -n "$3" ]; then msg="refactor($3)"; fi
    gco "$msg: $1" "$2"
}

function gperf() {
    local msg="perf"
    if [ -n "$3" ]; then msg="perf($3)"; fi
    gco "$msg: $1" "$2"
}

function gchore() {
    local msg="chore"
    if [ -n "$3" ]; then msg="chore($3)"; fi
    gco "$msg: $1" "$2"
}

function gwf() {
    local msg="ci"
    if [ -n "$3" ]; then msg="ci($3)"; fi
    gco "$msg: $1" "$2"
}

alias gpu='git pull'

function goops() {
    git add .
    if [ "$1" == "-Edit" ]; then
        git commit --amend
    elif [ -n "$1" ]; then
        git commit --amend -m "$1"
    else
        git commit --amend --no-edit
    fi
}

alias gfp='git push --force-with-lease'

function gpush() {
    local branch=$(git branch --show-current)
    git push || git push --set-upstream origin "$branch"
}

alias gr='git reset --hard && git clean -f -d'
alias howdy='git status'
# endregion Git helpers

# region Angular helpers
function ignite() {
    local port=${1:-4200}
    echo "🚀 Igniting Angular server on port $port..."
    ng serve --ssl --port "$port"
}
# endregion Angular helpers

# region Oh My Posh
if [ -x "$(command -v oh-my-posh)" ]; then
    current_shell=$(basename "$SHELL")
    if [ "$current_shell" = "zsh" ]; then
        eval "$(oh-my-posh init zsh --config ~/.oh-my-posh-theme.json)"
    else
        eval "$(oh-my-posh init bash --config ~/.oh-my-posh-theme.json)"
    fi
fi
# endregion

# region fzf helpers
if command -v fzf > /dev/null 2>&1; then
    function fcd() {
        local dir
        dir=$(find "${1:-.}" -type d 2>/dev/null | fzf --preview 'ls -la {}' --prompt="cd > ") && cd "$dir"
    }

    function fe() {
        local file
        file=$(find "${1:-.}" -type f 2>/dev/null | fzf --preview 'cat {}' --prompt="edit > ")
        [ -n "$file" ] && ${EDITOR:-code} "$file"
    }

    function gfz() {
        local branch
        branch=$(git branch -a 2>/dev/null | sed 's/^[ *]*//' | fzf --prompt="branch > ") || return
        git checkout "${branch#remotes/origin/}"
    }
fi
# endregion fzf helpers

# region Help
function aliases() {
    echo ""
    echo "✨ Available Shell Aliases & Functions ✨"
    echo ""
    echo "📁 [Navigation]"
    echo "  ..  ....  ......             -> Up 1 / 2 / 3 directories"
    echo "  nf <name>                    -> Create folder and cd into it"
    echo "  rmf <path>                   -> Force remove recursively"
    echo "  projects / dev               -> Jump to $PROJECT_ROOT (Dev Drive: /mnt/e)"
    echo ""
    echo "🌿 [Git: Branch & Sync]"
    echo "  gswitch <branch>             -> git switch"
    echo "  gb <branch>                  -> git checkout -b"
    echo "  gbt <id>                     -> git checkout -b task/<id>"
    echo "  gs <branch>                  -> checkout + pull"
    echo "  gmaster | gmain | gdev       -> quick switch & pull"
    echo "  grb <branch>                 -> fetch + rebase onto origin/<branch>"
    echo "  gpu                          -> git pull"
    echo "  gpush                        -> push (sets upstream if needed)"
    echo "  gfp                          -> force push with lease"
    echo "  gr                           -> HARD reset + clean (⚠️ dangerous)"
    echo "  goblivion                    -> delete all branches except 'main' (⚠️ dangerous)"
    echo "  howdy                        -> git status"
    echo ""
    echo "📝 [Git: Commits]"
    echo "  gco '<msg>' ['<body>']       -> stage all + commit"
    echo "  gfeat | gfix | gtest | gdocs | gstyle | grefactor | gperf | gchore | gwf"
    echo "       '<msg>' ['<body>'] ['<scope>']  -> conventional commit"
    echo "  goops [<msg>]                -> amend last commit"
    echo "  goops -Edit                  -> amend + open editor"
    echo ""
    echo "🅰️ [Angular]"
    echo "  ignite [<port>]              -> ng serve --ssl"
    echo ""
    if command -v fzf > /dev/null 2>&1; then
        echo "🔍 [fzf Fuzzy Search]"
        echo "  fcd [<dir>]                  -> fuzzy cd into a subdirectory"
        echo "  fe [<dir>]                   -> fuzzy open file in \$EDITOR"
        echo "  gfz                          -> fuzzy git branch switch"
        echo "  Ctrl+R                       -> fuzzy history search"
        echo "  Ctrl+T                       -> fuzzy file insert"
        echo "  Alt+C                        -> fuzzy cd"
        echo ""
    fi
    echo "💡 Run 'aliases' anytime to see this list."
    echo ""
}
# endregion Help
