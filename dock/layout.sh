#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Dock layout (Dockutil) – generated from Dockfinity backup (Default profile)
# Notes:
# - Dockfinity exported some system apps with Cryptex/Preboot paths (unstable).
#   We therefore use stable canonical system paths as fallbacks.
# - We add items in order (no explicit --position needed).
# -----------------------------------------------------------------------------

if ! command -v dockutil >/dev/null 2>&1; then
  echo "ERROR: dockutil not found. Install it first (brew install dockutil)."
  exit 1
fi

# Clear Dock (keep running Dock, apply changes at the end)
dockutil --remove all --no-restart >/dev/null

add_app() {
  local primary="$1"
  shift || true

  local p="$primary"
  if [[ -e "$p" ]]; then
    dockutil --add "$p" --no-restart >/dev/null
    return 0
  fi

  # Fallback candidates
  for p in "$@"; do
    if [[ -e "$p" ]]; then
      dockutil --add "$p" --no-restart >/dev/null
      return 0
    fi
  done

  echo "WARN: App not found, skipping: $primary"
  return 0
}

# -----------------------------------------------------------------------------
# Apps (in Dockfinity order positions 0..31)
# -----------------------------------------------------------------------------

add_app "/Applications/Brave Browser.app"
add_app "/System/Applications/Safari.app" \
        "/Applications/Safari.app"
add_app "/Applications/1Password.app"
add_app "/Applications/Obsidian.app"

add_app "/System/Applications/Mail.app"
add_app "/Applications/Spark Desktop.app"

add_app "/System/Applications/Calendar.app"
add_app "/System/Applications/Contacts.app"
add_app "/System/Applications/Phone.app"
add_app "/System/Applications/Photos.app"

add_app "/Applications/Plex.app"
add_app "/Applications/Plexamp.app"

add_app "/Applications/Adobe Acrobat DC/Adobe Acrobat.app" \
        "/Applications/Adobe Acrobat.app"

add_app "/Applications/Pages.app"
add_app "/Applications/Numbers.app"
add_app "/Applications/Microsoft Word.app"

add_app "/Applications/ONLYOFFICE.app"

add_app "/Applications/Adobe Bridge 2026/Adobe Bridge 2026.app"
add_app "/Applications/Adobe Illustrator 2026/Adobe Illustrator.app"
add_app "/Applications/Adobe Photoshop 2026/Adobe Photoshop 2026.app"
add_app "/Applications/Adobe InDesign 2026/Adobe InDesign 2026.app"
add_app "/Applications/Adobe Audition 2025/Adobe Audition 2025.app"

add_app "/Applications/Telegram.app"
add_app "/Applications/Parallels Desktop.app"

add_app "/System/Applications/System Settings.app"
add_app "/System/Applications/Utilities/System Information.app"
add_app "/System/Applications/Utilities/Screenshot.app"
add_app "/System/Applications/Utilities/Activity Monitor.app"
add_app "/System/Applications/Utilities/Terminal.app"

add_app "/Applications/Termius.app"
add_app "/Applications/Warp.app"
add_app "/Applications/Sentinel.app"

# Apply
killall Dock >/dev/null 2>&1 || true
echo "Dock layout applied."
