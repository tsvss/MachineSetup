# Windows to Mac — Developer Quick Reference

A practical cheat sheet for switching from Windows to macOS. Covers day-to-day things that trip up Windows users in the first few weeks.

---

## The Keyboard

The biggest mental shift. Mac has no Windows key and Ctrl behaves differently.

| Windows | Mac | Notes |
|---------|-----|-------|
| `Ctrl` | `Cmd (⌘)` | Almost every shortcut swaps Ctrl → Cmd |
| `Alt` | `Option (⌥)` | |
| `Win` key | `Cmd+Space` | Opens Spotlight (universal search — use it constantly) |
| `Ctrl+Alt+Del` | `Cmd+Option+Esc` | Force Quit menu |
| `Delete` (forward) | `Fn+Delete` | Mac's Delete key = Backspace. Fn+Delete = forward delete |
| `Home / End` | `Cmd+← / Cmd+→` | Jump to start/end of line |
| `Ctrl+Home/End` | `Cmd+↑ / Cmd+↓` | Jump to top/bottom of document |
| `PrintScreen` | `Cmd+Shift+3` | See Screenshots section below |
| `Alt+F4` | `Cmd+Q` | Quit app entirely |
| `Alt+Tab` | `Cmd+Tab` | Switch between apps |
| — | `Cmd+\`` | Switch between windows of the *same* app |

> Mac `Ctrl` still exists but is mostly for terminal shortcuts (Ctrl+C, Ctrl+Z). In GUI apps, use `Cmd`.

---

## Screenshots

| Action | Shortcut |
|--------|----------|
| Capture entire screen | `Cmd+Shift+3` |
| Capture a selected area | `Cmd+Shift+4` then drag |
| Capture a specific window | `Cmd+Shift+4` then press `Space`, click window |
| Screenshot toolbar (record, timer, etc.) | `Cmd+Shift+5` |

Screenshots save to `~/Desktop/Screenshots` (configured by the setup script).  
Add `Ctrl` to any of the above to copy to clipboard instead of saving a file.

---

## Installing Software

Three ways, in order of preference for a developer:

**1. Homebrew (CLI tools and most apps)**
```bash
brew install git              # CLI tools
brew install --cask slack     # GUI apps
brew search <name>            # find a package
brew list                     # see what's installed
brew update && brew upgrade   # update everything
```

**2. App Store**
Open the App Store app. Good for Apple-native apps (Xcode, Things, etc.).

**3. Direct download (.dmg)**
Download → open the `.dmg` → drag the `.app` into `/Applications`. That's it. No installer wizard.  
To uninstall: drag the `.app` from `/Applications` to Trash. That's genuinely all it takes for most apps.

---

## Window Management

Mac windows don't maximize the same way as Windows.

| Action | How |
|--------|-----|
| Maximize (fill screen) | Double-click the title bar, or hold `Option` and click the green button |
| Full screen (hides everything else) | Click the green `⊕` button or `Cmd+Ctrl+F` |
| Exit full screen | `Esc` or `Cmd+Ctrl+F` |
| Minimise to Dock | `Cmd+M` |
| Hide app (keep running, no Dock slot) | `Cmd+H` |
| See all open windows | `Ctrl+↓` (App Exposé) or `F3` (Mission Control) |
| Switch desktops / Spaces | `Ctrl+← / Ctrl+→` |

> There is no built-in snap-to-half-screen like Windows 11. Use **Rectangle** (free): `brew install --cask rectangle` — gives you Win+← / Win+→ style snapping via keyboard.

---

## Finder (= File Explorer)

| Windows | Mac |
|---------|-----|
| File Explorer | Finder |
| `Win+E` | `Cmd+N` in Finder, or click Finder in Dock |
| Address bar | `Cmd+L` to edit path, or path bar at bottom (enabled by setup script) |
| `Ctrl+C / Ctrl+V` | `Cmd+C / Cmd+V` |
| Cut and paste files | `Cmd+C` to copy, then `Cmd+Option+V` to move (no Cmd+X for files) |
| Show hidden files | `Cmd+Shift+.` (toggle) |
| Open folder in terminal | Right-click → New Terminal at Folder |
| `F2` rename | `Enter` (press Enter on a selected file to rename it) |
| `Delete` to trash | `Cmd+Delete` |
| Empty trash | `Cmd+Shift+Delete` |

---

## System Settings

| Windows | Mac |
|---------|-----|
| Control Panel / Settings | System Settings (Apple menu → System Settings) |
| Task Manager | Activity Monitor (search in Spotlight: `Cmd+Space` → "activity monitor") |
| Add/Remove Programs | Just delete the `.app` from `/Applications`. For brew apps: `brew uninstall <name>` |
| Device Manager | System Information (`Cmd+Space` → "system information") |
| Environment Variables | `~/.zshrc` (add `export VAR=value`) |
| Services | `launchctl` in terminal, or Activity Monitor → CPU tab |

---

## Terminal

Your terminal is **zsh** with Oh My Zsh. Behaves like PowerShell but with Unix commands.

| Windows / PowerShell | Mac / zsh |
|----------------------|-----------|
| `cls` | `clear` or `Ctrl+L` |
| `dir` | `ls` |
| `copy`, `move` | `cp`, `mv` |
| `del` | `rm` |
| `type file.txt` | `cat file.txt` |
| `where git` | `which git` |
| `$env:PATH` | `echo $PATH` |
| `notepad file.txt` | `open -e file.txt` or `code file.txt` |
| `start .` | `open .` (opens current folder in Finder) |
| `explorer .` | `open .` |

You have all the same git aliases (`gs`, `gb`, `gco`, `gfeat`, `gsco`, etc.) as on Windows.

---

## Common Mac Shortcuts (General)

| Shortcut | Action |
|----------|--------|
| `Cmd+Space` | Spotlight search — launch apps, find files, do maths |
| `Cmd+,` | Open Preferences for the current app (universal) |
| `Cmd+W` | Close the current window/tab |
| `Cmd+Q` | Quit the app entirely |
| `Cmd+Z` | Undo |
| `Cmd+Shift+Z` | Redo |
| `Cmd+F` | Find |
| `Cmd+A` | Select all |
| `Cmd+T` | New tab (in browser, Finder, terminal) |
| `Cmd+L` | Focus address/URL bar |

---

## Things That Behave Differently

**Closing a window ≠ quitting the app.**  
`Cmd+W` closes the window but the app keeps running (see the dot under its Dock icon). `Cmd+Q` actually quits.

**Right-click = two-finger tap on trackpad.**  
Or `Ctrl+click` anywhere.

**Copy-paste between terminal and GUI.**  
Works with `Cmd+C / Cmd+V` in terminal too — no need for `Ctrl+Shift+C`.

**`.dmg` files are disk images, not installers.**  
After you drag the app to `/Applications` and eject the `.dmg`, you can delete the downloaded `.dmg` file.

**Software update ≠ restart required (usually).**  
Most app updates apply instantly. macOS system updates sometimes need a restart, but it's less frequent than Windows.

**No drive letters.**  
Everything is under `/`. Your home folder is `/Users/yourusername`, aliased as `~`. External drives mount at `/Volumes/DriveName`.
