using namespace System.Management.Automation
using namespace System.Management.Automation.Language
 
if ($host.Name -eq 'ConsoleHost') {
    Import-Module PSReadLine
}
Import-Module -Name Terminal-Icons
Import-Module z
Import-Module -Name Microsoft.WinGet.CommandNotFound
set-alias desktop "Desktop.ps1"
 

#region Profile Settings
# Paths and shared settings
$Global:ProjectRoot = 'C:\ProjectFiles'
$Global:OhMyPoshThemePath = "C:\Users\$([Environment]::UserName)\oh-my-posh\theme.json"
$Global:EndorctlPath = Join-Path $HOME 'endorctl.exe'
$Global:SslKeyPath = Join-Path $Global:ProjectRoot 'misc\SSLCert\cert.key'
$Global:SslCertPath = Join-Path $Global:ProjectRoot 'misc\SSLCert\cert.crt'
#endregion Profile Settings

Set-Alias -Name endorctl -Value $Global:EndorctlPath

oh-my-posh --init --shell pwsh --config $Global:OhMyPoshThemePath | Invoke-Expression
fnm env --use-on-cd | Out-String | Invoke-Expression

#region Navigation & FS helpers
<#
.SYNOPSIS
 Change directory one level up.
.EXAMPLE
 ..
#>
function .. {
    Set-Location ..
}
<#
.SYNOPSIS
 Change directory two levels up.
.EXAMPLE
 ....
#>
function .... {
    Set-Location ../../
}
<#
.SYNOPSIS
 Change directory three levels up.
.EXAMPLE
 ......
#>
function ...... {
    Set-Location ../../../
}

<#
.SYNOPSIS
 Force remove file or folder recursively.
.PARAMETER args
 Path to remove.
.EXAMPLE
 rmf .\dist
#>
function rmf{
    Write-Host "🗑️ Removing: $args (recursive, force)" -ForegroundColor Yellow
    try {
        Remove-Item -Path "$args" -Recurse -Force -ErrorAction Stop
        Write-Host "✅ Removed: $args" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to remove: $args. $_" -ForegroundColor Red
        throw
    }
}

<#
.SYNOPSIS
 Create a new folder and switch into it.
.PARAMETER name
 Name of the new folder.
.EXAMPLE
 nf MyApp
#>
function nf ($name){
     Write-Host "📁 Creating and switching to new folder: $name" -ForegroundColor Cyan
     mkdir $name | cd $name
}

<#
.SYNOPSIS
 Jump to your project root directory.
.EXAMPLE
 projects
#>
function projects{
    Write-Host "📂 Switching to project root: $Global:ProjectRoot" -ForegroundColor Cyan
    Set-Location $Global:ProjectRoot
}

#endregion Navigation & FS helpers
#
#region Git helpers

<#
.SYNOPSIS
 Switch to a git branch (wrapper around 'git switch').
.PARAMETER args
 Branch name and/or flags.
.EXAMPLE
 gswitch feature/xyz
#>
function gswitch {
    Write-Host "🔀 Switching to branch: $args" -ForegroundColor Cyan
    git switch $args
}

<#
.SYNOPSIS
 Create and switch to a new branch.
.PARAMETER args
 Branch name.
.EXAMPLE
 gb feature/xyz
#>
function gb {
    Write-Host "🌱 Creating and switching to new branch: $args" -ForegroundColor Cyan
    git checkout -b $args
}
 
<#
.SYNOPSIS
 Create and switch to a new task branch.
.PARAMETER taskid
 Task identifier to use as task/<id>.
.EXAMPLE
 gbt 1234
#>
function gbt ([string] $taskid) {
    Write-Host "🧩 Creating and switching to new task branch: task/$taskid" -ForegroundColor Cyan
    git checkout -b "task/$taskid"
}

<#
.SYNOPSIS
 Commit with ticket ID prefix extracted from current branch.
.DESCRIPTION
 Builds summary as "[TICKET] Summary" (TICKET inferred from current branch name split by '-' or '_').
 If Description is provided, it's used as the commit body.
.PARAMETER Summary
 Commit summary line.
.PARAMETER Description
 Optional commit body/description.
.EXAMPLE
 gsco -Summary "Refactor login flow" -Description "Extract helpers into TokenUtils"
#>
function gsco{
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Summary,
        [Parameter(Position = 1)]
        [string] $Description
    )
    $currentBranch = git branch --show-current
    $parts = $currentBranch -split "[-_]"
    $ticketId = $parts[0] + '-' + $parts[1]
    Write-Host "Committing changes for $ticketId" -ForegroundColor Cyan

    $prefixedSummary = "[$ticketId] $Summary"
    Write-Host "Summary: $prefixedSummary" -ForegroundColor Cyan
    if ($PSBoundParameters.ContainsKey('Description') -and $null -ne $Description -and $Description -ne '') {
        gco -Summary $prefixedSummary -Description $Description
    } else {
        gco -Summary $prefixedSummary
    }
}

<#
.SYNOPSIS
 Checkout a branch and pull latest changes.
.PARAMETER args
 Branch name.
.EXAMPLE
 gs main
#>
function gs {
    Write-Host "🔁 Checking out '$args' and pulling latest ⬇️..." -ForegroundColor Cyan
    git checkout $args
    git pull
}
 
