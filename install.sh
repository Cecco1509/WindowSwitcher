#!/bin/bash

# Clean up any previous installation
./uninstall.sh

# Build the application
swift build --configuration release

# Install the executable and the launch agent
cp .build/release/WindowSwitcher ~/bin/WindowSwitcher
cp ./Resources/local.windowswitcher.plist ~/Library/LaunchAgents/local.windowswitcher.plist

# Load the launch agent
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.windowswitcher.plist
