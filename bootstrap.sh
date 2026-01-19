#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="${REPO_DIR}/Brewfile"

# Load configuration
if [[ -f "${REPO_DIR}/config.sh" ]]; then
  source "${REPO_DIR}/config.sh"
else
  echo "⚠ config.sh not found, using defaults"
  CREATE_BACKUP=true
  ENABLE_POWER_DEFAULTS=true
  ENABLE_DOCK_LAYOUT=true
  AUTO_CLEANUP_BREW=true
fi

# Logging
LOG_FILE="${HOME}/bootstrap-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "==> Bootstrap log: ${LOG_FILE}"
echo

# Load backup library if available
if [[ -f "${REPO_DIR}/lib/backup.sh" ]]; then
  source "${REPO_DIR}/lib/backup.sh"
fi

echo "==> 0) Rosetta (Apple Silicon only)"
ARCH="$(uname -m)"
if [[ "${ARCH}" == "arm64" ]]; then
  if /usr/bin/pgrep oahd >/dev/null 2>&1; then
    echo "✓ Rosetta already installed"
  else
    echo "Installing Rosetta..."
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license || true
  fi
else
  echo "Intel Mac detected, skipping Rosetta"
fi

echo
echo "==> 1) Xcode Command Line Tools (if needed)"
if xcode-select -p >/dev/null 2>&1; then
  echo "✓ Xcode Command Line Tools already installed"
else
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install || true
  echo "⚠ Complete the installer prompt, then re-run this script"
  exit 0
fi

echo
echo "==> 2) Homebrew (if needed)"
if command -v brew >/dev/null 2>&1; then
  echo "✓ Homebrew already installed"
else
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew in PATH for Apple Silicon
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo
echo "==> 3) Minimal zsh init"
ZPROFILE="${HOME}/.zprofile"
ZSHRC="${HOME}/.zshrc"

# Ensure .zprofile exists and contains brew shellenv exactly once
if [[ ! -f "${ZPROFILE}" ]]; then
  cat > "${ZPROFILE}" <<'ZP'
# ~/.zprofile
# Login shell config (runs once per login)

# Homebrew (Apple Silicon)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
ZP
  echo "✓ Created ${ZPROFILE}"
else
  if ! grep -q '/opt/homebrew/bin/brew shellenv' "${ZPROFILE}"; then
    cat >> "${ZPROFILE}" <<'ZP_ADD'

# Homebrew (Apple Silicon)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
ZP_ADD
    echo "✓ Updated ${ZPROFILE}"
  else
    echo "✓ ${ZPROFILE} already configured"
  fi
fi

# Ensure .zshrc exists with minimal sane defaults
if [[ ! -f "${ZSHRC}" ]]; then
  cat > "${ZSHRC}" <<'ZR'
# ~/.zshrc
# Interactive shell config

# De-duplicate PATH entries (prevents PATH bloat)
typeset -U path PATH

# History
HISTFILE=~/.zsh_history
HISTSIZE=20000
SAVEHIST=20000
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# Completion
autoload -Uz compinit
compinit -u

# Prompt (minimal)
autoload -Uz colors && colors
PROMPT='%F{cyan}%n@%m%f:%F{yellow}%~%f %# '

# Useful aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -lah'
ZR
  echo "✓ Created ${ZSHRC}"
else
  if ! grep -q '^typeset -U path PATH$' "${ZSHRC}"; then
    printf '\n# De-duplicate PATH entries\ntypeset -U path PATH\n' >> "${ZSHRC}"
  fi
  
  if ! grep -q 'compinit' "${ZSHRC}"; then
    cat >> "${ZSHRC}" <<'ZR_ADD'

# Completion
autoload -Uz compinit
compinit -u
ZR_ADD
  fi
  echo "✓ ${ZSHRC} already configured"
fi

echo
echo "==> 4) Backup current system settings"
if command -v create_backup >/dev/null 2>&1; then
  create_backup
else
  echo "ℹ Backup function not available, skipping"
fi

echo
echo "==> 5) MAS (Mac App Store) login check"

