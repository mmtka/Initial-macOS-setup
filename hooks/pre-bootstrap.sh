#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Pre-bootstrap hook
# Runs BEFORE bootstrap.sh main execution.
# bootstrap.sh already prints the step header — do NOT echo it again here.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

echo "  Checking prerequisites…"

# ── Internet connectivity ────────────────────────────────────────────────────
echo "  → Verifying internet connection…"
if ! curl -fsSL --max-time 5 https://github.com >/dev/null 2>&1; then
  echo "ERROR: No internet connection (github.com unreachable)"
  exit 1
fi
echo "  ✓ Internet OK"

# ── Disk space (require ≥ 10 GB free) ───────────────────────────────────────
echo "  → Checking free disk space…"
FREE_GB=$(df -g / 2>/dev/null | awk 'NR==2 {print $4}')
if [[ -n "${FREE_GB}" ]] && (( FREE_GB < 10 )); then
  echo "WARNING: Less than 10 GB free on / (${FREE_GB} GB). Continuing anyway."
else
  echo "  ✓ Disk space OK (${FREE_GB:-?} GB free)"
fi

# ── Refuse to run as root ────────────────────────────────────────────────────
if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  echo "ERROR: Do not run this script as root (sudo). Run as your normal user."
  exit 1
fi
echo "  ✓ Running as normal user ($(whoami))"

echo "✓ Pre-bootstrap checks complete"
