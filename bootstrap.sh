#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="${REPO_DIR}/Brewfile"

# ─────────────────────────────────────────────────────────────────────────────
# Colour helpers (safe — no-op if tput unavailable)
# ─────────────────────────────────────────────────────────────────────────────
bold=$(tput bold   2>/dev/null || true)
reset=$(tput sgr0  2>/dev/null || true)
cyan=$(tput setaf 6 2>/dev/null || true)
green=$(tput setaf 2 2>/dev/null || true)
yellow=$(tput setaf 3 2>/dev/null || true)
red=$(tput setaf 1 2>/dev/null || true)

step()  { echo; echo "${bold}${cyan}==>${reset}${bold} $*${reset}"; }
ok()    { echo "${green}✓${reset} $*"; }
warn()  { echo "${yellow}⚠${reset} $*"; }
err()   { echo "${red}✗${reset} $*" >&2; }

# ─────────────────────────────────────────────────────────────────────────────
# Progress tracker (total steps = 12)
# ─────────────────────────────────────────────────────────────────────────────
TOTAL_STEPS=12
CURRENT_STEP=0

progress() {
  CURRENT_STEP=$(( CURRENT_STEP + 1 ))
  echo
  echo "${bold}${cyan}[${CURRENT_STEP}/${TOTAL_STEPS}]${reset}${bold} $*${reset}"
  echo "${cyan}────────────────────────────────────────${reset}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Load configuration
# ─────────────────────────────────────────────────────────────────────────────
if [[ -f "${REPO_DIR}/config.sh" ]]; then
  # shellcheck source=config.sh
  source "${REPO_DIR}/config.sh"
else
  warn "config.sh not found — using built-in defaults"
  CREATE_BACKUP=true
  ENABLE_POWER_DEFAULTS=true
  ENABLE_DOCK_LAYOUT=true
  AUTO_CLEANUP_BREW=true
fi

# ─────────────────────────────────────────────────────────────────────────────
# Logging — tee to both stdout and log file
# ─────────────────────────────────────────────────────────────────────────────
LOG_FILE="${HOME}/bootstrap-$(date +%Y%m%d-%H%M%S).log"
DESKTOP_LOG="${HOME}/Desktop/bootstrap-report-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo
echo "${bold}Bootstrap log:${reset} ${LOG_FILE}"
echo

# ─────────────────────────────────────────────────────────────────────────────
# Track failed items for the final report
# ─────────────────────────────────────────────────────────────────────────────
FAILED_ITEMS=()

# ─────────────────────────────────────────────────────────────────────────────
# Load backup library
# ─────────────────────────────────────────────────────────────────────────────
if [[ -f "${REPO_DIR}/lib/backup.sh" ]]; then
  # shellcheck source=lib/backup.sh
  source "${REPO_DIR}/lib/backup.sh"
fi

# ─────────────────────────────────────────────────────────────────────────────
# PRE-BOOTSTRAP HOOK
# ─────────────────────────────────────────────────────────────────────────────
if [[ -f "${REPO_DIR}/hooks/pre-bootstrap.sh" ]]; then
  step "Running pre-bootstrap hook"
  bash "${REPO_DIR}/hooks/pre-bootstrap.sh" || {
    err "Pre-bootstrap hook failed — aborting"
    exit 1
  }
fi

# ─────────────────────────────────────────────────────────────────────────────
progress "Rosetta 2 (Apple Silicon only)"
echo   "  Ensures x86_64 binaries can run on your Apple Silicon Mac."
# ─────────────────────────────────────────────────────────────────────────────
ARCH="$(uname -m)"
if [[ "${ARCH}" == "arm64" ]]; then
  if /usr/bin/pgrep oahd >/dev/null 2>&1; then
    ok "Rosetta 2 already installed"
  else
    echo "  Installing Rosetta 2 — this is silent and fast..."
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license || true
    ok "Rosetta 2 installed"
  fi
else
  echo "  Intel Mac detected — Rosetta 2 not needed, skipping."
fi

# ─────────────────────────────────────────────────────────────────────────────
progress "Xcode Command Line Tools"
echo   "  Required by Homebrew, git, and most build tools."
# ─────────────────────────────────────────────────────────────────────────────
if xcode-select -p >/dev/null 2>&1; then
  ok "Xcode Command Line Tools already installed"
else
  echo "  Launching installer — a GUI dialog will appear."
  xcode-select --install || true
  echo
  warn "Complete the Xcode CLT installer dialog, then re-run this script."
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
progress "Homebrew"
echo   "  The missing package manager for macOS."
echo   "  All formulae, casks and MAS apps flow through it."
# ─────────────────────────────────────────────────────────────────────────────
if command -v brew >/dev/null 2>&1; then
  ok "Homebrew already installed"
else
  echo "  Downloading and installing Homebrew — may ask for sudo password."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ok "Homebrew installed"
fi

# Ensure brew is in PATH for Apple Silicon (needed immediately in the same session)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ─────────────────────────────────────────────────────────────────────────────
progress "Minimal zsh init"
echo   "  Writing ~/.zprofile (login) and ~/.zshrc (interactive) if missing."
echo   "  Existing custom config is left untouched — we only add what's needed."
# ─────────────────────────────────────────────────────────────────────────────
ZPROFILE="${HOME}/.zprofile"
ZSHRC="${HOME}/.zshrc"

if [[ ! -f "${ZPROFILE}" ]]; then
  cat > "${ZPROFILE}" <<'ZP'
# ~/.zprofile — runs once per login session

# Homebrew (Apple Silicon)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
ZP
  ok "Created ${ZPROFILE}"
else
  if ! grep -q '/opt/homebrew/bin/brew shellenv' "${ZPROFILE}"; then
    cat >> "${ZPROFILE}" <<'ZP_ADD'

# Homebrew (Apple Silicon)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
ZP_ADD
    ok "Updated ${ZPROFILE} with Homebrew PATH"
  else
    ok "${ZPROFILE} already configured"
  fi
fi

if [[ ! -f "${ZSHRC}" ]]; then
  cat > "${ZSHRC}" <<'ZR'
# ~/.zshrc — runs for every interactive shell

# De-duplicate PATH entries
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

# Minimal prompt
autoload -Uz colors && colors
PROMPT='%F{cyan}%n@%m%f:%F{yellow}%~%f %# '

# Handy aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -lah'
ZR
  ok "Created ${ZSHRC}"
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
  ok "${ZSHRC} already configured"
fi

# ─────────────────────────────────────────────────────────────────────────────
progress "Backup current system settings"
echo   "  Exporting defaults domains to ${BACKUP_DIR:-~/.macos-setup-backups}"
echo   "  so you can roll back any change made by this script."
# ─────────────────────────────────────────────────────────────────────────────
if [[ "${CREATE_BACKUP:-true}" == "true" ]]; then
  if command -v create_backup >/dev/null 2>&1; then
    create_backup
  else
    warn "Backup function not available (lib/backup.sh missing), skipping"
  fi
else
  echo "  ℹ Backup disabled in config.sh — skipping."
fi

# ─────────────────────────────────────────────────────────────────────────────
progress "Mac App Store — login check"
echo   "  MAS apps in the Brewfile require an App Store session."
# ─────────────────────────────────────────────────────────────────────────────
if ! command -v mas >/dev/null 2>&1; then
  echo "  Installing 'mas' CLI..."
  brew install mas
fi

if mas account 2>/dev/null | grep -qi '@'; then
  ok "Logged into App Store: $(mas account 2>/dev/null)"
  MAS_READY=1
else
  warn "NOT logged into App Store"
  echo "  MAS apps will be skipped during bundle install."
  echo "  To install them later:"
  echo "    1. Open App Store.app and sign in"
  echo "    2. Run: brew bundle --file ${BREWFILE}"
  MAS_READY=0
fi

# ─────────────────────────────────────────────────────────────────────────────
progress "Install from Brewfile (brew bundle)"
echo   "  Installing formulae, casks and MAS apps listed in Brewfile."
echo   "  This is typically the longest step — grab a coffee ☕"
# ─────────────────────────────────────────────────────────────────────────────
echo "  Updating Homebrew first..."

# Verbose brew so you see every formula/cask as it's processed
set +e
HOMEBREW_COLOR=1 brew bundle install --verbose --file "${BREWFILE}" 2>&1 | while IFS= read -r line; do
  echo "  ${line}"
  if [[ "${line}" == *"Error:"* ]] || [[ "${line}" == *"error:"* ]]; then
    failed_item="$(echo "${line}" | sed 's/.*[Ee]rror: //')"
    FAILED_ITEMS+=("${failed_item}")
  fi
done
BREW_EXIT=${PIPESTATUS[0]}
set -e

if [[ ${BREW_EXIT} -ne 0 ]]; then
  warn "brew bundle exited with errors (code ${BREW_EXIT})"
  if [[ -t 0 ]]; then
    printf "  Continue despite errors? [Y/n]: "
    read -r answer
    case "${answer}" in
      [nN]) err "Bootstrap aborted by user."; exit 1 ;;
      *)    echo "  Continuing..."; ;;
    esac
  else
    echo "  Non-interactive mode — continuing automatically."
  fi
