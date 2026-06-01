#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# tui.sh — friendly front-end for bootstrap.sh
#
# Lets you pick a Brewfile profile, toggle which steps run, and choose which
# .mobileconfig profiles to install — then hands off to bootstrap.sh with the
# choices passed as environment variables (config.sh reads them via ${VAR:-…}).
#
# Uses `gum` (https://github.com/charmbracelet/gum) for a nice UI and falls back
# to plain-bash prompts when gum / Homebrew are unavailable.
# =============================================================================

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILES_DIR="${PROFILES_DIR:-${REPO_DIR}/profiles/mobileconfig}"

# Source the profile helpers (profile_conflicts / profile_display_name / …).
# shellcheck source=lib/profiles.sh
[[ -f "${REPO_DIR}/lib/profiles.sh" ]] && source "${REPO_DIR}/lib/profiles.sh"

# -----------------------------------------------------------------------------
# gum bootstrap — install it once via Homebrew, else fall back to plain bash.
# -----------------------------------------------------------------------------
HAVE_GUM=false
ensure_gum() {
  if command -v gum >/dev/null 2>&1; then HAVE_GUM=true; return; fi
  if [[ -x /opt/homebrew/bin/brew ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
  if command -v brew >/dev/null 2>&1; then
    printf "gum (the TUI toolkit) is not installed. Install it now via Homebrew? [Y/n] "
    read -r reply </dev/tty || reply="y"
    if [[ ! "${reply}" =~ ^[Nn]$ ]]; then
      brew install gum && HAVE_GUM=true
    fi
  fi
  command -v gum >/dev/null 2>&1 && HAVE_GUM=true
}

# -----------------------------------------------------------------------------
# UI primitives — gum when available, bash otherwise.
# -----------------------------------------------------------------------------
ui_header() {
  if ${HAVE_GUM}; then
    gum style --border double --margin "1 0" --padding "1 3" --border-foreground 212 \
      "$@"
  else
    echo; printf '=%.0s' {1..60}; echo
    printf '  %s\n' "$@"
    printf '=%.0s' {1..60}; echo; echo
  fi
}

ui_info() { ${HAVE_GUM} && gum style --foreground 244 "$*" || echo "  $*"; }

# ui_confirm "question"  → returns 0 for yes, 1 for no
ui_confirm() {
  if ${HAVE_GUM}; then
    gum confirm "$1"
  else
    printf "%s [y/N] " "$1"; read -r r </dev/tty || r="n"
    [[ "${r}" =~ ^[Yy]$ ]]
  fi
}

# ui_choose_one "header" opt1 opt2 …  → prints selection
ui_choose_one() {
  local header="$1"; shift
  if ${HAVE_GUM}; then
    gum choose --header "${header}" "$@"
  else
    echo "${header}" >&2
    select opt in "$@"; do [[ -n "${opt}" ]] && { echo "${opt}"; break; }; done </dev/tty
  fi
}

# ui_choose_multi "header" "preselected_csv" opt1 opt2 …  → prints chosen (newline)
ui_choose_multi() {
  local header="$1" preselected="$2"; shift 2
  if ${HAVE_GUM}; then
    gum choose --no-limit --header "${header}" --selected "${preselected}" "$@"
  else
    echo "${header} (enter numbers separated by space, e.g. '1 3 4')" >&2
    local i=1 opt
    for opt in "$@"; do echo "  ${i}) ${opt}" >&2; i=$((i + 1)); done
    local picks; read -r picks </dev/tty
    local n
    for n in ${picks}; do eval "echo \"\${$((n))}\""; done
  fi
}

# =============================================================================
ensure_gum
ui_header "Initial macOS Setup" "Interactive installer"

# -----------------------------------------------------------------------------
# 1) Brewfile profile
# -----------------------------------------------------------------------------
BREWFILE="${REPO_DIR}/Brewfile"
brew_choices=("Full  — everything in Brewfile")
[[ -f "${REPO_DIR}/profiles/minimal.Brewfile" ]] && brew_choices+=("Minimal — essentials only")
[[ -f "${REPO_DIR}/profiles/work.Brewfile" ]]    && brew_choices+=("Work — development setup")
brew_pick="$(ui_choose_one "Which package set should brew install?" "${brew_choices[@]}")"
case "${brew_pick}" in
  Minimal*) BREWFILE="${REPO_DIR}/profiles/minimal.Brewfile" ;;
  Work*)    BREWFILE="${REPO_DIR}/profiles/work.Brewfile" ;;
  *)        BREWFILE="${REPO_DIR}/Brewfile" ;;
esac
ui_info "Brewfile: ${BREWFILE}"

