#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# APPLY — restart affected system processes so defaults take effect immediately
###############################################################################

echo "  Restarting Finder, Dock, SystemUIServer, cfprefsd…"

# Rebuild LaunchServices database (fixes stale "Open With" menu entries)
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -kill -r -domain local -domain system -domain user >/dev/null 2>&1 || true

killall Finder        >/dev/null 2>&1 || true
killall Dock          >/dev/null 2>&1 || true
killall SystemUIServer >/dev/null 2>&1 || true
killall cfprefsd      >/dev/null 2>&1 || true
