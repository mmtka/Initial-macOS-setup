# Initial macOS Setup

Opinionated, reproducible macOS bootstrap for power users.

One command installs:
- Homebrew + software (Brewfile)
- macOS system defaults
- Dock layout
- zsh configuration
- Apple Silicon specifics (Rosetta)

Designed to rebuild a clean macOS system quickly and predictably.

## Quick start

```bash
git clone https://github.com/mmtka/Initial-macOS-setup.git
cd Initial-macOS-setup
./bootstrap.sh
```

## What will prompt you

- macOS user password (sudo) – yes
- Mac App Store login – yes (guided by script)
- iCloud credentials – never

## Documentation

- INSTALL.md – installation & one‑liner
- USAGE.md – running individual parts
- STRUCTURE.md – repository layout
- FAQ.md – design decisions

This is not an MDM replacement.
Scripts are the source of truth.
