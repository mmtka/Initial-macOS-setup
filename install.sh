#!/usr/bin/env bash
set -euo pipefail

TMP_DIR="/tmp/Initial-macOS-setup"

echo "==> Cloning Initial macOS Setup"

# Remove previous clone – use sudo only if needed (handles root-owned /tmp clone)
if [[ -d "${TMP_DIR}" ]]; then
  rm -rf "${TMP_DIR}" 2>/dev/null || sudo rm -rf "${TMP_DIR}"
fi

git clone https://github.com/mmtka/Initial-macOS-setup.git "${TMP_DIR}"

cd "${TMP_DIR}"
chmod +x bootstrap.sh

echo "==> Running bootstrap"
exec ./bootstrap.sh
