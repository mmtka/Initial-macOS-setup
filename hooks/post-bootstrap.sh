#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Post-bootstrap hook
# Runs AFTER bootstrap.sh completes successfully.
# bootstrap.sh already prints the step header — do NOT echo it again here.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

echo "  Running post-install tasks…"

# ── Create common project directories ───────────────────────────────────────
echo "  → Creating ~/Projects and ~/Screenshots…"
mkdir -p "${HOME}/Projects"
# Screenshots dir is handled by defaults.safe.sh via SCREENSHOT_DIR from config.sh
# We mirror it here as a safety net in case defaults ran before this hook.
SCREENSHOT_DIR="${HOME}/Screenshots"
mkdir -p "${SCREENSHOT_DIR}"
echo "  ✓ Directories ready"

# ── Uncomment to clone dotfiles ──────────────────────────────────────────────
# if [[ ! -d "${HOME}/.dotfiles" ]]; then
#   echo "  → Cloning dotfiles…"
#   git clone https://github.com/yourusername/dotfiles.git "${HOME}/.dotfiles"
# fi

# ── Uncomment to generate an SSH key ────────────────────────────────────────
# if [[ ! -f "${HOME}/.ssh/id_ed25519" ]]; then
#   echo "  → Generating SSH key (ed25519)…"
#   ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f "${HOME}/.ssh/id_ed25519" -N ""
# fi

echo "✓ Post-bootstrap tasks complete"
