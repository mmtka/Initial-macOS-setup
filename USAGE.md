# Usage Guide

## Full Setup

Run the complete bootstrap process:

```bash
./bootstrap.sh
```

This executes all steps: Homebrew, packages, defaults, dock, backups.

## Profile-Based Setup

Choose installation profile before running:

```bash
# Minimal (essentials only)
cp profiles/minimal.Brewfile Brewfile
./bootstrap.sh

# Work (development tools)
cp profiles/work.Brewfile Brewfile
./bootstrap.sh

# Full (restore original)
cp Brewfile.original Brewfile  # backup your original first
./bootstrap.sh
```

## Configuration

Edit `config.sh` to customize behavior:

```bash
# Example: Disable dock layout
export ENABLE_DOCK_LAYOUT=false

# Example: Disable automatic cleanup
export AUTO_CLEANUP_BREW=false

# Example: Custom screenshot location
export SCREENSHOT_DIR="${HOME}/Desktop/Screenshots"
```

Then run:

```bash
./bootstrap.sh
```

## Individual Components

### Software Installation Only

```bash
# Install from Brewfile
brew bundle --file Brewfile

# Or use specific profile
brew bundle --file profiles/minimal.Brewfile
```

### macOS Defaults Only

```bash
# Safe defaults (no sudo)
bash defaults/defaults.safe.sh

# Power defaults (requires sudo)
bash defaults/defaults.power.sh

# Apply changes
bash defaults/apply.sh
```

### Dock Layout Only

```bash
bash dock/layout.sh
```

### Backup & Restore

```bash
# Create manual backup
source lib/backup.sh
create_backup

# List available backups
list_backups

# Restore from specific backup
restore_backup ~/.macos-setup-backups/20260119-173000
```

## Updating Installed Packages

```bash
# Update Homebrew and packages
brew update
brew upgrade

# Reinstall from Brewfile (keeps versions in sync)
brew bundle --file Brewfile
```

## After App Store Login

If you skipped MAS apps during initial setup:

```bash
# 1. Sign into App Store.app manually
# 2. Run:
brew bundle --file Brewfile
```

## Cleanup Orphaned Packages

Remove packages not in Brewfile:

```bash
# Interactive (asks before removing)
brew bundle cleanup --file Brewfile

# Automatic (force remove)
brew bundle cleanup --file Brewfile --force
```

## Customization Hooks

### Pre-Bootstrap Hook

Edit `hooks/pre-bootstrap.sh` to add checks before setup:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Example: Ensure sufficient disk space
AVAILABLE=$(df -h / | awk 'NR==2 {print $4}' | sed 's/Gi//')
if (( $(echo "$AVAILABLE < 20" | bc -l) )); then
  echo "ERROR: Need at least 20GB free disk space"
  exit 1
fi
```

### Post-Bootstrap Hook

Edit `hooks/post-bootstrap.sh` for final customization:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Example: Clone your dotfiles
if [[ ! -d "${HOME}/.dotfiles" ]]; then
  git clone https://github.com/yourusername/dotfiles.git "${HOME}/.dotfiles"
  cd "${HOME}/.dotfiles"
  ./install.sh
fi
```

## Re-running Bootstrap

Bootstrap is idempotent - safe to run multiple times:

```bash
./bootstrap.sh
```

It will:
- Skip already installed tools
- Update existing configurations
- Create new backup before changes
- Only apply what's different

## Logs

Every bootstrap run creates a timestamped log:

```bash
# View latest log
ls -t ~/bootstrap-*.log | head -1 | xargs cat

# Follow live log (in another terminal)
tail -f ~/bootstrap-$(date +%Y%m%d)-*.log

# Search logs
grep -i error ~/bootstrap-*.log
```

## Dry Run

To see what would be installed without actually doing it:

```bash
# Check Brewfile
brew bundle check --file Brewfile

# See what would be cleaned up
brew bundle cleanup --file Brewfile
```

## Troubleshooting

### Reset to defaults

```bash
# Restore from backup
source lib/backup.sh
list_backups
restore_backup <path-to-backup>

# Restart affected services
bash defaults/apply.sh
```

### Force reinstall everything

```bash
# Remove Brewfile.lock.json
rm Brewfile.lock.json

# Force reinstall
brew bundle --file Brewfile --force
```

### Check what changed

```bash
# Compare current vs backup
diff <(defaults export com.apple.finder -) \
     ~/.macos-setup-backups/latest/com.apple.finder.plist
```

## Advanced Usage

### Custom Brewfile Location

```bash
BREWFILE="/path/to/custom.Brewfile" ./bootstrap.sh
```

### Disable Specific Features

```bash
# In config.sh
export ENABLE_POWER_DEFAULTS=false
export ENABLE_DOCK_LAYOUT=false
export CREATE_BACKUP=false
```

### Multiple Profiles

Maintain separate Brewfiles for different machines:

```bash
profiles/
├── macbook-work.Brewfile
├── macbook-personal.Brewfile
└── mac-mini-server.Brewfile

# Use specific profile
cp profiles/macbook-work.Brewfile Brewfile
./bootstrap.sh
```