# Ensure mas is available early
if ! command -v mas >/dev/null 2>&1; then
  echo "Installing 'mas' (required for App Store apps)..."
  brew install mas
fi

# Check MAS login status
if mas account 2>/dev/null | grep -qi '@'; then
  echo "✓ Logged into App Store ($(mas account 2>/dev/null))"
  MAS_READY=1
else
  echo "⚠ NOT logged into App Store"
  echo "  MAS apps will be skipped during bundle install"
  echo "  To install them later:"
  echo "    1. Sign in via App Store.app"
  echo "    2. Run: brew bundle --file ${BREWFILE}"
  MAS_READY=0
fi

echo
echo "==> 6) Install from Brewfile (brew bundle)"
brew update
brew bundle --file "${BREWFILE}" --no-lock

if [[ "${MAS_READY}" == "0" ]]; then
  echo
  echo "⚠ MAS apps were skipped (not logged into App Store)"
fi

# Auto-cleanup orphaned packages
if [[ "${AUTO_CLEANUP_BREW:-true}" == "true" ]]; then
  echo
  echo "==> 7) Cleanup orphaned Homebrew packages"
  brew bundle cleanup --file "${BREWFILE}" --force || echo "⚠ Cleanup failed (non-critical)"
fi

echo
echo "==> 8) macOS defaults (safe)"
if [[ -f "${REPO_DIR}/defaults/defaults.safe.sh" ]]; then
  bash "${REPO_DIR}/defaults/defaults.safe.sh"
else
  echo "⚠ defaults.safe.sh not found, skipping"
fi

if [[ "${ENABLE_POWER_DEFAULTS:-true}" == "true" ]]; then
  echo
  echo "==> 9) macOS defaults (power) - requires sudo"
  if [[ -f "${REPO_DIR}/defaults/defaults.power.sh" ]]; then
    bash "${REPO_DIR}/defaults/defaults.power.sh"
  else
    echo "⚠ defaults.power.sh not found, skipping"
  fi
else
  echo
  echo "ℹ Power defaults disabled in config.sh"
fi

if [[ "${ENABLE_DOCK_LAYOUT:-true}" == "true" ]]; then
  echo
  echo "==> 10) Dock layout (dockutil) - best effort"
  if [[ -f "${REPO_DIR}/dock/layout.sh" ]]; then
    bash "${REPO_DIR}/dock/layout.sh" || echo "⚠ Dock layout failed (non-critical)"
  else
    echo "⚠ dock/layout.sh not found, skipping"
  fi
else
  echo
  echo "ℹ Dock layout disabled in config.sh"
fi

echo
echo "==> 11) Apply changes"
if [[ -f "${REPO_DIR}/defaults/apply.sh" ]]; then
  bash "${REPO_DIR}/defaults/apply.sh"
else
  echo "⚠ defaults/apply.sh not found, skipping"
fi

echo
echo "==> DONE"
echo
echo "Summary:"
echo "  ✓ Homebrew packages installed"
echo "  ✓ macOS defaults configured"
echo "  ✓ zsh configured"
if [[ "${MAS_READY}" == "0" ]]; then
  echo "  ⚠ MAS apps skipped (sign into App Store and re-run: brew bundle)"
fi
if [[ "${CREATE_BACKUP:-true}" == "true" ]] && [[ -d "${BACKUP_DIR:-${HOME}/.macos-setup-backups}" ]]; then
  LATEST_BACKUP=$(ls -t "${BACKUP_DIR:-${HOME}/.macos-setup-backups}" 2>/dev/null | head -1)
  if [[ -n "$LATEST_BACKUP" ]]; then
    echo "  ✓ Backup created: ${BACKUP_DIR:-${HOME}/.macos-setup-backups}/${LATEST_BACKUP}"
  fi
fi
echo
echo "Notes:"
echo "  - Full log saved to: ${LOG_FILE}"
echo "  - Some changes require logout/reboot"
echo "  - New zsh settings: open new terminal or run 'exec zsh'"
if [[ "${CREATE_BACKUP:-true}" == "true" ]]; then
  echo "  - To restore backup: source lib/backup.sh && restore_backup <path>"
fi
echo
