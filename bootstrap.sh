cd /Users/martin/Documents/GitHub/Initial-macOS-Setup

cat > bootstrap.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="${REPO_DIR}/Brewfile"

echo "==> 0) Rosetta (Apple Silicon only)"
ARCH="$(uname -m)"
if [[ "${ARCH}" == "arm64" ]]; then
  # Install Rosetta silently if not installed
  /usr/bin/pgrep oahd >/dev/null 2>&1 || /usr/sbin/softwareupdate --install-rosetta --agree-to-license || true
fi

echo "==> 1) Xcode Command Line Tools (if needed)"
xcode-select -p >/dev/null 2>&1 || xcode-select --install || true

echo "==> 2) Homebrew (if needed)"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew in PATH for Apple Silicon
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "==> 3) Minimal zsh init"
ZPROFILE="${HOME}/.zprofile"
ZSHRC="${HOME}/.zshrc"

# Ensure .zprofile exists and contains brew shellenv exactly once
if [[ ! -f "${ZPROFILE}" ]]; then
  cat > "${ZPROFILE}" <<'ZP'
# ~/.zprofile
# Login shell config (runs once per login)

# Homebrew (Apple Silicon)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
ZP
else
  # Add brew shellenv if missing
  grep -q '/opt/homebrew/bin/brew shellenv' "${ZPROFILE}" || cat >> "${ZPROFILE}" <<'ZP_ADD'

# Homebrew (Apple Silicon)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
ZP_ADD
fi

# Ensure .zshrc exists with minimal sane defaults
if [[ ! -f "${ZSHRC}" ]]; then
  cat > "${ZSHRC}" <<'ZR'
# ~/.zshrc
# Interactive shell config

# De-duplicate PATH entries (prevents PATH bloat)
typeset -U path PATH

# History
HISTFILE=~/.zsh_history
HISTSIZE=20000
SAVEHIST=20000
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# Completion
autoload -Uz compinit
compinit -u

# Prompt (minimal)
autoload -Uz colors && colors
PROMPT='%F{cyan}%n@%m%f:%F{yellow}%~%f %# '

# Useful aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -lah'
ZR
else
  # Ensure PATH de-duplication is present
  grep -q '^typeset -U path PATH$' "${ZSHRC}" || printf '\n# De-duplicate PATH entries\ntypeset -U path PATH\n' >> "${ZSHRC}"

  # Ensure compinit exists (minimal)
  grep -q 'compinit' "${ZSHRC}" || cat >> "${ZSHRC}" <<'ZR_ADD'

# Completion
autoload -Uz compinit
compinit -u
ZR_ADD
fi

echo "==> 4) MAS (Mac App Store) login check"

echo "==> MAS (Mac App Store) login check"

# Ensure mas is available early
if ! command -v mas >/dev/null 2>&1; then
  echo "==> Installing 'mas' first (required for App Store apps)"
  brew install mas
fi

check_mas_login() {
  mas account >/dev/null 2>&1
}

if ! check_mas_login; then
  echo
  echo "MAS is NOT signed in. Choose:"
  echo "  1) Sign in now (recommended) - open App Store and wait"
  echo "  2) Skip MAS apps - continue without App Store installs"
  echo "  3) Abort"
  echo

  while true; do
    read -r -p "Select [1/2/3]: " choice
    case "${choice}" in
      1)
        echo
        echo "Opening App Store…"
        echo "Sign in (Account -> Sign In), then come back here."
        open -a "App Store" || true

        while ! check_mas_login; do
          read -r -p "Press Enter AFTER you have signed in… " _
        done

        echo "==> MAS signed in as: $(mas account)"
        export MAS_READY=1
        break
        ;;
      2)
        echo "==> Skipping MAS installs for this run."
        export MAS_READY=0
        break
        ;;
      3)
        echo "Aborted."
        exit 1
        ;;
      *)
        echo "Invalid choice. Please enter 1, 2, or 3."
        ;;
    esac
  done
else
  echo "==> MAS already signed in as: $(mas account)"
  export MAS_READY=1
fi


echo "==> 5) Install from Brewfile (brew bundle)"
brew update
brew bundle --file "${BREWFILE}"

if [[ "${MAS_READY:-1}" == "0" ]]; then
  echo "==> MAS was skipped. If you sign in later, run: brew bundle"
fi

echo "==> 6) macOS defaults (safe)"
bash "${REPO_DIR}/defaults/defaults.safe.sh"

echo "==> 7) macOS defaults (power) - requires sudo"
bash "${REPO_DIR}/defaults/defaults.power.sh"

echo "==> 8) Dock layout (dockutil) - best effort"
bash "${REPO_DIR}/dock/layout.sh" || true

echo "==> 9) Apply changes"
bash "${REPO_DIR}/defaults/apply.sh"

echo
echo "==> DONE"
echo "Notes:"
echo "- MAS installs require you to be signed into App Store."
echo "- Some security changes may require logout/reboot on newer macOS."
echo "- New zsh settings apply to new terminals; run: exec zsh"
EOF

chmod +x bootstrap.sh
