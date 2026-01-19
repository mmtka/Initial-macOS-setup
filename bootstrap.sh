#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="${REPO_DIR}/Brewfile"

echo "==> 1) Xcode Command Line Tools (ak treba)"
xcode-select -p >/dev/null 2>&1 || xcode-select --install || true

echo "==> 2) Homebrew (ak treba)"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "==> 3) brew bundle (install všetkého z Brewfile)"
brew update
brew bundle --file "${BREWFILE}"

echo "==> 4) macOS defaults"
bash "${REPO_DIR}/defaults.sh" || true

echo "==> DONE"
echo "Pozn.: 'mas' vyžaduje prihlásenie do App Store."