<#
.SYNOPSIS
 Switch to 'master' and pull.
.EXAMPLE
 gmaster
#>
function gmaster {
    gs 'master'
}
 
<#
.SYNOPSIS
 Switch to 'main' and pull.
.EXAMPLE
 gmain
#>
function gmain {
    gs 'main'
}
 
<#
.SYNOPSIS
 Switch to 'develop' and pull.
.EXAMPLE
 gdev
#>
function gdev {
    gs 'develop'
}
 
<#
.SYNOPSIS
 Fetch and rebase current branch onto origin/<branch>.
.PARAMETER args
 Branch to rebase onto (e.g., main).
.EXAMPLE
 grb main
#>
function grb {
    Write-Host "⬇️  Fetching from origin..." -ForegroundColor Cyan
    git fetch
    Write-Host "🔁 Rebasing current branch onto origin/$args..." -ForegroundColor Yellow
    git rebase origin/$args
}
 
<#
.SYNOPSIS
 Stage all changes and create a commit with a summary and optional description.
.DESCRIPTION
 Runs 'git add .' then 'git commit' using a required summary (-m) and optional description as a second -m.
.PARAMETER Summary
 Commit summary line (the first -m message).
.PARAMETER Description
 Optional commit body/description (appended as a second -m message).
.EXAMPLE
 gco -Summary "fix: handle null token" -Description "Guard refresh path and add tests"
#>
function gco {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Summary,
        [Parameter(Position = 1)]
        [string] $Description
    )
    Write-Host "📦 Staging all changes..." -ForegroundColor DarkCyan
    git add .
    if ($PSBoundParameters.ContainsKey('Description') -and $null -ne $Description -and $Description -ne '') {
        Write-Host "📝 Committing: $Summary (with description)" -ForegroundColor Green
        git commit -m $Summary -m $Description
    } else {
        Write-Host "📝 Committing: $Summary" -ForegroundColor Green
        git commit -m $Summary
    }
}

<#
.SYNOPSIS
 Delete all local branches except ones that contain 'main'.
.EXAMPLE
 goblivion
#>
function goblivion {
    Write-Host "⚠️🧹 Deleting all local branches except those containing 'main'." -ForegroundColor Yellow
    git branch | Where-Object { $_ -notlike "*main*" } | ForEach-Object { git branch -D $_.Trim() }
}
 
<#
.SYNOPSIS
 Conventional commit: feat
.DESCRIPTION
 Creates a conventional commit summary "feat: Summary" or "feat(Scope): Summary" if -Scope is provided.
 Description (if provided) is used as the commit body.
.PARAMETER Summary
 Commit summary subject.
.PARAMETER Description
 Optional commit body/description.
.PARAMETER Scope
 Optional scope for the conventional commit. Alias: scope
.EXAMPLE
 gfeat -Summary "add dashboard"
.EXAMPLE
 gfeat -Scope "auth" -Summary "add JWT support" -Description "Introduce token service"
#>
function gfeat {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Summary,
        [Parameter(Position = 1)]
        [string] $Description,
        [Alias('scope')]
        [string] $Scope
    )
    $line = if ($PSBoundParameters.ContainsKey('Scope') -and $null -ne $Scope -and $Scope -ne '') { "feat($Scope): $Summary" } else { "feat: $Summary" }
    if ($PSBoundParameters.ContainsKey('Description') -and $null -ne $Description -and $Description -ne '') {
        gco -Summary $line -Description $Description
    } else {
        gco -Summary $line
    }
}
 
<#
.SYNOPSIS
 Conventional commit: fix
.DESCRIPTION
 Creates a conventional commit summary "fix: Summary" or "fix(Scope): Summary" if -Scope is provided.
.PARAMETER Summary
 Commit summary subject.
.PARAMETER Description
 Optional commit body/description.
.PARAMETER Scope
 Optional scope for the conventional commit. Alias: scope
.EXAMPLE
 gfix -Summary "null ref on dashboard"
.EXAMPLE
 gfix -Scope "auth" -Summary "token refresh race" -Description "Add lock and retry"
#>
function gfix {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Summary,
        [Parameter(Position = 1)]
        [string] $Description,
        [Alias('scope')]
        [string] $Scope
    )
    $line = if ($PSBoundParameters.ContainsKey('Scope') -and $null -ne $Scope -and $Scope -ne '') { "fix($Scope): $Summary" } else { "fix: $Summary" }
    if ($PSBoundParameters.ContainsKey('Description') -and $null -ne $Description -and $Description -ne '') {
        gco -Summary $line -Description $Description
    } else {
        gco -Summary $line
    }
}
 
<#
.SYNOPSIS
 Conventional commit: test
.DESCRIPTION
 Creates a conventional commit summary "test: Summary" or "test(Scope): Summary" if -Scope is provided.
.PARAMETER Summary
 Commit summary subject.
.PARAMETER Description
 Optional commit body/description.
.PARAMETER Scope
 Optional scope for the conventional commit. Alias: scope
#>
function gtest {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Summary,
        [Parameter(Position = 1)]
        [string] $Description,
        [Alias('scope')]
        [string] $Scope
    )
    $line = if ($PSBoundParameters.ContainsKey('Scope') -and $null -ne $Scope -and $Scope -ne '') { "test($Scope): $Summary" } else { "test: $Summary" }
    if ($PSBoundParameters.ContainsKey('Description') -and $null -ne $Description -and $Description -ne '') {
        gco -Summary $line -Description $Description
    } else {
        gco -Summary $line
    }
}
 
