#!/usr/bin/env bash
# ============================================
# Post-bootstrap hook
# Runs after bootstrap.sh completes successfully
# ============================================

set -euo pipefail

echo "==> Running post-bootstrap hook"

# Example: Set up additional configurations
# Example: Clone dotfiles repository
# if [[ ! -d "${HOME}/.dotfiles" ]]; then
#   echo "Cloning dotfiles..."
#   git clone https://github.com/yourusername/dotfiles.git "${HOME}/.dotfiles"
# fi

# Example: Set up SSH keys
# if [[ ! -f "${HOME}/.ssh/id_ed25519" ]]; then
#   echo "Generating SSH key..."
#   ssh-keygen -t ed25519 -C "your_email@example.com" -f "${HOME}/.ssh/id_ed25519" -N ""
# fi

# Example: Create common directories
# mkdir -p "${HOME}/Projects"
# mkdir -p "${HOME}/Documents/Work"
# mkdir -p "${HOME}/Downloads/Temp"

echo "✓ Post-bootstrap tasks complete"
