import CoreGraphics
import Foundation
import ApplicationServices

class HotkeyManager {
    
    private let windowManager: WindowManager
    private let focusManager: FocusManager
    private var eventTap: CFMachPort?
    
    init(windowManager: WindowManager, focusManager: FocusManager) {
        self.windowManager = windowManager
        self.focusManager = focusManager
    }
    
    func start() {

        let isTrusted = AXIsProcessTrusted()
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
        
        let isControlOption = flags.contains(.maskControl) && flags.contains(.maskAlternate)
        
        guard isControlOption else {
            return Unmanaged.passUnretained(event)
        }
        
        switch keyCode {
        case 123: // left arrow
            moveFocus(direction: .left)
            return nil
        case 124: // right arrow
            moveFocus(direction: .right)
            return nil
        case 125: // down arrow
            moveFocus(direction: .down)
            return nil
        case 126: // up arrow
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
        
        // Add filtering for windows that have the same Y coordinate (for horizontal) or X coordinate (for vertical) as the focused windows
        windows = windows.filter { window in
            switch direction {
            case .left, .right:
                return abs(window.frame.minX - focused.frame.minX) != 0
            case .up, .down:
                return abs(window.frame.minY - focused.frame.minY) != 0
            }
        }
        
        if windows.isEmpty {
            return
        }

        if windows.count == 1 {
            focusManager.focusWindow(windows[0])
            return
        }

        // Search for the index of the nearest window in the specified direction
        var nearestWindowIndex: Int = 0
        switch direction {
        case .left:
            nearestWindowIndex = windows.enumerated().min(by: { abs($0.element.frame.midY - focused.frame.midY) < abs($1.element.frame.midY - focused.frame.midY) })?.offset ?? 0
        case .right:
            nearestWindowIndex = windows.enumerated().min(by: { abs($0.element.frame.midY - focused.frame.midY) < abs($1.element.frame.midY - focused.frame.midY ) })?.offset ?? 0
        case .up:
            nearestWindowIndex = windows.enumerated().min(by: { abs($0.element.frame.midX - focused.frame.midX) < abs($1.element.frame.midX - focused.frame.midX ) })?.offset ?? 0
        case .down:
            nearestWindowIndex = windows.enumerated().min(by: { abs($0.element.frame.midX - focused.frame.midX) < abs($1.element.frame.midX - focused.frame.midX ) })?.offset ?? 0
        }

        focusManager.focusWindow(windows[nearestWindowIndex])
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
