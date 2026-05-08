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
        let windows = direction == .left || direction == .right
            ? windowManager.getWindowsSortedHorizontally()
            : windowManager.getWindowsSortedVertically() 

        guard windows.count > 1 else { return }
        guard let focused = focusedWindow(in: windows) else { return }

        let candidates: [Window]
            switch direction {
            case .left:
                candidates = windows.filter { $0.frame.midX < focused.frame.midX }
            case .right:
                candidates = windows.filter { $0.frame.midX > focused.frame.midX }
            case .up:
                candidates = windows.filter {
                    $0.frame.midY < focused.frame.midY &&
                    $0.frame.maxX > focused.frame.minX &&
                    $0.frame.minX < focused.frame.maxX
                }
            case .down:
                candidates = windows.filter {
                    $0.frame.midY > focused.frame.midY &&
                    $0.frame.maxX > focused.frame.minX &&
                    $0.frame.minX < focused.frame.maxX
                }
            } 

        // pacman effect — wrap around if no candidates in that direction
        let targetPool: [Window]
        if candidates.isEmpty {
            guard config.pacman else { return }
            // wrap: reverse direction gives all other windows
            targetPool = windows.filter { $0.windowID != focused.windowID }
        } else {
            targetPool = candidates
        }

        guard let nearest = targetPool.min(by: {
            let isHorizontal = direction == .left || direction == .right
            
            let primaryDistA = isHorizontal
                ? abs($0.frame.midX - focused.frame.midX)
                : abs($0.frame.midY - focused.frame.midY)
            let primaryDistB = isHorizontal
                ? abs($1.frame.midX - focused.frame.midX)
                : abs($1.frame.midY - focused.frame.midY)
            
            // if same primary distance, use perpendicular as tiebreaker
            if primaryDistA == primaryDistB {
                let perpDistA = isHorizontal
                    ? abs($0.frame.midY - focused.frame.midY)
                    : abs($0.frame.midX - focused.frame.midX)
                let perpDistB = isHorizontal
                    ? abs($1.frame.midY - focused.frame.midY)
                    : abs($1.frame.midX - focused.frame.midX)
                return perpDistA < perpDistB
            }
            
            return primaryDistA < primaryDistB
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
