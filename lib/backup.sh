#!/usr/bin/env bash
set -euo pipefail

# ============================================
# Backup mechanism for macOS defaults
# ============================================

BACKUP_TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${BACKUP_DIR:-${HOME}/.macos-setup-backups}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_TIMESTAMP}"

create_backup() {
  if [[ "${CREATE_BACKUP:-true}" != "true" ]]; then
    echo "ℹ Backup disabled in config.sh"
    return 0
  fi

  echo "==> Creating backup of current settings"
  mkdir -p "${BACKUP_PATH}"

  # Backup critical domains
  local domains=(
    "NSGlobalDomain"
    "com.apple.finder"
    "com.apple.dock"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad"
    "com.apple.AppleMultitouchTrackpad"
    "com.apple.screencapture"
    "com.apple.Safari"
    "com.apple.ActivityMonitor"
    "com.apple.TimeMachine"
    "com.apple.LaunchServices"
  )

  for domain in "${domains[@]}"; do
    local filename="${domain}.plist"
    if defaults read "${domain}" &>/dev/null; then
      defaults export "${domain}" "${BACKUP_PATH}/${filename}" 2>/dev/null || true
    fi
  done

  # Backup current Dock layout
  if command -v dockutil >/dev/null 2>&1; then
    dockutil --list > "${BACKUP_PATH}/dock-layout.txt" 2>/dev/null || true
  fi

  # Backup current Brewfile state
  if command -v brew >/dev/null 2>&1; then
    brew bundle dump --file="${BACKUP_PATH}/Brewfile.current" --force 2>/dev/null || true
  fi

  # Create backup manifest
  cat > "${BACKUP_PATH}/MANIFEST.txt" <<EOF
Backup created: ${BACKUP_TIMESTAMP}
macOS version: $(sw_vers -productVersion)
Hostname: $(hostname)
User: ${USER}

Contents:
$(ls -1 "${BACKUP_PATH}" | grep -v MANIFEST)

To restore a specific domain:
  defaults import <domain> <path-to-plist>

Example:
  defaults import com.apple.finder "${BACKUP_PATH}/com.apple.finder.plist"
EOF

  echo "✓ Backup created: ${BACKUP_PATH}"
  echo "  Files: $(ls -1 "${BACKUP_PATH}" | wc -l | tr -d ' ')"
  echo
}

restore_backup() {
  local backup_path="$1"
  
  if [[ ! -d "${backup_path}" ]]; then
    echo "ERROR: Backup directory not found: ${backup_path}"
    return 1
  fi

  echo "==> Restoring backup from: ${backup_path}"
  
  for plist in "${backup_path}"/*.plist; do
    if [[ -f "${plist}" ]]; then
      local domain=$(basename "${plist}" .plist)
      echo "  Restoring ${domain}..."
      defaults import "${domain}" "${plist}" 2>/dev/null || echo "    ⚠ Failed to restore ${domain}"
    fi
  done

  echo "✓ Restore complete"
  echo "  Restart Finder/Dock: killall Finder Dock"
  echo "  Or logout/login for full effect"
}

list_backups() {
  if [[ ! -d "${BACKUP_DIR}" ]]; then
    echo "No backups found (${BACKUP_DIR} does not exist)"
    return 0
  fi

  echo "Available backups in ${BACKUP_DIR}:"
  echo
  
  local count=0
  for backup in "${BACKUP_DIR}"/*/; do
    if [[ -d "${backup}" ]]; then
      count=$((count + 1))
      local backup_name=$(basename "${backup}")
      local file_count=$(ls -1 "${backup}" 2>/dev/null | wc -l | tr -d ' ')
      echo "  ${count}. ${backup_name} (${file_count} files)"
    fi
  done

  if [[ ${count} -eq 0 ]]; then
    echo "  No backups found"
  fi
}

# Export functions
export -f create_backup
export -f restore_backup
export -f list_backups
