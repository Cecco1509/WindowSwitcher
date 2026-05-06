#!/bin/bash

# Stop the deamon (if it's running)
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/local.windowswitcher.plist > /dev/null 2>&1
if [ $? -eq 0 ]; then
		echo "WindowSwitcher daemon stopped successfully."
fi

# Launch the deamon again
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.windowswitcher.plist
if [ $? -eq 0 ]; then
		echo "WindowSwitcher daemon restarted successfully."
else
		echo "Failed to restart the WindowSwitcher daemon. Please check the plist file and try again"
		exit 1
fi
