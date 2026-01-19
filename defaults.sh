#!/usr/bin/env bash

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


# GENERAL :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Use AirDrop over every interface
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

# Remove duplicates in the “Open With” menu (also see `lscleanup` alias)
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

# Disable automatic Smart Substitutions
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct. OH YEAH PLEASE!
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "sk" "en" "cz" "de"
defaults write NSGlobalDomain AppleLocale -string "de_DE@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Set the timezone
sudo systemsetup -settimezone "Europe/Berlin" > /dev/null

# Hide language menu in the top right corner of the boot screen
sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool false


# TRACKPAD :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Enable 3-finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true


# ENERGY SAVING ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Enable lid wakeup
sudo pmset -a lidwake 1

# Sleep the display after 5 minutes
sudo pmset -a displaysleep 5

# Disable machine sleep while charging
sudo pmset -c sleep 0

# Set machine sleep to 10 minutes on battery
sudo pmset -b sleep 10

# Disable hibernation
sudo pmset -a hibernatemode 0

# FINDER :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Disable window animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Disable warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Set home as default location for new Finder windows
defaults write com.apple.finder NewWindowTarget -string "PfHm"

# Show status & path bar
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Set grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 64" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 64" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 64" ~/Library/Preferences/com.apple.finder.plist

# Set icons size on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 48" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 48" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 48" ~/Library/Preferences/com.apple.finder.plist

# Use collum view in all Finder windows by default
# Four-letter codes for the other view modes: 'Nlsv', 'glyv', 'icnv',
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Show the ~/Library folder
chflags nohidden ~/Library

# Create user Sites directory
mkdir -p "$HOME/Sites"


# DOCK ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Set the icon size of Dock items
defaults write com.apple.dock tilesize -int 32

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Wipe all default app icons from the Dock
defaults write com.apple.dock persistent-apps -array true

# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false


# NETWORK :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Set default Cloudflare DNS (and Google as fallback)
networksetup -setdnsservers Wi-Fi 1.1.1.1 1.0.0.1 8.8.8.8


# TERMINAL :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Set default Terminal theme to Pro (dark)
defaults write com.apple.terminal "Default Window Settings" -string "Brew"
defaults write com.apple.terminal "Startup Window Settings" -string "Brew"

# OTHER :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#"Application Downloaded from Internet" popup will not display
defaults write com.apple.LaunchServices "LSQuarantine" -bool "false"

# APPLE INTELIGENCE ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool "false"


# MISSION CONTROL ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
defaults write com.apple.dock "mru-spaces" -bool "false"

# Fn/🌐 key usage ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
defaults write com.apple.HIToolbox AppleFnUsageType -int "1"