#!/usr/bin/env bash
set -euo pipefail

# Close System Settings/Preferences to avoid overrides
osascript -e 'tell application "System Settings" to quit' >/dev/null 2>&1 || true
osascript -e 'tell application "System Preferences" to quit' >/dev/null 2>&1 || true

# Ask for admin upfront
sudo -v

# Keep sudo alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Helpers
OS_VER="$(sw_vers -productVersion)"
HOSTNAME_SHORT="$(scutil --get ComputerName 2>/dev/null || true)"

echo "Applying macOS defaults on ${OS_VER} ..."

# ==============================================================================
# GENERAL
# ==============================================================================

# Disable boot sound
sudo nvram SystemAudioVolume=" " 2>/dev/null || true

# Save to disk (not iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable Gatekeeper "downloaded from internet" quarantine prompts (WARNING: security tradeoff)
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Use AirDrop over every interface
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Disable automatic smart substitutions
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Language / locale
defaults write NSGlobalDomain AppleLanguages -array "sk" "en" "cs" "de"
defaults write NSGlobalDomain AppleLocale -string "de_DE@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Timezone
sudo systemsetup -settimezone "Europe/Berlin" >/dev/null 2>&1 || true

# Hide input menu on login screen
sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool false 2>/dev/null || true

# Expand save/print panels by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Disable "natural" scrolling? (comment/uncomment)
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# ==============================================================================
# INPUT: TRACKPAD / MOUSE / KEYBOARD
# ==============================================================================

# Tap to click (user + login screen)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# 3-finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# Key repeat (faster)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for keys (enable key repeat everywhere)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Fn/🌐 key usage: 1=Show Emoji & Symbols, 2=Change Input Source, 0=Do Nothing (varies by macOS)
defaults write com.apple.HIToolbox AppleFnUsageType -int 1

# ==============================================================================
# ENERGY / POWER
# ==============================================================================

# Lid wake
sudo pmset -a lidwake 1

# Display sleep (minutes)
sudo pmset -a displaysleep 5

# No machine sleep on charger
sudo pmset -c sleep 0

# Machine sleep on battery
sudo pmset -b sleep 10

# Hibernation mode (0 disables safe sleep – tradeoff)
sudo pmset -a hibernatemode 0 || true

# ==============================================================================
# SCREENSHOTS
# ==============================================================================

# Save screenshots to ~/Screenshots
mkdir -p "${HOME}/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"

# Screenshot format: png/jpg/pdf/tiff
defaults write com.apple.screencapture type -string "png"

# Disable screenshot shadow
defaults write com.apple.screencapture disable-shadow -bool true

# ==============================================================================
# FINDER
# ==============================================================================

# Show icons on Desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Disable Finder window animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Show file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show hidden files (comment/uncomment)
# defaults write com.apple.finder AppleShowAllFiles -bool true

# Disable warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store on network/USB
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Automatically open Finder window for mounted volumes
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# New Finder windows open: Home
defaults write com.apple.finder NewWindowTarget -string "PfHm"
# defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Status & path bar
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Preferred view style: clmv (column), Nlsv (list), icnv (icon), glyv (gallery)
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Show ~/Library
chflags nohidden "${HOME}/Library" || true

# Create ~/Sites
mkdir -p "${HOME}/Sites"

# Finder icon view settings (guarded – plist keys may not exist on fresh systems)
FPLIST="${HOME}/Library/Preferences/com.apple.finder.plist"
if [[ -f "${FPLIST}" ]]; then
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 64" "${FPLIST}" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 64" "${FPLIST}" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 64" "${FPLIST}" 2>/dev/null || true

  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 48" "${FPLIST}" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 48" "${FPLIST}" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 48" "${FPLIST}" 2>/dev/null || true
fi

# ==============================================================================
# DOCK / MISSION CONTROL
# ==============================================================================

# Dock icon size
defaults write com.apple.dock tilesize -int 32

# Minimize into application icon
defaults write com.apple.dock minimize-to-application -bool true

# Don’t show recent applications
defaults write com.apple.dock show-recents -bool false

# Disable automatic rearrangement of Spaces
defaults write com.apple.dock mru-spaces -bool false

# Hot corners (example: top-left = Mission Control)
# Possible values: 0=disabled, 2=Mission Control, 4=Desktop, 5=Start Screen Saver, 10=Put Display to Sleep
# defaults write com.apple.dock wvous-tl-corner -int 2
# defaults write com.apple.dock wvous-tl-modifier -int 0

# IMPORTANT: wiping Dock icons via defaults is fragile. Prefer dockutil in bootstrap if needed.
# (Your old line `persistent-apps -array true` was wrong syntax.) :contentReference[oaicite:1]{index=1}

# ==============================================================================
# SAFARI (optional – comment out if you don't want it)
# ==============================================================================

# Show full URL in address bar
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Enable Develop menu
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# ==============================================================================
# ACTIVITY MONITOR (nice defaults)
# ==============================================================================

# Show CPU usage in Dock icon (0=none, 2=CPU)
defaults write com.apple.ActivityMonitor IconType -int 2

# Show main window when launching
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# ==============================================================================
# TERMINAL
# ==============================================================================

# Default Terminal profile (if you have a profile named "Brew")
defaults write com.apple.terminal "Default Window Settings" -string "Brew" 2>/dev/null || true
defaults write com.apple.terminal "Startup Window Settings" -string "Brew" 2>/dev/null || true

# ==============================================================================
# NETWORK
# ==============================================================================

# Set DNS servers for Wi-Fi (Cloudflare + Google fallback)
# NOTE: interface name differs on some systems. If Wi-Fi isn't correct, change it.
networksetup -setdnsservers "Wi-Fi" 1.1.1.1 1.0.0.1 8.8.8.8 2>/dev/null || true

# ==============================================================================
# TIME MACHINE (optional)
# ==============================================================================

# Don’t offer new disks for backup
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# ==============================================================================
# SECURITY (optional)
# ==============================================================================

# Enable firewall (may require UI confirmation in newer macOS; still safe)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on >/dev/null 2>&1 || true
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on >/dev/null 2>&1 || true

# ==============================================================================
# APPLE INTELLIGENCE / CLOUD FEATURES (your existing setting kept)
# ==============================================================================
defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool false 2>/dev/null || true

# ==============================================================================
# APPLY CHANGES
# ==============================================================================

# Rebuild LaunchServices "Open With" menu
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -kill -r -domain local -domain system -domain user >/dev/null 2>&1 || true

# Restart affected apps/services
killall Finder >/dev/null 2>&1 || true
killall Dock >/dev/null 2>&1 || true
killall SystemUIServer >/dev/null 2>&1 || true
killall cfprefsd >/dev/null 2>&1 || true

echo "Done. Some changes may require log out / restart."