# -----------------------------------------------------------------------------
# 2) Which steps to run
# -----------------------------------------------------------------------------
# NOTE: labels must NOT contain commas — gum's --selected list is comma-separated.
STEP_HB="Homebrew bundle (install apps)"
STEP_SAFE="Safe macOS defaults (Finder / input / screenshots)"
STEP_POWER="Power defaults — sudo: firewall / power / timezone"
STEP_DOCK="Dock layout"
STEP_TID="Touch ID for sudo"
STEP_BK="Backup current settings first"
STEP_PROF="Install configuration profiles (.mobileconfig)"
STEP_RMCONF="Remove conflicting profiles (so defaults write applies)"

STEPS=()
while IFS= read -r _line; do [[ -n "${_line}" ]] && STEPS+=("${_line}"); done < <(
  ui_choose_multi "Select steps to run (space to toggle, enter to confirm)" \
    "${STEP_HB},${STEP_SAFE},${STEP_POWER},${STEP_DOCK},${STEP_TID},${STEP_BK},${STEP_PROF},${STEP_RMCONF}" \
    "${STEP_HB}" "${STEP_SAFE}" "${STEP_POWER}" "${STEP_DOCK}" "${STEP_TID}" "${STEP_BK}" "${STEP_PROF}" "${STEP_RMCONF}")

# Export VAR=true when the matching step was selected, false otherwise.
# (Split declare/assign so the subshell exit status doesn't mask `export`.)
set_flag() {
  local value="false"
  printf '%s\n' ${STEPS[@]+"${STEPS[@]}"} | grep -qxF "$2" && value="true"
  export "$1=${value}"
}

set_flag ENABLE_HOMEBREW             "${STEP_HB}"
set_flag ENABLE_DEFAULTS_SAFE        "${STEP_SAFE}"
set_flag ENABLE_POWER_DEFAULTS       "${STEP_POWER}"
set_flag ENABLE_DOCK_LAYOUT          "${STEP_DOCK}"
set_flag ENABLE_TOUCHID_SUDO         "${STEP_TID}"
set_flag CREATE_BACKUP               "${STEP_BK}"
set_flag ENABLE_PROFILES             "${STEP_PROF}"
set_flag REMOVE_CONFLICTING_PROFILES "${STEP_RMCONF}"

# -----------------------------------------------------------------------------
# 3) Configuration profiles (.mobileconfig)
# -----------------------------------------------------------------------------
if [[ "${ENABLE_PROFILES}" == "true" ]] && command -v discover_profiles >/dev/null 2>&1; then
  installable=(); conflicting=()
  while IFS= read -r f; do
    [[ -n "${f}" ]] || continue
    if profile_conflicts "${f}"; then conflicting+=("${f}"); else installable+=("${f}"); fi
  done < <(discover_profiles "${PROFILES_DIR}")

  if [[ "${#conflicting[@]}" -gt 0 ]]; then
    ui_info "These profiles manage domains your scripts own — they will NOT be installed"
    ui_info "(scripts win). If '${STEP_RMCONF}' is on, their installed copies are removed:"
    for f in "${conflicting[@]}"; do ui_info "   ⚠ $(profile_display_name "${f}")  [$(profile_domains "${f}" | paste -sd ',' -)]"; done
  fi

  if [[ "${#installable[@]}" -gt 0 ]]; then
    names=(); for f in "${installable[@]}"; do names+=("$(profile_display_name "${f}")"); done
    preselected="$(printf '%s,' "${names[@]}")"; preselected="${preselected%,}"
    chosen=()
    while IFS= read -r _line; do [[ -n "${_line}" ]] && chosen+=("${_line}"); done < <(
      ui_choose_multi "Which profiles to install? (each opens for approval)" \
        "${preselected}" "${names[@]}")
    SELECTED_PROFILES=""
    for f in "${installable[@]}"; do
      dn="$(profile_display_name "${f}")"
      printf '%s\n' ${chosen[@]+"${chosen[@]}"} | grep -qxF "${dn}" && SELECTED_PROFILES+="${f}"$'\n'
    done
    export SELECTED_PROFILES
  else
    ui_info "No installable (non-conflicting) profiles found in ${PROFILES_DIR}"
  fi
fi

# -----------------------------------------------------------------------------
# 4) Summary + confirm
# -----------------------------------------------------------------------------
ui_header "Ready to run" \
  "Brewfile:        $(basename "${BREWFILE}")" \
  "Homebrew:        ${ENABLE_HOMEBREW}" \
  "Safe defaults:   ${ENABLE_DEFAULTS_SAFE}" \
  "Power defaults:  ${ENABLE_POWER_DEFAULTS}" \
  "Dock layout:     ${ENABLE_DOCK_LAYOUT}" \
  "Touch ID sudo:   ${ENABLE_TOUCHID_SUDO}" \
  "Backup:          ${CREATE_BACKUP}" \
  "Install profiles:${ENABLE_PROFILES}" \
  "Remove conflicts:${REMOVE_CONFLICTING_PROFILES}"

if ui_confirm "Start the setup now?"; then
  export BREWFILE
  exec "${REPO_DIR}/bootstrap.sh"
else
  ui_info "Aborted. Nothing was changed."
  exit 0
fi
