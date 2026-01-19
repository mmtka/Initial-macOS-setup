# Initial macOS Setup

Opinionated, reproducible macOS bootstrap for power users with advanced configuration management.

## Features

✓ **One-command setup** – Complete macOS configuration in minutes  
✓ **Configurable** – Customize via `config.sh` without editing scripts  
✓ **Backup & Restore** – Automatic backup before changes  
✓ **Profile System** – Minimal, work, or full installation profiles  
✓ **Idempotent** – Safe to run multiple times  
✓ **CI/CD Validated** – Automated testing via GitHub Actions  
✓ **Hook System** – Pre/post-bootstrap customization  

## What Gets Installed

- **Homebrew** + all packages from Brewfile
- **macOS system defaults** (Finder, Dock, keyboard, etc.)
- **Dock layout** (via dockutil)
- **zsh configuration** (minimal, sane defaults)
- **Rosetta 2** (Apple Silicon only)

## Quick Start

### Standard Installation

```bash
git clone https://github.com/mmtka/Initial-macOS-setup.git
cd Initial-macOS-setup
./bootstrap.sh
```

### Profile-Based Installation

```bash
# Minimal setup (essentials only)
cp profiles/minimal.Brewfile Brewfile
./bootstrap.sh

# Work setup (development tools)
cp profiles/work.Brewfile Brewfile
./bootstrap.sh

# Full setup (everything)
cp Brewfile.bak Brewfile  # restore original
./bootstrap.sh
```

### One-liner (from scratch)

```bash
curl -fsSL https://raw.githubusercontent.com/mmtka/Initial-macOS-setup/main/install.sh | bash
```

## Configuration

Edit `config.sh` to customize your setup:

```bash
# Language and locale
export LOCALE="de_DE"
export CURRENCY="EUR"
export TIMEZONE="Europe/Berlin"
export LANGUAGES=("sk" "en" "cs" "de")

# Features
export ENABLE_POWER_DEFAULTS=true
export ENABLE_DOCK_LAYOUT=true
export AUTO_CLEANUP_BREW=true
export CREATE_BACKUP=true

# Paths
export SCREENSHOT_DIR="${HOME}/Screenshots"
export BACKUP_DIR="${HOME}/.macos-setup-backups"
```

## What Will Prompt You

- **macOS user password (sudo)** – yes, required for system changes
- **Mac App Store login** – yes, guided by script (for MAS apps)
- **iCloud credentials** – never

## Backup & Restore

### Automatic Backup

Bootstrap automatically backs up your current settings to `~/.macos-setup-backups/` before making changes.

### Manual Backup

```bash
source lib/backup.sh
create_backup
```

### Restore from Backup

```bash
source lib/backup.sh
list_backups  # Show available backups
restore_backup ~/.macos-setup-backups/20260119-173000
```

## Customization Hooks

Create custom logic without modifying core scripts:

### Pre-Bootstrap Hook

Edit `hooks/pre-bootstrap.sh` to run checks before setup:

```bash
# Example: Check disk space
AVAILABLE=$(df -h / | awk 'NR==2 {print $4}')
if [[ "$AVAILABLE" -lt 10 ]]; then
  echo "ERROR: Need at least 10GB free"
  exit 1
fi
```

### Post-Bootstrap Hook

Edit `hooks/post-bootstrap.sh` for final customization:

```bash
# Example: Clone dotfiles
git clone https://github.com/yourusername/dotfiles ~/.dotfiles
```

## Profiles

Three installation profiles are available:

| Profile | Description | Size | Use Case |
|---------|-------------|------|----------|
| **minimal** | Essentials only | ~500MB | Testing, VM, minimal setup |
| **work** | Development tools | ~2GB | Work machines, development |
| **full** | Everything | ~10GB | Primary personal machine |

Switch profiles by copying the desired Brewfile:

```bash
cp profiles/minimal.Brewfile Brewfile
```

## Documentation

- **[INSTALL.md](INSTALL.md)** – Installation instructions & one-liner
- **[USAGE.md](USAGE.md)** – Running individual components
- **[STRUCTURE.md](STRUCTURE.md)** – Repository layout
- **[FAQ.md](FAQ.md)** – Design decisions and troubleshooting

## Repository Structure

```
.
├── bootstrap.sh          # Main setup script
├── config.sh             # User configuration
├── Brewfile              # Full package list
├── defaults/
│   ├── defaults.safe.sh  # Safe system settings
│   ├── defaults.power.sh # Advanced settings (sudo)
│   └── apply.sh          # Apply & restart services
├── dock/
│   └── layout.sh         # Dock configuration
├── lib/
│   └── backup.sh         # Backup/restore functions
├── hooks/
│   ├── pre-bootstrap.sh  # Pre-setup hook
│   └── post-bootstrap.sh # Post-setup hook
├── profiles/
│   ├── minimal.Brewfile  # Minimal profile
│   └── work.Brewfile     # Work profile
└── .github/
    └── workflows/
        └── validate.yml  # CI/CD validation
```

## CI/CD

Every push and pull request automatically runs:

- **Brewfile syntax validation**
- **Shellcheck** on all scripts
- **Configuration validation**
- **Common issue detection**

View status: [GitHub Actions](https://github.com/mmtka/Initial-macOS-setup/actions)

## Important Notes

- **Not an MDM replacement** – For personal use, not enterprise deployment
- **Scripts are source of truth** – Not declarative infrastructure
- **Some changes require logout/reboot** – Especially security settings on newer macOS
- **MAS apps require App Store login** – Sign in manually first

## Troubleshooting

### MAS apps not installing

1. Sign into App Store.app manually
2. Re-run: `brew bundle --file Brewfile`

### Dock layout not applied

```bash
# Manually apply dock layout
bash dock/layout.sh
```

### Restore previous settings

```bash
source lib/backup.sh
list_backups
restore_backup <path-to-backup>
```

### Check logs

Bootstrap creates detailed logs:

```bash
ls -lt ~/bootstrap-*.log | head -1
tail -f ~/bootstrap-*.log  # Follow latest log
```

## License

MIT – Use at your own risk

## Credits

Inspired by:
- [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles)
- [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)
- [dockutil](https://github.com/kcrawford/dockutil)
