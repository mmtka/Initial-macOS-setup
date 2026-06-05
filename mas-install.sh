#!/usr/bin/env bash
set -uo pipefail
# Standalone, re-runnable Mac App Store installer.
# Use any time App Store apps were skipped or failed during bootstrap:
#
#   ./mas-install.sh
#
# Installs every `mas` entry from the Brewfile, skips already-installed apps,
# continues past failures, and prints a summary at the end.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export MAS_REPO_DIR="${REPO_DIR}"
BREWFILE="${BREWFILE:-${REPO_DIR}/Brewfile}"

if ! command -v mas >/dev/null 2>&1; then
  echo "==> Installing 'mas'..."
  if command -v brew >/dev/null 2>&1; then
    brew install mas
  else
    echo "ERROR: Homebrew not found. Install Homebrew first." >&2
    exit 1
  fi
fi

# shellcheck source=lib/mas.sh
source "${REPO_DIR}/lib/mas.sh"

echo "==> Mac App Store apps"
mas_ensure_signed_in
mas_install_from_brewfile "${BREWFILE}"