fi

[[ "${MAS_READY}" == "0" ]] && warn "MAS apps were skipped (not signed into App Store)"

# ─────────────────────────────────────────────────────────────────────────────
if [[ "${AUTO_CLEANUP_BREW:-true}" == "true" ]]; then
  progress "Cleanup orphaned Homebrew packages"
  echo   "  Removing packages no longer listed in the Brewfile."
  brew bundle cleanup --file "${BREWFILE}" --force || warn "Cleanup failed (non-critical)"
fi

# ─────────────────────────────────────────────────────────────────────────────
progress "macOS defaults — safe"
echo   "  Applying sensible defaults: Finder, Dock, screenshots, locale…"
echo   "  None of these changes require a restart."
# ─────────────────────────────────────────────────────────────────────────────
if [[ -f "${REPO_DIR}/defaults/defaults.safe.sh" ]]; then
  bash "${REPO_DIR}/defaults/defaults.safe.sh"
  ok "Safe defaults applied"
else
  warn "defaults/defaults.safe.sh not found, skipping"
fi

# ─────────────────────────────────────────────────────────────────────────────
if [[ "${ENABLE_POWER_DEFAULTS:-true}" == "true" ]]; then
  progress "macOS defaults — power (needs sudo)"
  echo   "  Timezone, boot sound, power management, firewall…"
  echo   "  Will prompt for sudo password."
  if [[ -f "${REPO_DIR}/defaults/defaults.power.sh" ]]; then
    bash "${REPO_DIR}/defaults/defaults.power.sh"
    ok "Power defaults applied"
  else
    warn "defaults/defaults.power.sh not found, skipping"
  fi
