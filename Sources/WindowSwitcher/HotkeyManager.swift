import CoreGraphics
import Foundation
import ApplicationServices
import AppKit

class HotkeyManager {
    
    private let windowManager: WindowManager
    private let focusManager: FocusManager
    private var eventTap: CFMachPort?
    private let config: WindowSwitcherConfig
    
    init(windowManager: WindowManager, focusManager: FocusManager, config: WindowSwitcherConfig) {
        self.windowManager = windowManager
        self.focusManager = focusManager
        self.config = config
    }
    
    func start() {

        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        let isTrusted = AXIsProcessTrustedWithOptions(options)
        log("Accessibility permission granted: \(isTrusted)")

        if !isTrusted {
            log("Please grant Accessibility permission to the app in System Preferences > Security & Privacy > Privacy > Accessibility")
            return
        }

        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue)
    
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { proxy, type, event, refcon in
                let manager = Unmanaged<HotkeyManager>.fromOpaque(refcon!).takeUnretainedValue()
                return manager.handleEvent(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
    
        guard let tap = eventTap else {
            log("Failed to create event tap — check Accessibility permission")
            return
        }
    
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }  

    private func handleEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        let flags = event.flags
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        
        let allModifiersPressed = config.modifiers.allSatisfy { flags.contains($0.cgEventFlag) } 
        guard allModifiersPressed else {
            return Unmanaged.passUnretained(event)
        }
    
        switch keyCode {
        case Int64(config.keys.left.cgKeyCode): 
            moveFocus(direction: .left)
            return nil
        case Int64(config.keys.right.cgKeyCode):
            moveFocus(direction: .right)
            return nil
        case Int64(config.keys.down.cgKeyCode):
            moveFocus(direction: .down)
            return nil
        case Int64(config.keys.up.cgKeyCode):
            moveFocus(direction: .up)
            return nil
        default:
            return Unmanaged.passUnretained(event)
        }
    }
    
    private func moveFocus(direction: Direction) {
        var windows: [Window]

        switch direction {
        case .left, .right:
            windows = windowManager.getWindowsSortedHorizontally()
        case .up, .down:
            windows = windowManager.getWindowsSortedVertically()
        }

        guard let focused = focusedWindow(in: windows) else { return }

        let isHorizontal = direction == .left || direction == .right

        // filter out windows on the same axis as focused
        windows = windows.filter { $0.windowID != focused.windowID }

        guard !windows.isEmpty else { return }

        // find nearest window perpendicular to movement direction
        guard let nearest = windows.min(by: {
            let distA = isHorizontal
                ? abs($0.frame.midY - focused.frame.midY)
                : abs($0.frame.midX - focused.frame.midX)
            let distB = isHorizontal
                ? abs($1.frame.midY - focused.frame.midY)
                : abs($1.frame.midX - focused.frame.midX)
            return distA < distB
        }) else { return }

        focusManager.focusWindow(nearest)
    } 
    
    private func focusedWindow(in windows: [Window]) -> Window? {
        guard let frontApp = NSWorkspace.shared.frontmostApplication else { return nil }
        let pid = frontApp.processIdentifier
        
        let axApp = AXUIElementCreateApplication(pid)
        var focusedWindowRef: CFTypeRef?
        AXUIElementCopyAttributeValue(axApp, kAXFocusedWindowAttribute as CFString, &focusedWindowRef)
    
        guard let focusedWindowRef = focusedWindowRef else { return nil }
        let axWindow = focusedWindowRef as! AXUIElement
    
        var wid: CGWindowID = 0
        _AXUIElementGetWindow(axWindow, &wid)
    
        return windows.first { $0.windowID == wid }
    }
}

enum Direction {
    case left, right, up, down
}
