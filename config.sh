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
export SCREENSHOT_SHOW_CURSOR=false
export SCREENSHOT_SHOW_THUMBNAIL=true

# Finder
export FINDER_SHOW_HIDDEN=true
export FINDER_SHOW_EXTENSIONS=true
export FINDER_VIEW_STYLE="clmv"  # icnv=Icon, clmv=Column, Nlsv=List, glyv=Gallery
export FINDER_SHOW_POSIX_PATH=true
export FINDER_WARN_EMPTY_TRASH=false
export FINDER_QUIT_MENU=true
export FINDER_SHOW_RECENT_TAGS=false
export FINDER_SPAWN_TAB=false

# Dock
export DOCK_TILE_SIZE=32
export DOCK_SHOW_RECENTS=false
export DOCK_AUTOHIDE=false
export DOCK_AUTOHIDE_DELAY=0
export DOCK_AUTOHIDE_TIME=0.5
export DOCK_MINIMIZE_EFFECT="scale"  # genie/scale/suck
export DOCK_MAGNIFICATION=false
export DOCK_LARGE_SIZE=64
export DOCK_POSITION="bottom"  # left/bottom/right

# UI / Animations
export SCROLLBARS_VISIBILITY="Always"  # Always/Automatic/WhenScrolling
export MENU_BAR_AUTOHIDE=false
export MENU_BAR_CLOCK_FORMAT="EEE d. MMM  HH:mm"

# Trackpad
export TRACKPAD_CLICK_THRESHOLD=1  # 0=light, 1=medium, 2=firm

# Mission Control / Spaces
export MISSION_CONTROL_GROUP_APPS=true
export SPACES_SPAN_DISPLAYS=false

# Safari
export SAFARI_HOMEPAGE="about:blank"
export SAFARI_AUTOFILL_PASSWORDS=false
export SAFARI_AUTOFILL_CREDIT_CARDS=false

# Mail
export MAIL_DISABLE_INLINE_ATTACHMENTS=true
export MAIL_DISABLE_REMOTE_IMAGES=true

# Security (ADVANCED - know what you're doing)
export DISABLE_GATEKEEPER_QUARANTINE=false  # Set to true only if you understand the risks