else
  progress "macOS defaults — power"
  echo   "  ℹ Power defaults disabled in config.sh — skipping."
fi

# ─────────────────────────────────────────────────────────────────────────────
if [[ "${ENABLE_DOCK_LAYOUT:-true}" == "true" ]]; then
  progress "Dock layout"
  echo   "  Arranging your Dock via dockutil — best effort, non-fatal."
  if [[ -f "${REPO_DIR}/dock/layout.sh" ]]; then
    bash "${REPO_DIR}/dock/layout.sh" || warn "Dock layout failed (non-critical)"
  else
    warn "dock/layout.sh not found, skipping"
  fi
else
  progress "Dock layout"
  echo   "  ℹ Dock layout disabled in config.sh — skipping."
fi

# ─────────────────────────────────────────────────────────────────────────────
progress "Apply changes (restart Finder, Dock, SystemUIServer)"
echo   "  Bouncing system processes so all defaults take effect immediately."
# ─────────────────────────────────────────────────────────────────────────────
if [[ -f "${REPO_DIR}/defaults/apply.sh" ]]; then
  bash "${REPO_DIR}/defaults/apply.sh"
  ok "System processes restarted"
else
  warn "defaults/apply.sh not found, skipping"
fi

# ─────────────────────────────────────────────────────────────────────────────
# POST-BOOTSTRAP HOOK
# ─────────────────────────────────────────────────────────────────────────────
if [[ -f "${REPO_DIR}/hooks/post-bootstrap.sh" ]]; then
  progress "Post-bootstrap hook"
  bash "${REPO_DIR}/hooks/post-bootstrap.sh" || warn "Post-bootstrap hook failed (non-critical)"
