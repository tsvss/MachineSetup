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

# Project root differs by OS: VHD mount on Windows/WSL, ~/Developer on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    PROJECT_ROOT="$HOME/Developer"
else
    PROJECT_ROOT="/mnt/e"
fi
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

function gsco() {
    local branch ticket msg
    branch=$(git branch --show-current)
    ticket=$(echo "$branch" | grep -oE '[A-Z]+-[0-9]+' | head -1)
    if [ -z "$ticket" ]; then
        echo "⚠️  No Jira ticket found in branch '$branch' — committing without prefix"
        gco "$1" "$2"
        return
    fi
    msg="$ticket: $1"
    echo "🎫 Ticket: $ticket"
    gco "$msg" "$2"
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

# region Oh My Posh (WSL only — macOS uses pure, plain Linux skips, PowerShell has its own init)
_is_wsl() {
    [ -n "$WSL_DISTRO_NAME" ] || grep -qi microsoft /proc/version 2>/dev/null
}
if _is_wsl && [ -x "$(command -v oh-my-posh)" ]; then
    current_shell=$(basename "$SHELL")
    if [ "$current_shell" = "zsh" ]; then
        eval "$(oh-my-posh init zsh --config ~/.oh-my-posh-theme.json)"
    else
        eval "$(oh-my-posh init bash --config ~/.oh-my-posh-theme.json)"
    fi
fi
# endregion
