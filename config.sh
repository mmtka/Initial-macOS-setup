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
# NOTE: every value below uses the `${VAR:-default}` form so it can be overridden
# from the environment (e.g. by tui.sh) without editing this file.
export ENABLE_HOMEBREW="${ENABLE_HOMEBREW:-true}"            # run `brew bundle` from the Brewfile
export ENABLE_DEFAULTS_SAFE="${ENABLE_DEFAULTS_SAFE:-true}"  # apply safe macOS defaults (no sudo)
export ENABLE_POWER_DEFAULTS="${ENABLE_POWER_DEFAULTS:-true}"
export ENABLE_DOCK_LAYOUT="${ENABLE_DOCK_LAYOUT:-true}"
export AUTO_CLEANUP_BREW="${AUTO_CLEANUP_BREW:-true}"

# Configuration profiles (.mobileconfig)
# Scripts are the SOURCE OF TRUTH. A managed profile silently overrides
# `defaults write` (mcxdomain = always), so for any domain our scripts manage
# (Finder/Dock/Gatekeeper/Safari/…) we REMOVE the conflicting installed profile
# before applying defaults — otherwise Finder/Gatekeeper settings won't stick.
export REMOVE_CONFLICTING_PROFILES="${REMOVE_CONFLICTING_PROFILES:-true}"  # uses sudo
export ENABLE_PROFILES="${ENABLE_PROFILES:-true}"  # install NON-conflicting profiles from PROFILES_DIR
# PROFILES_DIR defaults to <repo>/profiles/mobileconfig (resolved in bootstrap.sh);
# point it elsewhere (e.g. a NAS folder) to install your own .mobileconfig files:
# export PROFILES_DIR="/path/to/your/profiles"

# Enable Touch ID for sudo so the single admin prompt at the start uses your
# fingerprint instead of a typed password (macOS 14+). Survives macOS updates.
export ENABLE_TOUCHID_SUDO="${ENABLE_TOUCHID_SUDO:-true}"

# Backup settings
export CREATE_BACKUP="${CREATE_BACKUP:-true}"
export BACKUP_DIR="${BACKUP_DIR:-${HOME}/.macos-setup-backups}"

# Screenshots
export SCREENSHOT_DIR="${SCREENSHOT_DIR:-${HOME}/Screenshots}"
export SCREENSHOT_FORMAT="${SCREENSHOT_FORMAT:-png}"  # png, jpg, pdf, tiff

# Finder
export FINDER_SHOW_HIDDEN="${FINDER_SHOW_HIDDEN:-true}"
export FINDER_SHOW_EXTENSIONS="${FINDER_SHOW_EXTENSIONS:-true}"
export FINDER_VIEW_STYLE="${FINDER_VIEW_STYLE:-clmv}"  # icnv=Icon, clmv=Column, Nlsv=List, glyv=Gallery

# Dock
export DOCK_TILE_SIZE="${DOCK_TILE_SIZE:-32}"
export DOCK_SHOW_RECENTS="${DOCK_SHOW_RECENTS:-false}"

# Security (ADVANCED - know what you're doing)
export DISABLE_GATEKEEPER_QUARANTINE="${DISABLE_GATEKEEPER_QUARANTINE:-false}"  # adds quarantine bypass; risk

# Gatekeeper assessment (allow apps from anywhere) is NOT a script setting:
# macOS 26 removed `spctl --master-disable`, so it is handled by the profile
# profiles/mobileconfig/gatekeeper.mobileconfig — which the installer keeps
# installed (it is the one "profile wins" exception). Remove that file if you
# want Gatekeeper to stay fully enabled.
