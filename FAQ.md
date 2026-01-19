# Frequently Asked Questions

## General

### Why not everything via Homebrew?

Some applications have their own updaters (Adobe Creative Cloud, Microsoft Office) or require manual installation steps (Parallels Desktop with license activation). Installing these via Homebrew Cask would bypass necessary setup steps or create update conflicts.

### Why split safe and power defaults?

Security-relevant settings must be explicit and require conscious decision. `defaults.safe.sh` contains UI/UX preferences safe for any Mac. `defaults.power.sh` includes system-level changes that:
- Require sudo privileges
- May disable security features (e.g., Gatekeeper quarantine)
- Affect power management or hardware behavior

This separation ensures you understand what you're changing.

### Why is App Store login manual?

Apple does not provide CLI authentication for the App Store. The `mas` tool requires you to be already signed in via the GUI App Store.app. This is an Apple security policy, not a limitation of this setup.

### Is this suitable for enterprise deployment?

No. This is designed for personal use. For enterprise:
- Use MDM (Jamf, Kandji, Mosyle)
- Consider declarative device management
- Use configuration profiles instead of `defaults` commands

This repository is the "source of truth" approach for power users, not declarative infrastructure.

## Features

### What's backed up automatically?

Before making changes, the bootstrap creates backups of:
- All `defaults` domains (NSGlobalDomain, Finder, Dock, Safari, etc.)
- Current Dock layout
- Current Brewfile state (what's installed)
- Manifest with system info and restore instructions

Backups are stored in `~/.macos-setup-backups/YYYYMMDD-HHMMSS/`

### Can I customize without modifying core scripts?

Yes, via:
1. **config.sh** - Change locale, timezone, feature flags, paths
2. **hooks/pre-bootstrap.sh** - Add pre-flight checks (disk space, network, etc.)
3. **hooks/post-bootstrap.sh** - Add post-install tasks (dotfiles, SSH keys, etc.)
4. **profiles/** - Use or create custom Brewfile profiles

Core scripts remain untouched, updates won't overwrite your customizations.

### What are profiles?

Profiles are pre-configured Brewfile variants:
- **minimal.Brewfile** (~500MB) - Browser, 1Password, essential CLI tools
- **work.Brewfile** (~2GB) - Development tools, IDE, Docker, Office
- **Brewfile** (full, ~10GB) - Everything including media, Adobe, games

Switch with: `cp profiles/minimal.Brewfile Brewfile`

### How does dynamic Adobe detection work?

Instead of hardcoded paths like `/Applications/Adobe Photoshop 2025/`, the dock layout script searches:
```bash
find /Applications -maxdepth 2 -name "Adobe Photoshop*.app" | head -1
```

This works across Adobe version updates (2025 → 2026 → 2027) without breaking.

## Security & Privacy

### What security trade-offs exist?

**In defaults.power.sh:**
- `LSQuarantine -bool false` - Disables Gatekeeper quarantine warnings (RISKY)
  - **Why**: Eliminates "downloaded from internet" prompts
  - **Risk**: Malware from downloads won't be flagged
  - **Mitigation**: Controlled via `DISABLE_GATEKEEPER_QUARANTINE` in config.sh (default: false)

- `hibernatemode 0` - Disables safe sleep
  - **Why**: Faster wake, frees disk space (removes sleepimage)
  - **Risk**: RAM contents lost on power failure
  - **Mitigation**: Only affects battery-powered Macs on power loss

**Firewall is enabled by default** - stealth mode on.

### Does this phone home or collect data?

No. All scripts run locally. The only network connections are:
- Homebrew (fetches packages from brew.sh)
- mas (App Store API for installed apps)
- GitHub (if you clone/update this repo)

No telemetry, no tracking, no data collection.

### Can I audit what changes?

Yes:
1. All scripts are bash - human-readable
2. Review `defaults/*.sh` for exact `defaults write` commands
3. Check diff before/after:
   ```bash
   diff ~/.macos-setup-backups/before/NSGlobalDomain.plist \
        ~/.macos-setup-backups/after/NSGlobalDomain.plist
   ```
4. CI/CD validates syntax on every commit

## Troubleshooting

### MAS apps not installing?

1. Sign into App Store.app manually (GUI)
2. Verify: `mas account` (should show your Apple ID)
3. Re-run: `brew bundle --file Brewfile`

If still failing, check if the app is in your purchase history (MAS can't install apps you haven't "purchased" - even if free).

### Dock layout not applying?

Common causes:
- **dockutil not installed**: `brew install dockutil`
- **App doesn't exist**: Check app name in `dock/layout.sh` matches `/Applications/`
- **Adobe version changed**: Dynamic detection should handle this, but verify app exists

Manual fix:
```bash
bash dock/layout.sh
killall Dock
```

### How do I restore previous settings?

```bash
source lib/backup.sh
list_backups  # Shows all available backups
restore_backup ~/.macos-setup-backups/20260119-173000
killall Finder Dock SystemUIServer
```

Or restore single domain:
```bash
defaults import com.apple.finder ~/.macos-setup-backups/20260119-173000/com.apple.finder.plist
killall Finder
```

### Settings not applying after reboot?

Some newer macOS versions cache `defaults` in System Settings. Try:
1. Quit System Settings: `killall "System Settings"`
2. Re-apply: `bash defaults/apply.sh`
3. If still failing, logout/login (not just restart)

### How to completely reset?

```bash
# 1. Restore from backup
source lib/backup.sh
restore_backup <earliest-backup>

# 2. Remove Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# 3. Reinstall from scratch
./bootstrap.sh
```

## Updates & Maintenance

### How do I update this repo?

```bash
cd Initial-macOS-setup
git pull origin main
./bootstrap.sh  # Re-run with latest changes
```

Your `config.sh` won't be overwritten (it's gitignored after first edit).

### How often should I re-run bootstrap?

Never required. Run when:
- Fresh macOS install
- Major macOS version upgrade (to reapply settings)
- You modified Brewfile or config.sh
- Testing new configurations

For package updates only: `brew update && brew upgrade`

### Can I contribute improvements?

Yes! This is your personal fork, but general improvements (bug fixes, better error handling, new features) can be:
1. Tested locally
2. Committed to your repo
3. Used as reference for others

CI/CD validates all changes automatically.

## Advanced

### Can I use this on multiple Macs?

Yes. Two approaches:

**Approach 1: Shared config**
- Same config.sh and Brewfile for all Macs
- Clone repo on each Mac
- Run `./bootstrap.sh`

**Approach 2: Per-machine profiles**
```bash
profiles/
├── macbook-pro.Brewfile
├── macbook-air.Brewfile
└── mac-mini.Brewfile

# On each Mac:
cp profiles/$(hostname).Brewfile Brewfile
./bootstrap.sh
```

### How do I add custom defaults?

Edit `defaults/defaults.safe.sh` or create your own:

```bash
# defaults/custom.sh
defaults write com.example.app Setting -bool true

# Call from bootstrap.sh or run manually:
bash defaults/custom.sh
```

### Can I disable CI/CD validation?

Yes, delete `.github/workflows/validate.yml`. But validation helps catch:
- Invalid Brewfile syntax
- Shell script errors (shellcheck)
- Broken references (missing files)
- Common mistakes (tabs, invalid Python versions)

Recommend keeping it enabled.
