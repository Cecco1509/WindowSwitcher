#!/bin/bash

launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/local.windowswitcher.plist

swift build --configuration release
cp .build/release/WindowSwitcher ~/bin/WindowSwitcher

launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.windowswitcher.plist