<#
.SYNOPSIS
 Conventional commit: docs
.DESCRIPTION
 Creates a conventional commit summary "docs: Summary" or "docs(Scope): Summary" if -Scope is provided.
.PARAMETER Summary
 Commit summary subject.
.PARAMETER Description
 Optional commit body/description.
.PARAMETER Scope
 Optional scope for the conventional commit. Alias: scope
#>
function gdocs {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Summary,
        [Parameter(Position = 1)]
        [string] $Description,
        [Alias('scope')]
        [string] $Scope
    )
    $line = if ($PSBoundParameters.ContainsKey('Scope') -and $null -ne $Scope -and $Scope -ne '') { "docs($Scope): $Summary" } else { "docs: $Summary" }
    if ($PSBoundParameters.ContainsKey('Description') -and $null -ne $Description -and $Description -ne '') {
        gco -Summary $line -Description $Description
    } else {
        gco -Summary $line
    }
}
 
<#
.SYNOPSIS
 Conventional commit: style
.DESCRIPTION
 Creates a conventional commit summary "style: Summary" or "style(Scope): Summary" if -Scope is provided.
.PARAMETER Summary
 Commit summary subject.
.PARAMETER Description
 Optional commit body/description.
.PARAMETER Scope
 Optional scope for the conventional commit. Alias: scope
#>
function gstyle {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Summary,
        [Parameter(Position = 1)]
        [string] $Description,
        [Alias('scope')]
        [string] $Scope
    )
    $line = if ($PSBoundParameters.ContainsKey('Scope') -and $null -ne $Scope -and $Scope -ne '') { "style($Scope): $Summary" } else { "style: $Summary" }
    if ($PSBoundParameters.ContainsKey('Description') -and $null -ne $Description -and $Description -ne '') {
        gco -Summary $line -Description $Description
    } else {
        gco -Summary $line
    }
}
 
<#
.SYNOPSIS
 Conventional commit: refactor
.DESCRIPTION
 Creates a conventional commit summary "refactor: Summary" or "refactor(Scope): Summary" if -Scope is provided.
.PARAMETER Summary
 Commit summary subject.
.PARAMETER Description
 Optional commit body/description.
.PARAMETER Scope
 Optional scope for the conventional commit. Alias: scope
#>
function grefactor {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Summary,
        [Parameter(Position = 1)]
        [string] $Description,
        [Alias('scope')]
        [string] $Scope
    )
    $line = if ($PSBoundParameters.ContainsKey('Scope') -and $null -ne $Scope -and $Scope -ne '') { "refactor($Scope): $Summary" } else { "refactor: $Summary" }
    if ($PSBoundParameters.ContainsKey('Description') -and $null -ne $Description -and $Description -ne '') {
        gco -Summary $line -Description $Description
    } else {
        gco -Summary $line
    }
}
 
<#
.SYNOPSIS
 Conventional commit: perf
.DESCRIPTION
 Creates a conventional commit summary "perf: Summary" or "perf(Scope): Summary" if -Scope is provided.
.PARAMETER Summary
 Commit summary subject.
.PARAMETER Description
 Optional commit body/description.
.PARAMETER Scope
 Optional scope for the conventional commit. Alias: scope
#>
function gperf {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Summary,
        [Parameter(Position = 1)]
        [string] $Description,
        [Alias('scope')]
        [string] $Scope
    )
    $line = if ($PSBoundParameters.ContainsKey('Scope') -and $null -ne $Scope -and $Scope -ne '') { "perf($Scope): $Summary" } else { "perf: $Summary" }
    if ($PSBoundParameters.ContainsKey('Description') -and $null -ne $Description -and $Description -ne '') {
        gco -Summary $line -Description $Description
    } else {
        gco -Summary $line
    }
}
 
<#
.SYNOPSIS
 Conventional commit: chore
.DESCRIPTION
 Creates a conventional commit summary "chore: Summary" or "chore(Scope): Summary" if -Scope is provided.
.PARAMETER Summary
 Commit summary subject.
.PARAMETER Description
 Optional commit body/description.
.PARAMETER Scope
 Optional scope for the conventional commit. Alias: scope
#>
function gchore {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Summary,
        [Parameter(Position = 1)]
        [string] $Description,
        [Alias('scope')]
        [string] $Scope
    )
    $line = if ($PSBoundParameters.ContainsKey('Scope') -and $null -ne $Scope -and $Scope -ne '') { "chore($Scope): $Summary" } else { "chore: $Summary" }
    if ($PSBoundParameters.ContainsKey('Description') -and $null -ne $Description -and $Description -ne '') {
        gco -Summary $line -Description $Description
    } else {
        gco -Summary $line
    }
}

<#
.SYNOPSIS
 Conventional commit: ci (workflow)
.DESCRIPTION
 Creates a conventional commit summary "ci: Summary" or "ci(Scope): Summary" if -Scope is provided.
.PARAMETER Summary
 Commit summary subject.
.PARAMETER Description
 Optional commit body/description.
.PARAMETER Scope
 Optional scope for the conventional commit. Alias: scope
