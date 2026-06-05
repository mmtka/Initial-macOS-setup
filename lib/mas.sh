#!/usr/bin/env bash
# ============================================
# Reliable Mac App Store (mas) installation
# ============================================
# Background:
#  - mas 7.x removed the `account` and `signin` subcommands (Apple dropped the
#    underlying private API), so there is no reliable CLI way to query sign-in
#    state or to sign in from the terminal. The user must sign in once via the
#    App Store app.
#  - `brew bundle` does install `mas` entries, but a single failure only yields a
#    generic warning. This library installs each App Store app individually,
#    idempotently, continues past failures, and prints a clear per-app report.
#
# It parses the `mas "...", id: NNN` lines straight from the Brewfile, so the
# Brewfile stays the single source of truth.

_MAS_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAS_REPO_DIR="${MAS_REPO_DIR:-$(cd "${_MAS_LIB_DIR}/.." && pwd)}"

# Open the App Store and (in an interactive shell) wait for the user to sign in.
# mas cannot sign in itself, so this is the only reliable path.
mas_ensure_signed_in() {
  command -v mas >/dev/null 2>&1 || { echo "⚠ mas not installed"; return 1; }
  echo "ℹ App Store apps can only install while you are signed in."
  open -a "App Store" >/dev/null 2>&1 || true
  if [[ -r /dev/tty ]]; then
    printf "  → Sign into the App Store, then press Enter to continue (Ctrl-C to abort)... "
    read -r _ </dev/tty || true
  else
    echo "  (non-interactive run; make sure you are already signed in)"
  fi
  return 0
}

# Echo "id<TAB>name" for every mas entry in the Brewfile.
_mas_entries() {
  local brewfile="${1:-${MAS_REPO_DIR}/Brewfile}"
  [[ -f "${brewfile}" ]] || return 0
  # Lines look like:  mas "WhatsApp", id: 310633997
  grep -E '^[[:space:]]*mas[[:space:]]' "${brewfile}" \
    | sed -E 's/^[[:space:]]*mas[[:space:]]+"([^"]+)".*id:[[:space:]]*([0-9]+).*/\2\t\1/'
}

# Install every mas app from the Brewfile, idempotently, continuing on error.
# Returns non-zero if any app failed (so callers can warn), but never aborts.
mas_install_from_brewfile() {
  local brewfile="${1:-${MAS_REPO_DIR}/Brewfile}"

  if ! command -v mas >/dev/null 2>&1; then
    echo "⚠ mas not installed; skipping App Store apps"
    return 0
  fi

  local installed_ids
  installed_ids="$(mas list 2>/dev/null | awk '{print $1}')"

  local ok=0 skip=0 fail=0
  local failed=()
  local id name

  while IFS=$'\t' read -r id name; do
    [[ -z "${id}" ]] && continue
    if grep -qx "${id}" <<<"${installed_ids}"; then
      echo "  ✓ already installed: ${name} (${id})"
      skip=$((skip + 1))
      continue
    fi
    echo "  → installing: ${name} (${id})"
    if mas install "${id}"; then
      ok=$((ok + 1))
    else
      echo "    ⚠ FAILED: ${name} (${id})"
      failed+=("${name} (${id})")
      fail=$((fail + 1))
    fi
  done < <(_mas_entries "${brewfile}")

  echo
  echo "MAS summary: ${ok} installed, ${skip} already present, ${fail} failed"
  if (( fail > 0 )); then
    echo "Failed apps:"
    printf '  - %s\n' "${failed[@]}"
    echo "Common causes: not signed into the App Store, or the app was never"
    echo "obtained on this Apple ID (paid apps must be purchased once first;"
    echo "mas cannot purchase apps for you)."
    return 1
  fi
  return 0
}
