#!/usr/bin/env bash
# ============================================
# Configuration profile (.mobileconfig) helpers
#
# macOS 26 removed `profiles install`: profiles can ONLY be installed by opening
# them and approving in System Settings (no silent CLI install without MDM).
# `profiles remove` still works with sudo, which we use to clear profiles that
# would otherwise override our shell-script settings (managed preferences always
# beat `defaults write`).
# ============================================

# Preference domains our scripts manage. A managed profile for any of these
# silently overrides `defaults write`, so we detect (and remove) them.
#
# NOTE: com.apple.systempolicy.control (Gatekeeper) and com.apple.SoftwareUpdate
# are deliberately NOT listed. On macOS 26 (Tahoe) `spctl --master-disable` was
# removed, so disabling Gatekeeper assessment is ONLY possible via a profile.
# gatekeeper.mobileconfig therefore OWNS those domains — it is installed and kept,
# not treated as a conflict. (Gatekeeper is the one profile-wins exception.)
CONFLICT_DOMAINS=(
  "com.apple.finder"
  "com.apple.dock"
  "com.apple.Safari"
  ".GlobalPreferences"
)

# Print managed-preference domains that conflict with our scripts (one per line).
# Returns 0 if at least one conflict exists, 1 otherwise.
detect_conflicting_profiles() {
  local mp_dir="/Library/Managed Preferences/${USER}"
  local domain found=1
  for domain in "${CONFLICT_DOMAINS[@]}"; do
    if [[ -f "${mp_dir}/${domain}.plist" ]]; then
      echo "${domain}"
      found=0
    fi
  done
  return "${found}"
}

# Open the System Settings profiles pane and print manual-removal guidance.
open_profiles_settings() {
  echo "  → Open System Settings ▸ General ▸ Device Management and remove the"
  echo "    listed profile(s) manually, then re-run this step."
  open "x-apple.systempreferences:com.apple.preferences.configurationprofiles" \
    >/dev/null 2>&1 || true
}

# Print identifiers of installed configuration profiles (needs sudo).
list_config_profile_identifiers() {
  sudo profiles list -type=configuration 2>/dev/null \
    | awk -F': ' '/profileIdentifier:/ {print $NF}'
}

# Remove the installed configuration profiles that conflict with our scripts so
# `defaults write` takes effect. Best-effort CLI removal with a manual fallback.
remove_conflicting_profiles() {
  if ! detect_conflicting_profiles >/dev/null; then
    echo "✓ No conflicting configuration profiles found"
    return 0
  fi

  echo "⚠ These managed domains currently override defaults write:"
  detect_conflicting_profiles | sed 's/^/    - /'

  # Strategy 1: remove by the identifiers of conflicting profiles we ship in
  # PROFILES_DIR. The installed managed copies came from these exact files, so
  # their top-level PayloadIdentifier is the most reliable removal key.
  local f id
  while IFS= read -r f; do
    [[ -n "${f}" ]] || continue
    profile_conflicts "${f}" || continue
    id=$(profile_identifier "${f}")
    [[ -n "${id}" ]] || continue
    echo "  Removing configuration profile: ${id} ($(basename "${f}"))"
    sudo profiles remove -identifier="${id}" -forced 2>/dev/null \
      || echo "    ⚠ Could not remove ${id} via CLI"
  done <<< "$(discover_profiles "${PROFILES_DIR:-}")"

  # Strategy 2: enumerate INSTALLED profiles and remove only those that manage a
  # conflict domain. We must NOT blanket-remove every profile — that would also
  # delete the Gatekeeper profile (and any Wi-Fi/VPN profile) we intend to keep.
  local tmp_xml xml
  tmp_xml=$(mktemp -t profiles_show.XXXXXX) || tmp_xml=""
  # Capture via command substitution (not `sudo … > file`, which would redirect
  # as the current user — see SC2024), then write it to our own temp file.
  xml=$(sudo profiles show -output stdout-xml 2>/dev/null) || xml=""
  if [[ -n "${tmp_xml}" && -n "${xml}" ]] && printf '%s' "${xml}" > "${tmp_xml}"; then
    local i=0 pid j ptype c hit
    while pid=$(/usr/libexec/PlistBuddy -c "Print :_computerlevel:${i}:ProfileIdentifier" "${tmp_xml}" 2>/dev/null); do
      hit=1; j=0
      while ptype=$(/usr/libexec/PlistBuddy -c "Print :_computerlevel:${i}:ProfileItems:${j}:PayloadType" "${tmp_xml}" 2>/dev/null); do
        for c in "${CONFLICT_DOMAINS[@]}"; do
          [[ "${ptype}" == "${c}" ]] && { hit=0; break; }
        done
        [[ "${hit}" -eq 0 ]] && break
        j=$((j + 1))
      done
      if [[ "${hit}" -eq 0 ]]; then
        echo "  Removing configuration profile: ${pid}"
        sudo profiles remove -identifier="${pid}" -forced 2>/dev/null \
          || echo "    ⚠ Could not remove ${pid} via CLI"
      fi
      i=$((i + 1))
    done
  fi
  [[ -n "${tmp_xml}" ]] && rm -f "${tmp_xml}"

  if detect_conflicting_profiles >/dev/null; then
    echo "⚠ Some managed domains remain after removal:"
    detect_conflicting_profiles | sed 's/^/    - /'
    open_profiles_settings
  else
    echo "✓ Conflicting profiles removed — defaults write will now apply"
  fi
}