#>
function gwf {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Summary,
        [Parameter(Position = 1)]
        [string] $Description,
        [Alias('scope')]
        [string] $Scope
    )
    $line = if ($PSBoundParameters.ContainsKey('Scope') -and $null -ne $Scope -and $Scope -ne '') { "ci($Scope): $Summary" } else { "ci: $Summary" }
    if ($PSBoundParameters.ContainsKey('Description') -and $null -ne $Description -and $Description -ne '') {
        gco -Summary $line -Description $Description
    } else {
        gco -Summary $line
    }
}
 
<#
.SYNOPSIS
 Pull latest changes for current branch.
.EXAMPLE
 gpu
#>
function gpu {
    Write-Host "⬇️  Pulling latest changes from current branch upstream..." -ForegroundColor Cyan
    git pull
}
 
<#
.SYNOPSIS
 Amend the last commit without changing its message.
.DESCRIPTION
 Stages all changes and runs 'git commit --amend --no-edit'. Useful for fixing up the most recent commit.
.EXAMPLE
 goops
#>
function goops {
    Write-Host "✏️ Amending last commit (message unchanged)..." -ForegroundColor Yellow
    git add .
    git commit --amend --no-edit
}
 
<#
.SYNOPSIS
 Force push with lease to protect remote updates.
.EXAMPLE
 gfp
#>
function gfp {
    Write-Host "🚀🛡️ Force pushing with lease to protect remote updates..." -ForegroundColor Yellow
    git push --force-with-lease
}

<#
.SYNOPSIS
 Push current branch; set upstream if it doesn't exist.
.EXAMPLE
 gpush
#>
function gpush {
    $currentBranch = git branch --show-current
    $command = "git ls-remote --heads origin $currentBranch"
    $result = Invoke-Expression $command 2>&1
    if ($result -match "refs/heads/$currentBranch") {
        git push
    } else {
        Write-Host "📡 Publishing current branch ($currentBranch) to origin" -ForegroundColor Cyan
        git push --set-upstream origin $currentBranch
    }   
    Write-Host "✅📤 Changes pushed to origin/$currentBranch" -ForegroundColor Green
}
 
<#
.SYNOPSIS
 Hard reset and clean untracked files/directories.
.EXAMPLE
 gr
#>
function gr {
    Write-Host "🚨 DANGER: Hard resetting and cleaning untracked files/folders." -ForegroundColor Red
    git reset --hard
    git clean -f -d
}

<#
.SYNOPSIS
 Show git status.
.EXAMPLE
 howdy
#>
function howdy {
    Write-Host "📋 Git status:" -ForegroundColor Cyan
    git status
}

#endregion Git helpers

#region Angular helpers
<#
.SYNOPSIS
 Start Angular dev server with SSL.
.PARAMETER port
 Optional port number.
.EXAMPLE
 ignite -port 4200
#>
function ignite {
    param(
        [int]$port
    )

    Write-Host "Igniting Angular server... 🚀" -ForegroundColor Green

    if ($port) {
        ng serve --ssl --ssl-key $Global:SslKeyPath --ssl-cert $Global:SslCertPath --port $port
    } else {
        ng serve --ssl --ssl-key $Global:SslKeyPath --ssl-cert $Global:SslCertPath
    }
}

#endregion Angular helpers

#region Argument completers
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

#endregion Argument completers

#region PSReadLine options and key bindings

# This is an example profile for PSReadLine.
#
# This is roughly what I use so there is some emphasis on emacs bindings,
# but most of these bindings make sense in Windows mode as well.

# Searching for commands with up/down arrow is really handy.  The
# option "moves to end" is useful if you want the cursor at the end
# of the line while cycling through history like it does w/o searching,
# without that option, the cursor will remain at the position it was
# when you used up arrow, which can be useful if you forget the exact
# string you started the search on.
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# This key handler shows the entire or filtered history using Out-GridView. The
# typed text is used as the substring pattern for filtering. A selected command
# is inserted to the command line without invoking. Multiple command selection
# is supported, e.g. selected by Ctrl + Click.
Set-PSReadLineKeyHandler -Key F7 `
    -BriefDescription History `
    -LongDescription 'Show command history' `
    -ScriptBlock {
    $pattern = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
    if ($pattern) {
        $pattern = [regex]::Escape($pattern)
    }

    $history = [System.Collections.ArrayList]@(
        $last = ''
        $lines = ''
        foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath)) {
            if ($line.EndsWith('`')) {
                $line = $line.Substring(0, $line.Length - 1)
                $lines = if ($lines) {
                    "$lines`n$line"
                }
                else {
                    $line
                }
                continue
            }

            if ($lines) {
                $line = "$lines`n$line"
                $lines = ''
            }

            if (($line -cne $last) -and (!$pattern -or ($line -match $pattern))) {
                $last = $line
                $line
            }
        }
    )
    $history.Reverse()

    $command = $history | Out-GridView -Title History -PassThru
    if ($command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
    }
}


# CaptureScreen is good for blog posts or email showing a transaction
# of what you did when asking for help or demonstrating a technique.
Set-PSReadLineKeyHandler -Chord 'Ctrl+d,Ctrl+c' -Function CaptureScreen

