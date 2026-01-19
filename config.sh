#!/usr/bin/env bash
# ============================================
# Configuration file for macOS setup
# Edit these values to customize your setup
# ============================================

# Language and locale settings
export LOCALE="de_DE"
export CURRENCY="EUR"
export TIMEZONE="Europe/Berlin"
export LANGUAGES=("sk" "en" "cs" "de")

# Measurement units
export USE_METRIC=true
export MEASUREMENT_UNITS="Centimeters"

# Bootstrap behavior
export ENABLE_POWER_DEFAULTS=true
export ENABLE_DOCK_LAYOUT=true
export AUTO_CLEANUP_BREW=true

# Backup settings
export CREATE_BACKUP=true
export BACKUP_DIR="${HOME}/.macos-setup-backups"

# Screenshots
export SCREENSHOT_DIR="${HOME}/Screenshots"
export SCREENSHOT_FORMAT="png"  # png, jpg, pdf, tiff

# Finder
export FINDER_SHOW_HIDDEN=true
export FINDER_SHOW_EXTENSIONS=true
export FINDER_VIEW_STYLE="clmv"  # icnv=Icon, clmv=Column, Nlsv=List, glyv=Gallery

# Dock
export DOCK_TILE_SIZE=32
export DOCK_SHOW_RECENTS=false

# Security (ADVANCED - know what you're doing)
export DISABLE_GATEKEEPER_QUARANTINE=false  # Set to true only if you understand the risks
