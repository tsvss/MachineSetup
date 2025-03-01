# Powershell Profile

This PowerShell profile script customizes the PowerShell environment with various functions and features to enhance productivity. Below is a detailed description of the commands and functions included in the profile.

## Modules

- **PSReadLine**: Enhances the command-line editing experience.
- **Terminal-Icons**: Adds icons to the terminal.
- **z**: Directory jumping tool.
- **oh-my-posh**: Customizes the PowerShell prompt.
- **fnm**: Node.js version manager.

## Aliases

- **desktop**: Alias for running `Desktop.ps1`.

## Functions

### Navigation

- **..**: Moves up one directory.
- **....**: Moves up two directories.
- **......**: Moves up three directories.
- **dev**: Mounts and navigates to the development drive.

### Git Shortcuts

- **gb**: Creates a new branch.
- **gbt**: Creates a new branch with a task ID.
- **gs**: Checks out a branch and pulls the latest changes.
- **gmaster**: Checks out and pulls the master branch.
- **gmain**: Checks out and pulls the main branch.
- **gdev**: Checks out and pulls the develop branch.
- **grb**: Rebases the current branch.
- **gco**: Adds and commits changes.
- **gfeat**: Commits a feature.
- **gfix**: Commits a fix.
- **gtest**: Commits a test.
- **gdocs**: Commits documentation changes.
- **gstyle**: Commits style changes.
- **grefactor**: Commits refactoring changes.
- **gperf**: Commits performance improvements.
- **gchore**: Commits chore changes.
- **gpu**: Pulls the latest changes.
- **goops**: Amends the last commit.
- **gfp**: Pushes changes with force.
- **gpush**: Pushes changes.
- **gr**: Resets and cleans the repository.
- **howdy**: Shows the git status.

### Angular

- **ignite**: Starts the Angular development server with SSL.

### Argument Completion

- **winget**: Completes `winget` commands.
- **dotnet**: Completes `dotnet` commands.

### PSReadLine Key Handlers

- **UpArrow**: Searches command history backward.
- **DownArrow**: Searches command history forward.
- **F7**: Shows command history in a grid view.
- **Ctrl+d, Ctrl+c**: Captures the screen.
- **Alt+d**: Deletes the next word.
- **Alt+Backspace**: Deletes the previous word.
- **Alt+b**: Moves backward by word.
- **Alt+f**: Moves forward by word.
- **Alt+B**: Selects the previous word.
- **Alt+F**: Selects the next word.
- **"** and **'**: Inserts paired quotes.
- **(**, **{**, **[**: Inserts paired braces.
- **)**, **]**, **}**: Closes braces or skips.
- **Backspace**: Deletes the previous character or matching quotes/braces.
- **Alt+w**: Saves the current line in history without executing.
- **Ctrl+V**: Pastes clipboard text as a here string.
- **Alt+(**: Parenthesizes the selection or entire line.
- **Alt+'**: Toggles quotes on the argument under the cursor.
- **Alt+%**: Expands aliases to full commands.
- **F1**: Opens help for the current command.
- **Ctrl+J**: Marks the current directory.
- **Ctrl+j**: Jumps to a marked directory.
- **Alt+j**: Shows marked directories.
- **RightArrow**: Moves the cursor right or accepts the next suggestion word.
- **Alt+a**: Selects command arguments.

### PSReadLine Options

- **PredictionSource**: Sets the prediction source to history.
- **PredictionViewStyle**: Sets the prediction view style to list view.
- **EditMode**: Sets the edit mode to Windows.

### Macros

- **Ctrl+Shift+b**: Builds the current directory.
- **Ctrl+Shift+s**: Starts the current directory.
- **Ctrl+Shift+t**: Runs tests in the current directory.
