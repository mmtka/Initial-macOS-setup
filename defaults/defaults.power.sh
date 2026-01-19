#!/usr/bin/env bash
set -euo pipefail

# Load configuration
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
if [[ -f "${REPO_DIR}/config.sh" ]]; then
  source "${REPO_DIR}/config.sh"
fi

###############################################################################
# POWER DEFAULTS (needs sudo; includes security tradeoffs)
###############################################################################
sudo -v

# Keep timezone from config.sh
echo "Setting timezone to: ${TIMEZONE}"
sudo systemsetup -settimezone "${TIMEZONE}" >/dev/null 2>&1 || true

# Disable boot sound
sudo nvram SystemAudioVolume=" " 2>/dev/null || true

# Gatekeeper quarantine (SECURITY TRADEOFF - from config.sh)
if [[ "${DISABLE_GATEKEEPER_QUARANTINE}" == "true" ]]; then
  echo "⚠ WARNING: Disabling Gatekeeper quarantine (security risk)"
  defaults write com.apple.LaunchServices LSQuarantine -bool false
else
  echo "✓ Gatekeeper quarantine remains enabled (recommended)"
fi

# Fn key behavior (1 = Emoji & Symbols on many macOS versions)
defaults write com.apple.HIToolbox AppleFnUsageType -int 1

# Power management
sudo pmset -a lidwake 1
sudo pmset -a displaysleep 5
sudo pmset -c sleep 0
sudo pmset -b sleep 10

# Disable hibernation (TRADEOFF: no safe sleep)
sudo pmset -a hibernatemode 0 2>/dev/null || true

# Firewall (may require UI approval on some macOS versions)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on >/dev/null 2>&1 || true
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on >/dev/null 2>&1 || true

# Apple feature flag (safe if missing)
defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool false 2>/dev/null || true