fi

# ─────────────────────────────────────────────────────────────────────────────
progress "Generating desktop report"
echo   "  Writing a summary of what was installed (and what failed) to your Desktop."
# ─────────────────────────────────────────────────────────────────────────────
{
  echo "=== Bootstrap Report — $(date '+%Y-%m-%d %H:%M:%S') ==="
  echo "Log file : ${LOG_FILE}"
  echo

  if [[ ${#FAILED_ITEMS[@]} -eq 0 ]]; then
    echo "✓ All items installed successfully — no failures."
  else
    echo "✗ Items that FAILED to install (install manually):"
    echo
    for item in "${FAILED_ITEMS[@]}"; do
      echo "  - ${item}"
    done
    echo
    echo "Help: https://github.com/mmtka/Initial-macOS-setup/blob/main/FAQ.md"
  fi

  if [[ "${MAS_READY:-0}" == "0" ]]; then
    echo
    echo "⚠ App Store (MAS) apps were skipped — you were not signed in."
    echo "  After signing in run: brew bundle --file ${BREWFILE}"
  fi
} > "${DESKTOP_LOG}"

if [[ ${#FAILED_ITEMS[@]} -gt 0 ]]; then
  warn "Report with failures saved to: ${DESKTOP_LOG}"
else
  ok "No failures — report saved to: ${DESKTOP_LOG}"
fi

# ─────────────────────────────────────────────────────────────────────────────
# FINAL SUMMARY
# ─────────────────────────────────────────────────────────────────────────────
echo
echo "${bold}${green}╔══════════════════════════════════════════════╗${reset}"
echo "${bold}${green}║          Bootstrap complete!                 ║${reset}"
echo "${bold}${green}╚══════════════════════════════════════════════╝${reset}"
echo
echo "  ${green}✓${reset} Homebrew packages processed"
echo "  ${green}✓${reset} macOS defaults configured"
echo "  ${green}✓${reset} zsh initialised"

if [[ "${MAS_READY:-0}" == "0" ]]; then
  echo "  ${yellow}⚠${reset} MAS apps skipped — sign in to App Store, then: brew bundle"
fi

if [[ "${CREATE_BACKUP:-true}" == "true" ]]; then
  LATEST_BACKUP=$(ls -t "${BACKUP_DIR:-${HOME}/.macos-setup-backups}" 2>/dev/null | head -1 || true)
  [[ -n "${LATEST_BACKUP}" ]] && echo "  ${green}✓${reset} Backup: ${BACKUP_DIR:-${HOME}/.macos-setup-backups}/${LATEST_BACKUP}"
fi

echo
echo "  ${bold}Full log    :${reset} ${LOG_FILE}"
echo "  ${bold}Desktop report:${reset} ${DESKTOP_LOG}"
echo
echo "  Notes:"
echo "    • Some changes require a logout or restart to fully apply."
echo "    • Open a new terminal (or run 'exec zsh') to pick up zsh changes."
[[ "${CREATE_BACKUP:-true}" == "true" ]] && \
  echo "    • To restore backup: source lib/backup.sh && restore_backup <path>"
echo