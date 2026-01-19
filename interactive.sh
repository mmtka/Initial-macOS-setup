#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_BREWFILE="${REPO_DIR}/Brewfile.interactive"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔═══════════════════════════════════════════════════╗"
echo -e "║     Interactive Package Selector               ║"
echo -e "╚═══════════════════════════════════════════════════╝${NC}\n"

ask() {
  local prompt="$1"
  local default="${2:-y}"
  [[ "$default" == "y" ]] && prompt="${prompt} [Y/n]: " || prompt="${prompt} [y/N]: "
  while true; do
    read -p "$prompt" answer
    answer=${answer:-$default}
    case $answer in
      [Yy]*) return 0;;
      [Nn]*) return 1;;
      *) echo "Please answer yes or no.";;
    esac
  done
}

select_multiple() {
  local title="$1"
  shift
  local -a options=("$@")
  echo -e "\n${CYAN}=== ${title} ===${NC}"
  echo "Enter numbers (e.g., 1 3 5) or 'all':"
  for i in "${!options[@]}"; do
    echo "  $((i+1)). ${options[$i]}"
  done
  read -p "Your choice: " choices
  [[ "$choices" == "all" ]] && printf '%s\n' "${options[@]}" && return
  for choice in $choices; do
    [[ $choice =~ ^[0-9]+$ ]] && [ $choice -ge 1 ] && [ $choice -le ${#options[@]} ] && echo "${options[$((choice-1))]}"
  done
}

# Initialize Brewfile
cat > "${TEMP_BREWFILE}" <<'EOF'
# Interactive Brewfile - Generated
tap "homebrew/bundle"
tap "homebrew/cask-fonts"
EOF

add() { echo "$1" >> "${TEMP_BREWFILE}"; }

# ESSENTIAL
echo -e "${GREEN}━━━ ESSENTIAL TOOLS ━━━${NC}"
if ask "Install essential CLI tools?"; then
  add 'brew "bash"'
  add 'brew "curl"'
  add 'brew "wget"'
  add 'brew "tree"'
  add 'brew "htop"'
fi
ask "Install dockutil?" && add 'brew "dockutil"'
ask "Install mas (App Store CLI)?" && add 'brew "mas"'

# DEVELOPMENT
echo -e "\n${GREEN}━━━ DEVELOPMENT ━━━${NC}"
if ask "Do you need development tools?"; then
  ask "  Python 3.13?" && add 'brew "python@3.13"'
  ask "  Git?" && add 'brew "git"'
  
  dev_apps=($(select_multiple "Dev Apps" "VSCode" "PyCharm" "OrbStack" "Warp" "Termius"))
  for app in "${dev_apps[@]}"; do
    case "$app" in
      "VSCode") add 'cask "visual-studio-code"';;
      "PyCharm") add 'cask "pycharm"';;
      "OrbStack") add 'cask "orbstack"';;
      "Warp") add 'cask "warp"';;
      "Termius") add 'cask "termius"';;
    esac
  done
fi

# BROWSERS
echo -e "\n${GREEN}━━━ BROWSERS ━━━${NC}"
browsers=($(select_multiple "Browsers" "Brave" "Firefox" "Chrome"))
for b in "${browsers[@]}"; do
  case "$b" in
    "Brave") add 'cask "brave-browser"';;
    "Firefox") add 'cask "firefox"';;
    "Chrome") add 'cask "google-chrome"';;
  esac
done

# SECURITY
echo -e "\n${GREEN}━━━ SECURITY ━━━${NC}"
ask "Install 1Password?" && add 'cask "1password"'
ask "Install ProtonVPN?" && add 'cask "protonvpn"'
ask "Install Lulu (firewall)?" && add 'cask "lulu"'

# PRODUCTIVITY
echo -e "\n${GREEN}━━━ PRODUCTIVITY ━━━${NC}"
ask "Install Obsidian?" && add 'cask "obsidian"'
ask "Install Microsoft Office?" "n" && {
  add 'cask "microsoft-word"'
  add 'cask "microsoft-excel"'
  add 'cask "microsoft-powerpoint"'
}

# SUMMARY
clear
echo -e "${CYAN}━━━ SUMMARY ━━━${NC}\n"
cat "${TEMP_BREWFILE}"
echo -e "\nPackages: $(grep -c '^brew\|^cask\|^mas' "${TEMP_BREWFILE}")"

if ask "\n${GREEN}Proceed with installation?${NC}"; then
  [[ -f "${REPO_DIR}/Brewfile" ]] && cp "${REPO_DIR}/Brewfile" "${REPO_DIR}/Brewfile.backup-$(date +%Y%m%d-%H%M%S)"
  export BREWFILE="${TEMP_BREWFILE}"
  "${REPO_DIR}/bootstrap.sh"
else
  echo -e "\n${YELLOW}Saved to: ${TEMP_BREWFILE}${NC}"
  echo "To install: brew bundle --file ${TEMP_BREWFILE}"
fi
