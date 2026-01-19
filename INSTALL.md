# Installation Guide

## Prerequisites

- macOS 12.0 (Monterey) or later
- Admin account with sudo privileges
- Internet connection
- At least 10GB free disk space (20GB+ recommended for full profile)

## Quick Install

### Option 1: One-Liner (Recommended for fresh install)

```bash
curl -fsSL https://raw.githubusercontent.com/mmtka/Initial-macOS-setup/main/install.sh | bash
```

This will:
1. Clone the repository to `/tmp/Initial-macOS-setup`
2. Run `bootstrap.sh` automatically
3. Clean up temporary files

### Option 2: Manual Clone

```bash
git clone https://github.com/mmtka/Initial-macOS-setup.git
cd Initial-macOS-setup
./bootstrap.sh
```

## Installation Profiles

Choose installation level before running bootstrap:

### Minimal Profile (~500MB)

Essentials only - browser, password manager, basic CLI tools.

```bash
git clone https://github.com/mmtka/Initial-macOS-setup.git
cd Initial-macOS-setup
cp profiles/minimal.Brewfile Brewfile
./bootstrap.sh
```

**Includes:**
- Brave Browser
- 1Password
- Essential CLI tools (bash, curl, wget, tree, htop)
- dockutil, mas

**Good for:**
- Testing this setup
- Virtual machines
- Secondary Macs
- Minimalist setups

### Work Profile (~2GB)

Development and productivity tools.

```bash
git clone https://github.com/mmtka/Initial-macOS-setup.git
cd Initial-macOS-setup
cp profiles/work.Brewfile Brewfile
./bootstrap.sh
```

**Includes:**
- Browsers (Brave, Firefox)
- Development tools (VS Code, PyCharm, Docker via OrbStack)
- Office suite (OnlyOffice, Microsoft Office)
- Communication (Telegram, WhatsApp, Spark Mail)
- Security (1Password, ProtonVPN)

**Good for:**
- Work machines
- Development environments
- Professional use

### Full Profile (~10GB)

Complete setup with media, Adobe Creative Cloud, and all tools.

```bash
git clone https://github.com/mmtka/Initial-macOS-setup.git
cd Initial-macOS-setup
./bootstrap.sh  # Uses default Brewfile (full)
```

**Includes:**
- Everything from Work profile
- Adobe Creative Cloud apps
- Media tools (Plex, Spotify, IINA, Audacity)
- Tax software (WISO Steuer)
- Geocaching tools
- TeX/LaTeX environment

**Good for:**
- Primary personal machine
- Content creation
- Photography/design work

## Configuration (Optional)

Before running bootstrap, customize `config.sh`:

```bash
cd Initial-macOS-setup
cp config.sh config.sh.backup  # Backup original
nano config.sh  # Or use your preferred editor
```

**Common customizations:**

```bash
# Change locale and timezone
export LOCALE="en_US"          # Was: de_DE
export TIMEZONE="America/New_York"  # Was: Europe/Berlin

# Disable features you don't want
export ENABLE_POWER_DEFAULTS=false  # Skip sudo defaults
export ENABLE_DOCK_LAYOUT=false     # Keep current dock

# Custom paths
export SCREENSHOT_DIR="${HOME}/Desktop/Screenshots"
export BACKUP_DIR="${HOME}/Backups/macOS-setup"
```

Then run bootstrap:

```bash
./bootstrap.sh
```

## What Happens During Installation

### Automatic Steps

1. **System checks**
   - Detects Apple Silicon vs Intel
   - Installs Rosetta 2 (if needed)
   - Installs Xcode Command Line Tools

2. **Homebrew setup**
   - Installs Homebrew (if not present)
   - Configures shell environment

3. **Backup creation**
   - Saves current system defaults
   - Backs up Dock layout
   - Creates restore manifest

4. **Package installation**
   - Installs CLI tools
   - Installs GUI applications
   - Installs App Store apps (if logged in)
   - Installs VS Code extensions

