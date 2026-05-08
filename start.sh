#!/bin/bash

launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.windowswitcher.plist > /dev/null 2>&1
if [ $? -eq 0 ]; then
		echo "WindowSwitcher daemon launched successfully."
fi
