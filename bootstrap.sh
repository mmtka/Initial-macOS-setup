#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# BREWFILE may be overridden from the environment (e.g. by tui.sh for Minimal).
BREWFILE="${BREWFILE:-${REPO_DIR}/Brewfile}"

# Load configuration
if [[ -f "${REPO_DIR}/config.sh" ]]; then
  source "${REPO_DIR}/config.sh"
else
  echo "⚠ config.sh not found, using defaults"
  CREATE_BACKUP=true
  ENABLE_HOMEBREW=true
  ENABLE_DEFAULTS_SAFE=true
  ENABLE_POWER_DEFAULTS=true
  ENABLE_DOCK_LAYOUT=true
  AUTO_CLEANUP_BREW=true
  ENABLE_TOUCHID_SUDO=true
  ENABLE_PROFILES=true
  REMOVE_CONFLICTING_PROFILES=false
fi

# Where to look for .mobileconfig profiles (config.sh may override PROFILES_DIR).
PROFILES_DIR="${PROFILES_DIR:-${REPO_DIR}/profiles/mobileconfig}"

# Logging
LOG_FILE="${HOME}/bootstrap-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "==> Bootstrap log: ${LOG_FILE}"
echo

# Load backup library if available
if [[ -f "${REPO_DIR}/lib/backup.sh" ]]; then
  source "${REPO_DIR}/lib/backup.sh"
fi

# Load configuration-profile helpers if available
if [[ -f "${REPO_DIR}/lib/profiles.sh" ]]; then
  # shellcheck source=lib/profiles.sh
  source "${REPO_DIR}/lib/profiles.sh"
fi

# Pre-bootstrap hook
if [[ -f "${REPO_DIR}/hooks/pre-bootstrap.sh" ]]; then
  echo "==> Running pre-bootstrap hook"
  bash "${REPO_DIR}/hooks/pre-bootstrap.sh" || {
    echo "ERROR: Pre-bootstrap hook failed"
    exit 1
  }
  echo
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

# -----------------------------------------------------------------------------
# Administrator access — Touch ID + single prompt for the whole run.
# Placed here (after the CLT check that may exit) so we never ask before we are
# sure the run continues. Homebrew and the macOS defaults below all need sudo.
# -----------------------------------------------------------------------------
echo
echo "==> 1.5) Administrator access (Touch ID + single prompt)"

# Enable Touch ID for sudo via the update-safe drop-in (macOS 14+). Needs a typed
# password the very first time only; afterwards sudo accepts Touch ID.
if [[ "${ENABLE_TOUCHID_SUDO:-true}" == "true" ]]; then
  if [[ -f /etc/pam.d/sudo_local ]] && \
     grep -qE '^auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' /etc/pam.d/sudo_local; then
    echo "✓ Touch ID for sudo already enabled"
  elif [[ -f /etc/pam.d/sudo_local.template ]]; then
    echo "Enabling Touch ID for sudo (password required this once)..."
    sed 's/^#\(auth[[:space:]].*pam_tid\.so\)/\1/' /etc/pam.d/sudo_local.template \
      | sudo tee /etc/pam.d/sudo_local >/dev/null
    echo "✓ Touch ID for sudo enabled"
  else
    echo "ℹ Touch ID drop-in not available on this macOS; sudo will use a password"
  fi
fi

# Prime sudo once (Touch ID if enabled above), then keep the timestamp warm in the
# background so no further prompts appear for the rest of the run.
echo "Authenticating for administrator tasks..."
sudo -v
( while true; do sudo -n true 2>/dev/null || true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) &
SUDO_KEEPALIVE_PID=$!
trap 'kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true' EXIT
echo "✓ Administrator access granted for this session"

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

if [[ "${ENABLE_HOMEBREW:-true}" != "true" ]]; then
  echo
  echo "ℹ Homebrew bundle disabled in config — skipping MAS sign-in, brew bundle and cleanup"
else
echo
echo "==> 5) Mac App Store (MAS) sign-in"

# Ensure mas is available early
if ! command -v mas >/dev/null 2>&1; then
  echo "Installing 'mas' (required for App Store apps)..."
  brew install mas
fi

# NOTE: mas 7.x removed the `account` and `signin` subcommands (Apple dropped the
# underlying private API). There is no reliable CLI way to query sign-in state or
# to sign in from the terminal, so we open the App Store and let the user sign in
# interactively before bundling. brew bundle then installs via `mas install || mas get`.
MAS_COUNT=$(grep -cE '^[[:space:]]*mas[[:space:]]' "${BREWFILE}" 2>/dev/null || true)
MAS_COUNT=${MAS_COUNT:-0}