# The built-in word movement uses character delimiters, but token based word
# movement is also very useful - these are the bindings you'd use if you
# prefer the token based movements bound to the normal emacs word movement
# key bindings.
Set-PSReadLineKeyHandler -Key Alt+d -Function ShellKillWord
Set-PSReadLineKeyHandler -Key Alt+Backspace -Function ShellBackwardKillWord
Set-PSReadLineKeyHandler -Key Alt+b -Function ShellBackwardWord
Set-PSReadLineKeyHandler -Key Alt+f -Function ShellForwardWord
Set-PSReadLineKeyHandler -Key Alt+B -Function SelectShellBackwardWord
Set-PSReadLineKeyHandler -Key Alt+F -Function SelectShellForwardWord

#region Smart Insert/Delete

# The next four key handlers are designed to make entering matched quotes
# parens, and braces a nicer experience.  I'd like to include functions
# in the module that do this, but this implementation still isn't as smart
# as ReSharper, so I'm just providing it as a sample.

Set-PSReadLineKeyHandler -Key '"', "'" `
    -BriefDescription SmartInsertQuote `
    -LongDescription "Insert paired quotes if not already on a quote" `
    -ScriptBlock {
    param($key, $arg)

    $quote = $key.KeyChar

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    # If text is selected, just quote it without any smarts
    if ($selectionStart -ne -1) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $quote + $line.SubString($selectionStart, $selectionLength) + $quote)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
        return
    }

    $ast = $null
    $tokens = $null
    $parseErrors = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)

    function FindToken {
        param($tokens, $cursor)

        foreach ($token in $tokens) {
            if ($cursor -lt $token.Extent.StartOffset) { continue }
            if ($cursor -lt $token.Extent.EndOffset) {
                $result = $token
                $token = $token -as [StringExpandableToken]
                if ($token) {
                    $nested = FindToken $token.NestedTokens $cursor
                    if ($nested) { $result = $nested }
                }

                return $result
            }
        }
        return $null
    }

    $token = FindToken $tokens $cursor

    # If we're on or inside a **quoted** string token (so not generic), we need to be smarter
    if ($token -is [StringToken] -and $token.Kind -ne [TokenKind]::Generic) {
        # If we're at the start of the string, assume we're inserting a new string
        if ($token.Extent.StartOffset -eq $cursor) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote ")
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            return
        }

        # If we're at the end of the string, move over the closing quote if present.
        if ($token.Extent.EndOffset -eq ($cursor + 1) -and $line[$cursor] -eq $quote) {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            return
        }
    }

    if ($null -eq $token -or
        $token.Kind -eq [TokenKind]::RParen -or $token.Kind -eq [TokenKind]::RCurly -or $token.Kind -eq [TokenKind]::RBracket) {
        if ($line[0..$cursor].Where{ $_ -eq $quote }.Count % 2 -eq 1) {
            # Odd number of quotes before the cursor, insert a single quote
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
        }
        else {
            # Insert matching quotes, move cursor to be in between the quotes
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote")
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
        }
        return
    }

    # If cursor is at the start of a token, enclose it in quotes.
    if ($token.Extent.StartOffset -eq $cursor) {
        if ($token.Kind -eq [TokenKind]::Generic -or $token.Kind -eq [TokenKind]::Identifier -or 
            $token.Kind -eq [TokenKind]::Variable -or $token.TokenFlags.hasFlag([TokenFlags]::Keyword)) {
            $end = $token.Extent.EndOffset
            $len = $end - $cursor
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace($cursor, $len, $quote + $line.SubString($cursor, $len) + $quote)
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($end + 2)
            return
        }
    }

    # We failed to be smart, so just insert a single quote
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
}

Set-PSReadLineKeyHandler -Key '(', '{', '[' `
    -BriefDescription InsertPairedBraces `
    -LongDescription "Insert matching braces" `
    -ScriptBlock {
    param($key, $arg)

    $closeChar = switch ($key.KeyChar) {
        <#case#> '(' { [char]')'; break }
        <#case#> '{' { [char]'}'; break }
        <#case#> '[' { [char]']'; break }
    }

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    
    if ($selectionStart -ne -1) {
        # Text is selected, wrap it in brackets
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $key.KeyChar + $line.SubString($selectionStart, $selectionLength) + $closeChar)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    }
    else {
        # No text is selected, insert a pair
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
}

Set-PSReadLineKeyHandler -Key ')', ']', '}' `
    -BriefDescription SmartCloseBraces `
    -LongDescription "Insert closing brace or skip" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line[$cursor] -eq $key.KeyChar) {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
    }
}

Set-PSReadLineKeyHandler -Key Backspace `
    -BriefDescription SmartBackspace `
    -LongDescription "Delete previous character or matching quotes/parens/braces" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -gt 0) {
        $toMatch = $null
        if ($cursor -lt $line.Length) {
            switch ($line[$cursor]) {
                <#case#> '"' { $toMatch = '"'; break }
                <#case#> "'" { $toMatch = "'"; break }
                <#case#> ')' { $toMatch = '('; break }
                <#case#> ']' { $toMatch = '['; break }
                <#case#> '}' { $toMatch = '{'; break }
            }
        }

        if ($toMatch -ne $null -and $line[$cursor - 1] -eq $toMatch) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
        }
        else {
            [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
        }
    }
}

#endregion Smart Insert/Delete

