# ============================================
# Martin – macOS setup (Homebrew Bundle)
# Source of truth: Brewfile
# Install:  brew bundle --file Brewfile
# Cleanup:  brew bundle cleanup --file Brewfile
# ============================================

# ---------- TAPS ----------
tap "homebrew/bundle"
tap "homebrew/cask-fonts"
tap "roshie548/tap"
tap "slp/krun"
tap "vitorgalvao/tiny-scripts"


# ============================================
# CLI / BASIC
# ============================================
brew "bash"
brew "curl"
brew "wget"
brew "tree"

brew "python@3.13"
brew "bpython"

brew "btop"
brew "bandwhich"
brew "dua-cli"
brew "dust"
brew "midnight-commander"
brew "duf"  # better df

brew "dockutil"
brew "m-cli"

brew "ripgrep"
# brew "cronboard"  # neexistuje v homebrew/core – skontrolovať manuálne
brew "rsync"

brew "speedtest-cli"

# Utilities / helpers
brew "ossp-uuid"
brew "parallel"
brew "pandoc"
brew "imagemagick"
brew "ffmpeg"
brew "bzip2"

# Battery
# cask "srimanachanta/tap/stasis"  # tap neexistuje, skontrolovať

# Bundle helpers
brew "mas"
brew "vitorgalvao/tiny-scripts/cask-repair"

# Proxmox helper
brew "roshie548/tap/proxmux"

# NTFS for MacOS
cask "tuxera-ntfs"


# ============================================
# NETWORK / SECURITY (CLI)
# ============================================
brew "nmap"
brew "mtr"
brew "gping"
brew "cfssl"
# cask "rana-gmbh/netfluss/netfluss"  # tap/cask neoverený – skontrolovať manuálne
# VPN Bypass start
tap "geiserx/vpn-bypass"
cask "vpn-bypass"
# VPN Bypass end
brew "wakeonlan"
# cask "jasine/tap/netmounter"  # neoverený tap – skontrolovať manuálne

# tcptracerout → tento riadok bol bez brew/cask/mas prefixu (čistý Ruby token) → crash
# Ak ho chceš: brew install tcptraceroute (píše sa s e na konci)
# brew "tcptraceroute"


# ============================================
# MEDIA (CLI + GUI)
# ============================================
brew "mkvtoolnix"
cask "iina"
cask "vlc"
cask "spotify"
cask "plex"
cask "plexamp"
cask "jellyfin-media-player"
cask "mkvtoolnix-app"
cask "audacity"
# cask "mediainfoex"  # neexistuje v cask – použiť cask "mediainfo" namiesto toho
cask "mediainfo"
cask "tinymediamanager"
# cask "finetune"  # nenájdené v homebrew cask
brew "yt-dlp"


# ============================================
# SMART HOME
# ============================================
# cask "nickustinov/tap/itsytv"  # neoverený tap – skontrolovať manuálne
cask "home-assistant"


# ============================================
# CLEANING / MAINTENANCE
# ============================================
cask "onyx"
cask "pearcleaner"
# cask "cleanupbuddy"  # nenájdené v homebrew cask
cask "daisydisk"
# brew "mole"  # nenájdené v homebrew/core
brew "mac-cleanup-go"  # system cleaner


# ============================================
# WORK WITH FILES / TERMINAL / SYNC
# ============================================
# cask "warp"    # zakomentované – prípadne odkomentovať
# cask "termius" # zakomentované – prípadne odkomentovať
cask "tabby"
cask "cloudmounter"
cask "keka"
cask "nextcloud"
cask "syncthing"
# cask "nextcloud-vfs"  # nenájdené v homebrew cask – používa sa len v Enterprise kontexte
# cask "syncthing-app"  # duplicita – syncthing vyššie, toto nie je štandardný cask
cask "transmission"


# ============================================
# DESKTOP ENHANCEMENT
# ============================================
cask "alt-tab"
cask "default-folder-x"
# cask "domzilla-caffeine"  # nenájdené – použi cask "caffeine" alebo cask "lungo"
cask "lungo"  # caffeine alternatíva, dostupná v cask
# cask "magicquit"  # nenájdené v homebrew cask – skontrolovať
cask "rcmd"  # window/app switcher; alebo odkomentovať magicquit ak ho nájdeš
# cask "last-window-quits"  # nenájdené v homebrew cask
cask "itsycal"  # menu bar calendar
# cask "thaw"  # nenájdené v homebrew cask
cask "ice"     # menu bar management (ICE by Jordan Baird – originál)
# cask "monuk7735/tap/mew-notch"  # neoverený tap
# cask "launchie"  # nenájdené v homebrew cask


