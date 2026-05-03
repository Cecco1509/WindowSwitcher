#!/bin/bash

BINARY_PATH="$HOME/bin/WindowSwitcher"
PLIST_DEST="$HOME/Library/LaunchAgents/local.windowswitcher.plist"

# Clean up any previous installation
./uninstall.sh

# Build the application
swift build --configuration release

# Install the executable
mkdir -p "$HOME/bin"
cp .build/release/WindowSwitcher "$BINARY_PATH"

# Generate the plist with the correct binary path
sed "s|BINARY_PATH_PLACEHOLDER|$BINARY_PATH|g" ./Resources/local.windowswitcher.plist > "$PLIST_DEST"

# Load the launch agent
launchctl bootstrap gui/$(id -u) "$PLIST_DEST"

echo "Installed successfully. Grant Accessibility permission to $BINARY_PATH in System Settings → Privacy & Security → Accessibility"