if [[ "${MAS_COUNT}" -gt 0 ]]; then
  echo "ℹ Brewfile lists ${MAS_COUNT} App Store app(s)."
  echo "  These can only install while you are signed into the App Store."
  open -a "App Store" >/dev/null 2>&1 || true
  if [[ -r /dev/tty ]]; then
    printf "  → Sign into the App Store, then press Enter to continue (Ctrl-C to abort)... "
    read -r _ </dev/tty || true
  else
    echo "  (non-interactive run; make sure you are already signed in)"
  fi
else
  echo "ℹ No App Store apps in Brewfile; nothing to sign in for."
fi

echo
echo "==> 6) Install from Brewfile (brew bundle)"
brew update
# Non-fatal: a single region-locked / unavailable entry must not abort the whole run.
brew bundle --file "${BREWFILE}" --verbose \
  || echo "⚠ Some Brewfile entries failed to install (see output above) — continuing"

# Auto-cleanup orphaned packages
if [[ "${AUTO_CLEANUP_BREW:-true}" == "true" ]]; then
  echo
  echo "==> 7) Cleanup orphaned Homebrew packages"
  brew bundle cleanup --file "${BREWFILE}" --force || echo "⚠ Cleanup failed (non-critical)"
fi
fi  # ENABLE_HOMEBREW

# Remove configuration profiles that would override our defaults (scripts win).
if [[ "${REMOVE_CONFLICTING_PROFILES:-false}" == "true" ]] \
   && command -v remove_conflicting_profiles >/dev/null 2>&1; then
  echo
  echo "==> 7.5) Remove conflicting configuration profiles"
  remove_conflicting_profiles
fi

if [[ "${ENABLE_DEFAULTS_SAFE:-true}" == "true" ]]; then
  echo
  echo "==> 8) macOS defaults (safe)"
  if [[ -f "${REPO_DIR}/defaults/defaults.safe.sh" ]]; then
    bash "${REPO_DIR}/defaults/defaults.safe.sh"
  else
    echo "⚠ defaults.safe.sh not found, skipping"
  fi
else
  echo
  echo "ℹ Safe defaults disabled in config.sh"
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

# Install configuration profiles (.mobileconfig). macOS opens each for manual
# approval — silent install is no longer supported. SELECTED_PROFILES (newline
# list, set by tui.sh) takes priority; otherwise all profiles in PROFILES_DIR.
if [[ "${ENABLE_PROFILES:-true}" == "true" ]] \
   && command -v install_profiles >/dev/null 2>&1; then
  PROFILE_FILES=()
  if [[ -n "${SELECTED_PROFILES:-}" ]]; then
    while IFS= read -r _p; do
      [[ -n "${_p}" ]] && PROFILE_FILES+=("${_p}")
    done <<< "${SELECTED_PROFILES}"
  else
    while IFS= read -r _p; do
      [[ -n "${_p}" ]] && PROFILE_FILES+=("${_p}")
    done <<< "$(discover_profiles "${PROFILES_DIR}")"
  fi

  if [[ "${#PROFILE_FILES[@]}" -gt 0 ]]; then
    echo
    echo "==> 12) Install configuration profiles"
    install_profiles "${PROFILE_FILES[@]}"
  fi
fi

# Post-bootstrap hook
if [[ -f "${REPO_DIR}/hooks/post-bootstrap.sh" ]]; then
  echo
  echo "==> Running post-bootstrap hook"
  bash "${REPO_DIR}/hooks/post-bootstrap.sh" || echo "⚠ Post-bootstrap hook failed (non-critical)"
fi

echo
echo "==> DONE"
echo
echo "Summary:"
echo "  ✓ Homebrew packages installed"
echo "  ✓ macOS defaults configured"
echo "  ✓ zsh configured"
if [[ "${MAS_COUNT:-0}" -gt 0 ]]; then
  echo "  ℹ If any App Store apps are missing, sign into App Store.app and re-run:"
  echo "      brew bundle --file ${BREWFILE}"
fi
if [[ "${CREATE_BACKUP:-true}" == "true" ]] && [[ -d "${BACKUP_DIR:-${HOME}/.macos-setup-backups}" ]]; then
  # Backup dirs are timestamp-named (e.g. 20260119-173000), so ls -t is safe here.
  # shellcheck disable=SC2012
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