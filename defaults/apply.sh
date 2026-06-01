#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# APPLY — restart affected system processes so defaults take effect immediately
###############################################################################

echo "  Restarting cfprefsd, Finder, Dock, SystemUIServer…"

# Rebuild LaunchServices database (fixes stale "Open With" menu entries)
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -kill -r -domain local -domain system -domain user >/dev/null 2>&1 || true

# Flush the preferences cache FIRST so the apps below re-read fresh values from
# disk instead of writing their stale in-memory copies back over our changes.
killall cfprefsd       >/dev/null 2>&1 || true

killall Finder         >/dev/null 2>&1 || true
killall Dock           >/dev/null 2>&1 || true
killall SystemUIServer >/dev/null 2>&1 || true

# Finder/Dock relaunch automatically; nudge Finder in case it does not.
open -a Finder >/dev/null 2>&1 || true
