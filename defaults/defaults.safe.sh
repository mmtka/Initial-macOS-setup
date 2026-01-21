#!/usr/bin/env bash
set -euo pipefail

# Load configuration
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
if [[ -f "${REPO_DIR}/config.sh" ]]; then
  source "${REPO_DIR}/config.sh"
fi

# Close System Settings to avoid overrides
osascript -e 'tell application "System Settings" to quit' >/dev/null 2>&1 || true
osascript -e 'tell application "System Preferences" to quit' >/dev/null 2>&1 || true

###############################################################################
# SAFE DEFAULTS (should be fine on any Mac)
###############################################################################

# Save new documents locally instead of iCloud
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# AirDrop over all interfaces
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Disable smart substitutions and autocorrect
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Language/locale (from config.sh)
LANGUAGES_ARRAY=()
for lang in "${LANGUAGES[@]}"; do
  LANGUAGES_ARRAY+=("$lang")
done
defaults write NSGlobalDomain AppleLanguages -array "${LANGUAGES_ARRAY[@]}"
defaults write NSGlobalDomain AppleLocale -string "${LOCALE}@currency=${CURRENCY}"

if [[ "${USE_METRIC}" == "true" ]]; then
  defaults write NSGlobalDomain AppleMeasurementUnits -string "${MEASUREMENT_UNITS}"
  defaults write NSGlobalDomain AppleMetricUnits -bool true
else
  defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
  defaults write NSGlobalDomain AppleMetricUnits -bool false
fi

# Expand save/print panels
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

###############################################################################
# UI / ANIMATIONS
###############################################################################

# Scrollbars visibility (Always/Automatic/WhenScrolling)
defaults write NSGlobalDomain AppleShowScrollBars -string "${SCROLLBARS_VISIBILITY:-Always}"

# Window resize speed (lower = faster)
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Disable window opening animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.springing.delay -float 0.5

# Double-click title bar action (Maximize/Minimize/None)
defaults write NSGlobalDomain AppleActionOnDoubleClick -string "Maximize"

# Menu bar flash count
defaults write NSGlobalDomain NSMenuBarFlashCount -int 2

# Hide menu bar (from config.sh)
if [[ "${MENU_BAR_AUTOHIDE:-false}" == "true" ]]; then
  defaults write NSGlobalDomain _HIHideMenuBar -bool true
else
  defaults write NSGlobalDomain _HIHideMenuBar -bool false
fi

# Close windows when quitting app
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

###############################################################################
# INPUT (safe)
###############################################################################

# Tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Three-finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# Trackpad right click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# Trackpad click sensitivity (0 = light, 1 = medium, 2 = firm)
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int "${TRACKPAD_CLICK_THRESHOLD:-1}"
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int "${TRACKPAD_CLICK_THRESHOLD:-1}"

# Force Click and haptic feedback
defaults write com.apple.AppleMultitouchTrackpad ActuateDetents -bool true
defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool false

# Key repeat faster
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Classic (non-natural) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Full keyboard access (Tab through all controls)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

###############################################################################
# MENU BAR
###############################################################################

# Clock format (e.g., "EEE d MMM HH:mm" or "EEE d. MMM HH:mm:ss")
defaults write com.apple.menuextra.clock DateFormat -string "${MENU_BAR_CLOCK_FORMAT:-EEE d. MMM  HH:mm}"

# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

###############################################################################
# SCREENSHOTS
###############################################################################
mkdir -p "${SCREENSHOT_DIR}"
defaults write com.apple.screencapture location -string "${SCREENSHOT_DIR}"
defaults write com.apple.screencapture type -string "${SCREENSHOT_FORMAT}"
defaults write com.apple.screencapture disable-shadow -bool true

# Include mouse cursor in screenshots
defaults write com.apple.screencapture showsCursor -bool "${SCREENSHOT_SHOW_CURSOR:-false}"

# Show thumbnail after screenshot
defaults write com.apple.screencapture show-thumbnail -bool "${SCREENSHOT_SHOW_THUMBNAIL:-true}"

###############################################################################
# FINDER
###############################################################################

# Hidden files + extensions (from config.sh)
if [[ "${FINDER_SHOW_HIDDEN}" == "true" ]]; then
  defaults write com.apple.finder AppleShowAllFiles -bool true
else
  defaults write com.apple.finder AppleShowAllFiles -bool false
fi

if [[ "${FINDER_SHOW_EXTENSIONS}" == "true" ]]; then
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
else
  defaults write NSGlobalDomain AppleShowAllExtensions -bool false
fi

# Disable extension change warning
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Desktop icons
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Finder UI
defaults write com.apple.finder DisableAllAnimations -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXPreferredViewStyle -string "${FINDER_VIEW_STYLE}"

# Quick Look - enable text selection
defaults write com.apple.finder QLEnableTextSelection -bool true

# Show POSIX path in Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool "${FINDER_SHOW_POSIX_PATH:-true}"

# Disable warning before emptying Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool "${FINDER_WARN_EMPTY_TRASH:-false}"

# Expand File Info panes by default
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  OpenWith -bool true \
  Privileges -bool true

# Enable Quit Finder menu item (Cmd+Q)
defaults write com.apple.finder QuitMenuItem -bool "${FINDER_QUIT_MENU:-true}"

# Disable iCloud Drive removal warning
defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false