# Discover .mobileconfig files in a directory (one path per line).
discover_profiles() {
  local dir="$1"
  [[ -d "${dir}" ]] || return 0
  find "${dir}" -maxdepth 1 -name '*.mobileconfig' -type f 2>/dev/null | sort
}

# Print a profile's top-level PayloadIdentifier (used to remove it via the CLI).
profile_identifier() {
  /usr/libexec/PlistBuddy -c 'Print :PayloadIdentifier' "$1" 2>/dev/null
}

# Print a profile's human-readable PayloadDisplayName (falls back to the filename).
profile_display_name() {
  local name
  name=$(/usr/libexec/PlistBuddy -c 'Print :PayloadDisplayName' "$1" 2>/dev/null)
  if [[ -n "${name}" ]]; then echo "${name}"; else basename "$1"; fi
}

# Print the inner PayloadType domains a profile manages (one per line).
profile_domains() {
  local f="$1" i=0 t
  while t=$(/usr/libexec/PlistBuddy -c "Print :PayloadContent:${i}:PayloadType" "${f}" 2>/dev/null); do
    [[ -n "${t}" ]] && echo "${t}"
    i=$((i + 1))
  done
}

# Return 0 if the profile manages any domain our scripts also manage (i.e. it
# would silently override `defaults write`). Returns 1 otherwise.
profile_conflicts() {
  local f="$1" d c
  while IFS= read -r d; do
    for c in "${CONFLICT_DOMAINS[@]}"; do
      [[ "${d}" == "${c}" ]] && return 0
    done
  done < <(profile_domains "${f}")
  return 1
}

# Return 0 if every domain a profile manages already has a managed-preference
# plist on disk — a good no-sudo signal that the profile is already installed,
# so we can skip re-opening it (e.g. an already-approved gatekeeper.mobileconfig).
profile_already_installed() {
  local f="$1" d any=1
  local mp_dir="/Library/Managed Preferences/${USER}"
  while IFS= read -r d; do
    any=0
    [[ -f "${mp_dir}/${d}.plist" ]] || return 1
  done < <(profile_domains "${f}")
  return "${any}"  # 1 (false) if the profile declared no domains
}

# "Install" the given .mobileconfig files. On macOS 26 this opens each profile so
# the user can approve it in System Settings (silent install is not possible).
install_profiles() {
  local count=$#
  if [[ "${count}" -eq 0 ]]; then
    echo "ℹ No profiles selected to install"
    return 0
  fi

  echo "ℹ macOS no longer allows silent profile installation."
  echo "  Each profile opens for review; approve it in:"
  echo "  System Settings ▸ General ▸ Device Management."

  local f
  for f in "$@"; do
    [[ -f "${f}" ]] || { echo "  ⚠ Not found, skipping: ${f}"; continue; }
    # Scripts are the source of truth: never install a profile that manages a
    # domain our defaults scripts also set — macOS would let it silently win.
    if profile_conflicts "${f}"; then
      echo "  ⏭ Skipping $(basename "${f}") — conflicts with defaults scripts"
      echo "     (managed domains: $(profile_domains "${f}" | paste -sd ', ' -))"
      continue
    fi
    if profile_already_installed "${f}"; then
      echo "  ✓ Already installed, skipping: $(basename "${f}")"
      continue
    fi
    echo "  → Opening: $(basename "${f}")"
    open "${f}" >/dev/null 2>&1 || echo "    ⚠ Could not open ${f}"
    if [[ -r /dev/tty ]]; then
      printf "    Approve it in System Settings, then press Enter for the next... "
      read -r _ </dev/tty || true
    fi
  done
  echo "✓ Finished opening selected profiles"
}
