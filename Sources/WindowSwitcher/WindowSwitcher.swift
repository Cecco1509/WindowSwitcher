// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import AppKit

@main
struct WindowSwitcher {
    static func main() {
        signal(SIGTERM) { _ in
            log("WindowSwitcher stopping...")
            CFRunLoopStop(CFRunLoopGetCurrent())
        }

        let windowManager = WindowManager()
        let focusManager = FocusManager()
        let hotkeyManager = HotkeyManager(windowManager: windowManager, focusManager: focusManager)

        log("Starting WindowSwitcher...")

        hotkeyManager.start()
        CFRunLoopRun()
    }
}
