#!/usr/bin/env bash
# ============================================
# Pre-bootstrap hook
# Runs before bootstrap.sh main execution
# Note: bootstrap.sh already prints "==> Running pre-bootstrap hook"
#       before calling this script — do NOT repeat that echo here.
# ============================================

set -euo pipefail

# Example: Check for required tools
# if ! command -v git >/dev/null 2>&1; then
#   echo "ERROR: git is required but not installed"
#   exit 1
# fi

# Example: Check disk space
# AVAILABLE=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//')
# if (( $(echo "$AVAILABLE < 10" | bc -l) )); then
#   echo "WARNING: Less than 10GB free disk space"
# fi

# Example: Verify internet connection
# if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
#   echo "ERROR: No internet connection detected"
#   exit 1
# fi

echo "✓ Pre-bootstrap checks complete"
