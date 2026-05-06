#!/bin/bash

BINARY_PATH="$HOME/bin/WindowSwitcher"
PLIST_DEST="$HOME/Library/LaunchAgents/local.windowswitcher.plist"

# Clean up any previous installation
./uninstall.sh > /dev/null 2>&1

# Build the application
swift build --configuration release
if [ $? -ne 0 ]; then
    echo "Build failed. Please fix the errors and try again."
		exit 1
fi

# Install the executable
mkdir -p "$HOME/bin"
cp .build/release/WindowSwitcher "$BINARY_PATH"
if [ $? -ne 0 ]; then
    echo "Build failed. An error occurred while copying the executable."
		exit 1
fi

# Generate the plist with the correct binary path
sed "s|BINARY_PATH_PLACEHOLDER|$BINARY_PATH|g" ./Resources/local.windowswitcher.plist > "$PLIST_DEST"

# Load the launch agent
launchctl bootstrap gui/$(id -u) "$PLIST_DEST"
if [ $? -ne 0 ]; then
    echo "Failed to load the launch agent. Please check the plist file and try again."
		exit 1
fi

echo "Installed successfully. Grant Accessibility permission to $BINARY_PATH in System Settings → Privacy & Security → Accessibility"