# ============================================
# SECURITY / PRIVACY
# ============================================
cask "1password"
cask "bitwarden"
# cask "sentinel"  # nenájdené v homebrew cask – skontrolovať
cask "protonvpn"
cask "lulu"
brew "certbot"


# ============================================
# TOOLS
# ============================================
# cask "mist"  # nenájdené v homebrew cask – použi cask "mist-cli" ak existuje, inak manuálne
cask "balenaetcher"
cask "deepl"
cask "drawio"
cask "espanso"
cask "ganttproject"
cask "openvisualtraceroute"
# cask "keyclu"  # nenájdené v homebrew cask – skontrolovať
cask "rsyncui"  # SwiftUI GUI for rsync

# macOS / FS
cask "macfuse"

# Docker / virtualization
cask "orbstack"

# Wireshark
cask "wireshark"
# cask "wireshark-app"  # duplicita / neplatný cask name – wireshark vyššie stačí

# Adobe (heavy)
cask "adobe-creative-cloud"

# Fonts
cask "font-ubuntu-sans"
cask "font-ubuntu-sans-mono"
cask "font-work-sans"


# ============================================
# BROWSERS
# ============================================
cask "firefox"
cask "brave-browser"


# ============================================
# OFFICE / PRODUCTIVITY
# ============================================
cask "obsidian"
cask "onlyoffice"
cask "anki"

# Microsoft Office
cask "microsoft-auto-update"
cask "microsoft-office"
cask "microsoft-word"
cask "microsoft-excel"
cask "microsoft-powerpoint"

# Mail
cask "readdle-spark"

# Tax
cask "wiso-steuer-2025"
cask "wiso-steuer-2026"


# ============================================
# DEV TOOLS
# ============================================
cask "visual-studio-code"
# cask "vscodium"  # open-source alternatíva
cask "openinterminal"
cask "imazing-profile-editor"
cask "pycharm"
cask "github"


# ============================================
# QUICKLOOK / INSPECTION
# ============================================
cask "qlcolorcode"
cask "apparency"
cask "suspicious-package"
cask "glance-chamburr"  # All-in-one Quick Look plugin


# ============================================
# TeX
# ============================================
cask "basictex"
cask "texshop"


# ============================================
# MAS (App Store)
# ============================================

# Social
mas "Telegram", id: 747648890
mas "WhatsApp", id: 310633997

# Safari extensions / web
mas "1Password for Safari", id: 1569813296
mas "Tampermonkey Classic", id: 1482490089
mas "Obsidian Web Clipper", id: 6720708363

# Geocaching
mas "Raccoon - Geocaching Tool", id: 424398764
mas "iCaching", id: 420484346

# Utilities / work
mas "Actions", id: 1586435171
mas "Magnet", id: 441258766
mas "Paste Plain Text", id: 1407015686
mas "OwlOCR", id: 6462355119
mas "Paprika Recipe Manager 3", id: 1303222628
mas "finanzblick", id: 993109868
mas "WireGuard", id: 1451685025
mas "Home Assistant", id: 1099568401
mas "Keepa - Price Tracker", id: 1533805339

# Apple iWork
mas "Pages", id: 409201541
mas "Numbers", id: 409203825
mas "Keynote", id: 409183694


# ============================================
# VS CODE EXTENSIONS
# ============================================
vscode "danielpinto8zz6.c-cpp-compile-run"
vscode "davidbwaters.macos-modern-theme"
vscode "dbaeumer.vscode-eslint"
vscode "dzhavat.css-flexbox-cheatsheet"
vscode "ecmel.vscode-html-css"
vscode "editorconfig.editorconfig"
vscode "golang.go"
vscode "ms-azuretools.vscode-containers"
vscode "ms-python.debugpy"
vscode "ms-python.python"
vscode "ms-python.vscode-pylance"
vscode "ms-python.vscode-python-envs"
vscode "ms-vscode-remote.remote-containers"
vscode "ms-vscode.cmake-tools"
vscode "ms-vscode.cpp-devtools"
vscode "ms-vscode.cpptools"
vscode "ms-vscode.cpptools-extension-pack"
vscode "ms-vscode.cpptools-themes"
vscode "openai.chatgpt"
vscode "parallelsdesktop.parallels-desktop"
vscode "pawelborkar.jellyfish"
vscode "pdconsec.vscode-print"
vscode "pinegrow.piny"
vscode "ritwickdey.liveserver"
vscode "sidthesloth.html5-boilerplate"
vscode "wayou.vscode-todo-highlight"
vscode "xdebug.php-debug"
vscode "yutengjing.vscode-archive"
vscode "zignd.html-css-class-completion"
vscode "zobo.php-intellisense"
