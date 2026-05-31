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
step "Welcome to Initial macOS Setup"
echo "  This one-shot installer will:"
echo "    1. Clone the setup repo to ${TMP_DIR}"
echo "    2. Hand off to bootstrap.sh which does the rest"
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
chmod +x bootstrap.sh

# ─────────────────────────────────────────────────────────────────────────────
step "Handing off to bootstrap.sh"
echo "  From here on, bootstrap.sh drives the installation."
echo "  A full log will be written to ~/bootstrap-<timestamp>.log"
echo

exec ./bootstrap.sh