# Sometimes you enter a command but realize you forgot to do something else first.
# This binding will let you save that command in the history so you can recall it,
# but it doesn't actually execute.  It also clears the line with RevertLine so the
# undo stack is reset - though redo will still reconstruct the command line.
Set-PSReadLineKeyHandler -Key Alt+w `
    -BriefDescription SaveInHistory `
    -LongDescription "Save current line in history but do not execute" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
}

# Insert text from the clipboard as a here string
Set-PSReadLineKeyHandler -Key Ctrl+V `
    -BriefDescription PasteAsHereString `
    -LongDescription "Paste the clipboard text as a here string" `
    -ScriptBlock {
    param($key, $arg)

    Add-Type -Assembly PresentationCore
    if ([System.Windows.Clipboard]::ContainsText()) {
        # Get clipboard text - remove trailing spaces, convert \r\n to \n, and remove the final \n.
        $text = ([System.Windows.Clipboard]::GetText() -replace "\p{Zs}*`r?`n", "`n").TrimEnd()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("@'`n$text`n'@")
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::Ding()
    }
}

# Sometimes you want to get a property of invoke a member on what you've entered so far
# but you need parens to do that.  This binding will help by putting parens around the current selection,
# or if nothing is selected, the whole line.
Set-PSReadLineKeyHandler -Key 'Alt+(' `
    -BriefDescription ParenthesizeSelection `
    -LongDescription "Put parenthesis around the selection or entire line and move the cursor to after the closing parenthesis" `
    -ScriptBlock {
    param($key, $arg)

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($selectionStart -ne -1) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '(' + $line.SubString($selectionStart, $selectionLength) + ')')
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, '(' + $line + ')')
        [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
    }
}

# Each time you press Alt+', this key handler will change the token
# under or before the cursor.  It will cycle through single quotes, double quotes, or
# no quotes each time it is invoked.
Set-PSReadLineKeyHandler -Key "Alt+'" `
    -BriefDescription ToggleQuoteArgument `
    -LongDescription "Toggle quotes on the argument under the cursor" `
    -ScriptBlock {
    param($key, $arg)

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    $tokenToChange = $null
    foreach ($token in $tokens) {
        $extent = $token.Extent
        if ($extent.StartOffset -le $cursor -and $extent.EndOffset -ge $cursor) {
            $tokenToChange = $token

            # If the cursor is at the end (it's really 1 past the end) of the previous token,
            # we only want to change the previous token if there is no token under the cursor
            if ($extent.EndOffset -eq $cursor -and $foreach.MoveNext()) {
                $nextToken = $foreach.Current
                if ($nextToken.Extent.StartOffset -eq $cursor) {
                    $tokenToChange = $nextToken
                }
            }
            break
        }
    }

    if ($tokenToChange -ne $null) {
        $extent = $tokenToChange.Extent
        $tokenText = $extent.Text
        if ($tokenText[0] -eq '"' -and $tokenText[-1] -eq '"') {
            # Switch to no quotes
            $replacement = $tokenText.Substring(1, $tokenText.Length - 2)
        }
        elseif ($tokenText[0] -eq "'" -and $tokenText[-1] -eq "'") {
            # Switch to double quotes
            $replacement = '"' + $tokenText.Substring(1, $tokenText.Length - 2) + '"'
        }
        else {
            # Add single quotes
            $replacement = "'" + $tokenText + "'"
        }

        [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
            $extent.StartOffset,
            $tokenText.Length,
            $replacement)
    }
}

# This example will replace any aliases on the command line with the resolved commands.
Set-PSReadLineKeyHandler -Key "Alt+%" `
    -BriefDescription ExpandAliases `
    -LongDescription "Replace all aliases with the full command" `
    -ScriptBlock {
    param($key, $arg)

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    $startAdjustment = 0
    foreach ($token in $tokens) {
        if ($token.TokenFlags -band [TokenFlags]::CommandName) {
            $alias = $ExecutionContext.InvokeCommand.GetCommand($token.Extent.Text, 'Alias')
            if ($alias -ne $null) {
                $resolvedCommand = $alias.ResolvedCommandName
                if ($resolvedCommand -ne $null) {
                    $extent = $token.Extent
                    $length = $extent.EndOffset - $extent.StartOffset
                    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                        $extent.StartOffset + $startAdjustment,
                        $length,
                        $resolvedCommand)

                    # Our copy of the tokens won't have been updated, so we need to
                    # adjust by the difference in length
                    $startAdjustment += ($resolvedCommand.Length - $length)
                }
            }
        }
    }
}

# F1 for help on the command line - naturally
Set-PSReadLineKeyHandler -Key F1 `
    -BriefDescription CommandHelp `
    -LongDescription "Open the help window for the current command" `
    -ScriptBlock {
    param($key, $arg)

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    $commandAst = $ast.FindAll( {
            $node = $args[0]
            $node -is [CommandAst] -and
            $node.Extent.StartOffset -le $cursor -and
            $node.Extent.EndOffset -ge $cursor
        }, $true) | Select-Object -Last 1

    if ($commandAst -ne $null) {
        $commandName = $commandAst.GetCommandName()
        if ($commandName -ne $null) {
            $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
            if ($command -is [AliasInfo]) {
                $commandName = $command.ResolvedCommandName
            }

            if ($commandName -ne $null) {
                Get-Help $commandName -ShowWindow
            }
        }
    }
}


