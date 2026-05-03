#!/bin/bash

launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/local.windowswitcher.plist

launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.windowswitcher.plist
