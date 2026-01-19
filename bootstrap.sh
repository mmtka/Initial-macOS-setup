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

echo "==> 4) Install from Brewfile (brew bundle)"
brew update
brew bundle --file "${BREWFILE}"

echo "==> 5) macOS defaults (safe)"
bash "${REPO_DIR}/defaults/defaults.safe.sh"

echo "==> 6) macOS defaults (power) - requires sudo"
bash "${REPO_DIR}/defaults/defaults.power.sh"

echo "==> 7) Dock layout (dockutil) - best effort"
bash "${REPO_DIR}/dock/layout.sh" || true

echo "==> 8) Apply changes"
bash "${REPO_DIR}/defaults/apply.sh"

echo
echo "==> DONE"
echo "Notes:"
echo "- MAS installs require you to be signed into App Store."
echo "- Some security changes may require logout/reboot on newer macOS."
echo "- New zsh settings apply to new terminals; run: exec zsh"
EOF

chmod +x bootstrap.sh