#
# Ctrl+Shift+j then type a key to mark the current directory.
# Ctrj+j then the same key will change back to that directory without
# needing to type Set-Location and won't change the command line.

#
$global:PSReadLineMarks = @{}

Set-PSReadLineKeyHandler -Key Ctrl+J `
    -BriefDescription MarkDirectory `
    -LongDescription "Mark the current directory" `
    -ScriptBlock {
    param($key, $arg)

    $key = [Console]::ReadKey($true)
    $global:PSReadLineMarks[$key.KeyChar] = $pwd
}

Set-PSReadLineKeyHandler -Key Ctrl+j `
    -BriefDescription JumpDirectory `
    -LongDescription "Goto the marked directory" `
    -ScriptBlock {
    param($key, $arg)

    $key = [Console]::ReadKey()
    $dir = $global:PSReadLineMarks[$key.KeyChar]
    if ($dir) {
        Set-Location $dir
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    }
}

Set-PSReadLineKeyHandler -Key Alt+j `
    -BriefDescription ShowDirectoryMarks `
    -LongDescription "Show the currently marked directories" `
    -ScriptBlock {
    param($key, $arg)

    $global:PSReadLineMarks.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{Key = $_.Key; Dir = $_.Value } } |
    Format-Table -AutoSize | Out-Host

    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}

# Auto correct 'git cmt' to 'git commit'
Set-PSReadLineOption -CommandValidationHandler {
    param([CommandAst]$CommandAst)

    switch ($CommandAst.GetCommandName()) {
        'git' {
            $gitCmd = $CommandAst.CommandElements[1].Extent
            switch ($gitCmd.Text) {
                'cmt' {
                    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                        $gitCmd.StartOffset, $gitCmd.EndOffset - $gitCmd.StartOffset, 'commit')
                }
            }
        }
    }
}

# `ForwardChar` accepts the entire suggestion text when the cursor is at the end of the line.
# This custom binding makes `RightArrow` behave similarly - accepting the next word instead of the entire suggestion text.
Set-PSReadLineKeyHandler -Key RightArrow `
    -BriefDescription ForwardCharAndAcceptNextSuggestionWord `
    -LongDescription "Move cursor one character to the right in the current editing line and accept the next word in suggestion when it's at the end of current editing line" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -lt $line.Length) {
        [Microsoft.PowerShell.PSConsoleReadLine]::ForwardChar($key, $arg)
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptNextSuggestionWord($key, $arg)
    }
}

# Cycle through arguments on current line and select the text. This makes it easier to quickly change the argument if re-running a previously run command from the history
# or if using a psreadline predictor. You can also use a digit argument to specify which argument you want to select, i.e. Alt+1, Alt+a selects the first argument
# on the command line. 
Set-PSReadLineKeyHandler -Key Alt+a `
    -BriefDescription SelectCommandArguments `
    -LongDescription "Set current selection to next command argument in the command line. Use of digit argument selects argument by position" `
    -ScriptBlock {
    param($key, $arg)
  
    $ast = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$null, [ref]$null, [ref]$cursor)
  
    $asts = $ast.FindAll( {
            $args[0] -is [System.Management.Automation.Language.ExpressionAst] -and
            $args[0].Parent -is [System.Management.Automation.Language.CommandAst] -and
            $args[0].Extent.StartOffset -ne $args[0].Parent.Extent.StartOffset
        }, $true)
  
    if ($asts.Count -eq 0) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Ding()
        return
    }
    
    $nextAst = $null

    if ($null -ne $arg) {
        $nextAst = $asts[$arg - 1]
    }
    else {
        foreach ($ast in $asts) {
            if ($ast.Extent.StartOffset -ge $cursor) {
                $nextAst = $ast
                break
            }
        } 
        
        if ($null -eq $nextAst) {
            $nextAst = $asts[0]
        }
    }

    $startOffsetAdjustment = 0
    $endOffsetAdjustment = 0

    if ($nextAst -is [System.Management.Automation.Language.StringConstantExpressionAst] -and
        $nextAst.StringConstantType -ne [System.Management.Automation.Language.StringConstantType]::BareWord) {
        $startOffsetAdjustment = 1
        $endOffsetAdjustment = 2
    }
  
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($nextAst.Extent.StartOffset + $startOffsetAdjustment)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetMark($null, $null)
    [Microsoft.PowerShell.PSConsoleReadLine]::SelectForwardChar($null, ($nextAst.Extent.EndOffset - $nextAst.Extent.StartOffset) - $endOffsetAdjustment)
}


Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows


