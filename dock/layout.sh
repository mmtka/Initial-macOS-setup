cat > dock/layout.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# If dockutil is not available, skip silently
command -v dockutil >/dev/null 2>&1 || exit 0

# Build a sane Dock for a fresh system.
# You can adjust later, but this gives you a clean starting point.

dockutil --no-restart --remove all || true

# Core apps
dockutil --no-restart --add "/System/Applications/Finder.app" || true
dockutil --no-restart --add "/System/Applications/Safari.app" || true
dockutil --no-restart --add "/System/Applications/Mail.app" || true
dockutil --no-restart --add "/System/Applications/Calendar.app" || true
dockutil --no-restart --add "/System/Applications/System Settings.app" || true
dockutil --no-restart --add "/System/Applications/Utilities/Terminal.app" || true

# Common 3rd-party apps (only if present)
for app in \
  "/Applications/Obsidian.app" \
  "/Applications/Visual Studio Code.app" \
  "/Applications/Nextcloud.app" \
  "/Applications/Warp.app" \
  "/Applications/Pearcleaner.app" \
  "/Applications/1Password.app" \
  "/Applications/Spotify.app" \
  "/Applications/Plexamp.app" \
  "/Applications/IINA.app" \
  "/Applications/Wireshark.app" \
  "/Applications/ProtonVPN.app"
do
  [[ -d "$app" ]] && dockutil --no-restart --add "$app" || true
done

# Add Downloads stack
dockutil --no-restart --add "${HOME}/Downloads" --view grid --display folder || true

killall Dock >/dev/null 2>&1 || true
EOF

chmod +x dock/layout.sh
