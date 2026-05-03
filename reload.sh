#!/bin/bash

# Stop the deamon (if it's running)
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/local.windowswitcher.plist

# Launch the deamon again
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.windowswitcher.plist