# This is an example of a macro that you might use to execute a command.
# This will add the command to history.
Set-PSReadLineKeyHandler -Key Ctrl+Shift+b `
    -BriefDescription BuildCurrentDirectory `
    -LongDescription "Build the current directory" `
    -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    if (Test-Path -Path ".\package.json") {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("npm run build")
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("dotnet build")
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Key Ctrl+Shift+s `
    -BriefDescription StartCurrentDirectory `
    -LongDescription "Start the current directory" `
    -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    if (Test-Path -Path ".\package.json") {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("ng serve --ssl --ssl-key $Global:SslKeyPath --ssl-cert $Global:SslCertPath")
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("dotnet run")
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Key Ctrl+Shift+t `
    -BriefDescription BuildCurrentDirectory `
    -LongDescription "Build the current directory" `
    -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("dotnet test")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
#endregion PSReadLine options and key bindings
#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

#f45873b3-b655-43a6-b217-97c00aa0db58

#region Profile Capabilities
<#
.SYNOPSIS
 Show a categorized list of capabilities provided by this PowerShell profile.
.DESCRIPTION
 Displays commands, example usage, and a short description for each capability.
.EXAMPLE
 Show-ProfileCapabilities
#>
function Show-ProfileCapabilities {
    Write-Host ""; Write-Host "✨ Profile Capabilities ✨" -ForegroundColor Green

    # Navigation & Filesystem
    Write-Host "`n📁 [Navigation & Filesystem]" -ForegroundColor Magenta
    Write-Host "  Example: ↩️  ..                           -> Up one directory" -ForegroundColor Cyan
    Write-Host "  Example: ↩️  ....                         -> Up two directories" -ForegroundColor Cyan
    Write-Host "  Example: ↩️  ......                       -> Up three directories" -ForegroundColor Cyan
    Write-Host "  Example: 📁 nf MyApp                     -> Create folder 'MyApp' and cd into it" -ForegroundColor Cyan
    Write-Host "  Example: 🗑️ rmf .\dist                    -> Force remove folder/file recursively" -ForegroundColor Cyan
    Write-Host "  Example: 📂 projects                      -> Jump to $Global:ProjectRoot" -ForegroundColor Cyan

    # Git basics
    Write-Host "`n🌿 [Git: Branch & Sync]" -ForegroundColor Magenta
    Write-Host "  Example: 🔀 gswitch feature/x             -> git switch feature/x" -ForegroundColor Cyan
    Write-Host "  Example: 🌱 gb feature/x                  -> git checkout -b feature/x" -ForegroundColor Cyan
    Write-Host "  Example: 🧩 gbt 1234                      -> git checkout -b task/1234" -ForegroundColor Cyan
    Write-Host "  Example: 🔁 gs main                       -> checkout 'main' then pull" -ForegroundColor Cyan
    Write-Host "  Example: 🧭 gmaster|gmain|gdev            -> quick switch and pull" -ForegroundColor Cyan
    Write-Host "  Example: 🔁 grb main                      -> fetch then rebase onto origin/main" -ForegroundColor Cyan
    Write-Host "  Example: ⬇️  gpu                            -> git pull" -ForegroundColor Cyan
    Write-Host "  Example: 📤 gpush                          -> push (creates upstream if needed)" -ForegroundColor Cyan
    Write-Host "  Example: 🚀🛡️ gfp                             -> force push with lease" -ForegroundColor Cyan
    Write-Host "  Example: 🚨 gr                              -> HARD reset and clean (dangerous)" -ForegroundColor Cyan
    Write-Host "  Example: ⚠️🧹 goblivion                      -> Delete all local branches except ones containing 'main' (dangerous)" -ForegroundColor Yellow
    Write-Host "  Example: 📋 howdy                          -> git status" -ForegroundColor Cyan

    # Git commits
    Write-Host "`n📝 [Git: Commits]" -ForegroundColor Magenta
    Write-Host "  Example: 📝 gco -Summary 'fix: bug' -Description 'details'" -ForegroundColor Cyan
    Write-Host "           -> Stage all and commit with summary and optional description" -ForegroundColor Gray
    Write-Host "  Example: 🧾 gsco -Summary 'Refactor service' -Description 'extract helper'" -ForegroundColor Cyan
    Write-Host "           -> Prefix summary with [TICKET] from current branch" -ForegroundColor Gray
    Write-Host "  Example: 🧱 gfeat -Scope core -Summary 'add X' -Description 'Y' (also: gfix, gtest, gdocs, gstyle, grefactor, gperf, gchore, gwf)" -ForegroundColor Cyan
    Write-Host "           -> Conventional commit with optional scope" -ForegroundColor Gray
    Write-Host "  Example: ✏️ goops                          -> Amend last commit without changing message" -ForegroundColor Cyan

    # Angular
    Write-Host "`n🅰️ [Angular]" -ForegroundColor Magenta
    Write-Host "  Example: 🚀 ignite -port 4200              -> ng serve with SSL certs on port 4200" -ForegroundColor Cyan

    # Key bindings (PSReadLine)
    Write-Host "`n⌨️ [Key Bindings]" -ForegroundColor Magenta
    Write-Host "  Press F7                                -> 🗂️  Interactive history viewer" -ForegroundColor Cyan
    Write-Host "  Ctrl+J (mark) / Ctrl+j (jump)          -> 🏷️  Mark & jump to directories" -ForegroundColor Cyan
    Write-Host "  Alt+a                                   -> 🔤 Select next command argument" -ForegroundColor Cyan
    Write-Host "  RightArrow at EOL                       -> ➡️  Accept next suggestion word" -ForegroundColor Cyan

    # Argument completers
    Write-Host "`n🔌 [Argument Completers]" -ForegroundColor Magenta
    Write-Host "  winget and dotnet provide native completions" -ForegroundColor Cyan

    Write-Host "`n💡 Tip: Use Get-Help <function> -Detailed for usage & examples." -ForegroundColor Green
}
#endregion Profile Capabilities
