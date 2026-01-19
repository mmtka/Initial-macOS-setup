cat > defaults/apply.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# APPLY / RESTART AFFECTED SERVICES
###############################################################################

# Rebuild LaunchServices database (Open With menu)
 /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -kill -r -domain local -domain system -domain user >/dev/null 2>&1 || true

killall Finder >/dev/null 2>&1 || true
killall Dock >/dev/null 2>&1 || true
killall SystemUIServer >/dev/null 2>&1 || true
killall cfprefsd >/dev/null 2>&1 || true
EOF

chmod +x defaults/apply.sh