# Show Recent Tags in sidebar
defaults write com.apple.finder ShowRecentTags -bool "${FINDER_SHOW_RECENT_TAGS:-false}"

# Spawn new windows instead of tabs
defaults write com.apple.finder FinderSpawnTab -bool "${FINDER_SPAWN_TAB:-false}"

# Prevent .DS_Store on network/USB
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Auto-open Finder on mounts
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# New Finder windows open to Home
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Show ~/Library
chflags nohidden "${HOME}/Library" 2>/dev/null || true

# Skip disk image verification (speeds up mounting)
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

###############################################################################
# DOCK / SPACES / HOT CORNERS
###############################################################################
defaults write com.apple.dock tilesize -int "${DOCK_TILE_SIZE}"
defaults write com.apple.dock minimize-to-application -bool true

if [[ "${DOCK_SHOW_RECENTS}" == "true" ]]; then
  defaults write com.apple.dock show-recents -bool true
else
  defaults write com.apple.dock show-recents -bool false
fi

defaults write com.apple.dock mru-spaces -bool false

# Dock autohide
if [[ "${DOCK_AUTOHIDE:-false}" == "true" ]]; then
  defaults write com.apple.dock autohide -bool true
  # Autohide delay (0 = instant)
  defaults write com.apple.dock autohide-delay -float "${DOCK_AUTOHIDE_DELAY:-0}"
  # Autohide animation time
  defaults write com.apple.dock autohide-time-modifier -float "${DOCK_AUTOHIDE_TIME:-0.5}"
else
  defaults write com.apple.dock autohide -bool false
fi

# Minimize effect (genie/scale/suck)
defaults write com.apple.dock mineffect -string "${DOCK_MINIMIZE_EFFECT:-scale}"

# Show indicator for running applications
defaults write com.apple.dock show-process-indicators -bool true

# Spring loading for Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Magnification
if [[ "${DOCK_MAGNIFICATION:-false}" == "true" ]]; then
  defaults write com.apple.dock magnification -bool true
  defaults write com.apple.dock largesize -int "${DOCK_LARGE_SIZE:-64}"
else
  defaults write com.apple.dock magnification -bool false
fi

# Make hidden application icons translucent
defaults write com.apple.dock showhidden -bool true

# Dock position (left/bottom/right)
defaults write com.apple.dock orientation -string "${DOCK_POSITION:-bottom}"

# Mission Control: Group windows by application
defaults write com.apple.dock expose-group-apps -bool "${MISSION_CONTROL_GROUP_APPS:-true}"

# Displays have separate Spaces
defaults write com.apple.spaces spans-displays -bool "${SPACES_SPAN_DISPLAYS:-false}"

# Switch to Space with open windows for the application
defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -bool true

# Hot Corners:
# 0=Disabled, 2=Mission Control, 4=Desktop, 10=Put Display to Sleep
# 5=Start Screen Saver, 6=Disable Screen Saver, 11=Launchpad, 12=Notification Center
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 4
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 10
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

###############################################################################
# SAFARI
###############################################################################
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Backspace key for back navigation
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

# Disable automatic opening of "safe" downloads
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Homepage
defaults write com.apple.Safari HomePage -string "${SAFARI_HOMEPAGE:-about:blank}"

# New tab/window behavior (0=Top Sites, 1=Empty, 2=Same, 3=Bookmarks, 4=Homepage)
defaults write com.apple.Safari NewTabBehavior -int 1
defaults write com.apple.Safari NewWindowBehavior -int 1

# Disable thumbnail cache for History/Top Sites
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

# Privacy - Send Do Not Track header
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Autofill settings
defaults write com.apple.Safari AutoFillPasswords -bool "${SAFARI_AUTOFILL_PASSWORDS:-false}"
defaults write com.apple.Safari AutoFillCreditCardData -bool "${SAFARI_AUTOFILL_CREDIT_CARDS:-false}"

###############################################################################
# TEXTEDIT
###############################################################################

# Use plain text by default (instead of Rich Text)
defaults write com.apple.TextEdit RichText -bool false

# Default encoding UTF-8
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

###############################################################################
# MAIL
###############################################################################

# Copy email addresses without names
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Disable inline attachment viewing
defaults write com.apple.mail DisableInlineAttachmentViewing -bool "${MAIL_DISABLE_INLINE_ATTACHMENTS:-true}"

# Disable automatic loading of remote images (privacy)
defaults write com.apple.mail-shared DisableURLLoading -bool "${MAIL_DISABLE_REMOTE_IMAGES:-true}"

###############################################################################
# SECURITY (safe options)
###############################################################################

# Require password immediately after sleep/screensaver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Disable crash reporter dialog
defaults write com.apple.CrashReporter DialogType -string "none"

###############################################################################
# ACTIVITY MONITOR
###############################################################################
defaults write com.apple.ActivityMonitor IconType -int 2
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

###############################################################################
# TIME MACHINE
###############################################################################
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

###############################################################################
# RESTART AFFECTED APPLICATIONS
###############################################################################
echo "Restarting affected applications..."
for app in "Finder" "Dock" "SystemUIServer" "Safari" "Mail"; do
  killall "${app}" &>/dev/null || true
done

echo "✓ Safe defaults applied successfully!"
echo "Note: Some changes may require logout/restart to take effect."
