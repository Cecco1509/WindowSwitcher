#!/bin/bash

# Uninstall the application

# Stop the deamon
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/local.windowswitcher.plist > /dev/null 2>&1

# Remove the executable and the launch agent
rm ~/bin/WindowSwitcher
rm ~/Library/LaunchAgents/local.windowswitcher.plist