5. **System configuration**
   - Applies safe defaults (Finder, keyboard, trackpad)
   - Applies power defaults (sudo required)
   - Configures Dock layout

6. **Cleanup**
   - Removes orphaned packages
   - Restarts affected services

### User Prompts

You'll be asked for:

- **macOS password (sudo)** - Required for:
  - Xcode Command Line Tools
  - Homebrew installation
  - Power defaults (timezone, firewall, etc.)

- **App Store login** - Only if you want MAS apps:
  - Not automated (Apple security policy)
  - Sign in via App Store.app GUI
  - Script will detect and install MAS apps

- **Xcode installer** - If not already installed:
  - GUI popup appears
  - Click Install
  - Re-run bootstrap after completion

## Post-Installation

### 1. Restart Required?

Some settings require logout/reboot:
- Security settings (Gatekeeper, Firewall)
- Input preferences (three-finger drag on older macOS)

Recommended: **Logout and login** after first run.

### 2. Install MAS Apps (if skipped)

If you weren't signed into App Store:

```bash
# 1. Sign in via App Store.app
# 2. Run:
brew bundle --file Brewfile
```

### 3. Check Logs

Review installation log:

```bash
ls -t ~/bootstrap-*.log | head -1 | xargs cat
```

### 4. Verify Installation

```bash
# Check Homebrew
brew doctor

# List installed packages
brew list
brew list --cask
mas list

# Check defaults
defaults read com.apple.finder AppleShowAllFiles  # Should be 1
defaults read com.apple.dock tilesize            # Should be 32
```

## Updating After Installation

### Update Homebrew packages

```bash
brew update
brew upgrade
```

### Update this setup repository

```bash
cd Initial-macOS-setup
git pull origin main
./bootstrap.sh  # Re-run with latest changes
```

### Switch profiles

```bash
# Save current Brewfile
mv Brewfile Brewfile.full

# Switch to minimal
cp profiles/minimal.Brewfile Brewfile
brew bundle cleanup --force  # Remove packages not in minimal
```

## Troubleshooting

### Installation fails at Xcode Command Line Tools

**Symptom:** Script exits asking you to complete Xcode installer.

**Solution:**
1. Click Install in the GUI popup
2. Wait for completion (may take 5-10 minutes)
3. Re-run: `./bootstrap.sh`

### Homebrew not in PATH

**Symptom:** `brew: command not found` after installation.

**Solution:**
```bash
# For Apple Silicon:
eval "$(/opt/homebrew/bin/brew shellenv)"

# For Intel:
eval "$(/usr/local/bin/brew shellenv)"

# Or open new terminal window
```

### MAS apps not installing

**Symptom:** App Store apps skipped during installation.

**Solution:**
1. Open App Store.app
2. Sign in with your Apple ID
3. Verify: `mas account`
4. Re-run: `brew bundle --file Brewfile`

### Dock layout incorrect

**Symptom:** Dock doesn't match expected layout.

**Solution:**
```bash
# Manually apply
bash dock/layout.sh

# If apps missing, install first
brew bundle --file Brewfile
bash dock/layout.sh
```

### Restore from backup

**Symptom:** Don't like the new settings.

**Solution:**
```bash
source lib/backup.sh
list_backups
restore_backup ~/.macos-setup-backups/<timestamp>
killall Finder Dock SystemUIServer
```

## Uninstallation

To completely remove:

```bash
# 1. Restore backup (optional)
source lib/backup.sh
restore_backup <earliest-backup>

# 2. Remove Homebrew and all packages
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# 3. Remove repository
rm -rf ~/Initial-macOS-setup

# 4. Remove backups (optional)
rm -rf ~/.macos-setup-backups

# 5. Remove logs (optional)
rm ~/bootstrap-*.log
```

## Support

For issues:
1. Check [FAQ.md](FAQ.md)
2. Review logs: `~/bootstrap-*.log`
3. Check [GitHub Issues](https://github.com/mmtka/Initial-macOS-setup/issues)
4. Run validation: `brew bundle check --file Brewfile`
