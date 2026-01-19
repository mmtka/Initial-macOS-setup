#!/usr/bin/env bash
set -euo pipefail

TMP_DIR="/tmp/Initial-macOS-setup"

echo "==> Cloning Initial macOS Setup"
rm -rf "${TMP_DIR}"
git clone https://github.com/mmtka/Initial-macOS-setup.git "${TMP_DIR}"

cd "${TMP_DIR}"
chmod +x bootstrap.sh

echo "==> Running bootstrap"
./bootstrap.sh
