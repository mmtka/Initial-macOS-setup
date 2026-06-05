#!/usr/bin/env bash
set -euo pipefail

TMP_DIR="/tmp/Initial-macOS-setup"

# ─────────────────────────────────────────────────────────────────────────────
# Colour helpers
# ─────────────────────────────────────────────────────────────────────────────
bold=$(tput bold 2>/dev/null || true)
reset=$(tput sgr0 2>/dev/null || true)
cyan=$(tput setaf 6 2>/dev/null || true)
green=$(tput setaf 2 2>/dev/null || true)
yellow=$(tput setaf 3 2>/dev/null || true)

step()  { echo; echo "${bold}${cyan}==>${reset}${bold} $*${reset}"; }
ok()    { echo "${green}✓${reset} $*"; }
warn()  { echo "${yellow}⚠${reset} $*"; }

# ─────────────────────────────────────────────────────────────────────────────
# Self-cleanup — remove the temporary clone when we exit, so the installer never
# leaves leftovers behind. Set KEEP_CLONE=1 to keep it (useful for debugging).
# Runs on success, failure, or Ctrl-C. We cd out first so rm can remove the cwd.
# ─────────────────────────────────────────────────────────────────────────────
cleanup() {
  local ec=$?
  cd / 2>/dev/null || true
  if [[ "${KEEP_CLONE:-0}" == "1" ]]; then
    warn "Keeping clone at ${TMP_DIR} (KEEP_CLONE=1)"
  elif [[ -d "${TMP_DIR}" ]]; then
    rm -rf "${TMP_DIR}" 2>/dev/null || sudo rm -rf "${TMP_DIR}" 2>/dev/null || true
    ok "Removed temporary clone (${TMP_DIR})"
  fi
  return "${ec}"
}
trap cleanup EXIT INT TERM

# ─────────────────────────────────────────────────────────────────────────────
step "Welcome to Initial macOS Setup"
echo "  This one-shot installer will:"
echo "    1. Clone the setup repo to ${TMP_DIR}"
echo "    2. Hand off to the installer (tui.sh → bootstrap.sh)"
echo "    3. Remove the temporary clone when finished (no leftovers)"
echo
echo "  Expected total time: 5–20 min (depending on Brewfile size)"
echo "  You may be asked for your sudo password once."
echo

# ─────────────────────────────────────────────────────────────────────────────
step "Cloning Initial macOS Setup"

# Remove previous clone — sudo only when needed (handles root-owned /tmp clone)
if [[ -d "${TMP_DIR}" ]]; then
  warn "Found previous clone at ${TMP_DIR} — removing it"
  rm -rf "${TMP_DIR}" 2>/dev/null || sudo rm -rf "${TMP_DIR}"
fi

git clone https://github.com/mmtka/Initial-macOS-setup.git "${TMP_DIR}"
ok "Repo cloned to ${TMP_DIR}"

cd "${TMP_DIR}"
chmod +x bootstrap.sh tui.sh 2>/dev/null || chmod +x bootstrap.sh

# ─────────────────────────────────────────────────────────────────────────────
step "Launching the interactive installer (tui.sh)"
echo "  tui.sh lets you choose what to install, then hands off to bootstrap.sh."
echo "  A full log will be written to ~/bootstrap-<timestamp>.log"
echo

# Run as a child (NOT exec) so control returns here and the cleanup trap fires.
# tui.sh internally execs bootstrap.sh; that all happens inside this child.
if [[ -f tui.sh ]]; then
  ./tui.sh
else
  ./bootstrap.sh
fi

step "Setup complete"
ok "All done. The temporary clone will now be removed."
echo "  Your working copy (if you keep one) is unaffected."
