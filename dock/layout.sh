#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Dock layout (Dockutil) – generated from Dockfinity backup (Default profile)
# Notes:
# - Dockfinity exported some system apps with Cryptex/Preboot paths (unstable).
#   We therefore use stable canonical system paths as fallbacks.
# - Adobe apps use dynamic detection (version-independent)
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

find_adobe_app() {
  local app_name="$1"
  # Search for Adobe apps dynamically (version-independent)
  local found=$(find /Applications -maxdepth 2 -name "${app_name}*.app" -type d 2>/dev/null | head -1)
  if [[ -n "$found" ]]; then
    echo "$found"
  fi
}

add_adobe_app() {
  local search_name="$1"
  local fallback_path="${2:-}"
  
  local app_path=$(find_adobe_app "$search_name")
  
  if [[ -n "$app_path" ]]; then
    dockutil --add "$app_path" --no-restart >/dev/null
  elif [[ -n "$fallback_path" ]] && [[ -e "$fallback_path" ]]; then
    dockutil --add "$fallback_path" --no-restart >/dev/null
  else
    echo "WARN: Adobe app not found: $search_name"
  fi
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

# Adobe apps with dynamic detection
add_adobe_app "Adobe Acrobat"

add_app "/Applications/Pages.app"
add_app "/Applications/Numbers.app"
add_app "/Applications/Microsoft Word.app"

add_app "/Applications/ONLYOFFICE.app"

# Adobe Creative Cloud apps (version-independent)
add_adobe_app "Adobe Bridge"
add_adobe_app "Adobe Illustrator"
add_adobe_app "Adobe Photoshop"
add_adobe_app "Adobe InDesign"
add_adobe_app "Adobe Audition"

add_app "/Applications/Telegram.app"

# Parallels Desktop (not in Brewfile - manual install)
if [[ -e "/Applications/Parallels Desktop.app" ]]; then
  add_app "/Applications/Parallels Desktop.app"
fi

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
