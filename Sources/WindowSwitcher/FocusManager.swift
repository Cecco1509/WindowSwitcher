import ApplicationServices
import Foundation

class FocusManager {

    func focusWindow(_ window: Window) {

        if let exApp = NSRunningApplication(processIdentifier: window.appPID) {
            exApp.activate(options: .activateIgnoringOtherApps)
        }

        let app = AXUIElementCreateApplication(window.appPID)
        
        var windowList: AnyObject?
        AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &windowList)
        
        guard let windows = windowList as? [AXUIElement] else { return }
        
        for axWindow in windows {
            if windowID(of: axWindow) == window.windowID {
                AXUIElementSetAttributeValue(axWindow, kAXMainAttribute as CFString, true as CFTypeRef)
                AXUIElementSetAttributeValue(axWindow, kAXFocusedAttribute as CFString, true as CFTypeRef)
                movePointerToCenter(of: window)
                return
            }
        }
    }

    private func movePointerToCenter(of window: Window) {
        let center = CGPoint(
            x: window.frame.midX,
            y: window.frame.midY
        )
        CGWarpMouseCursorPosition(center)
    }
    
    private func windowID(of axWindow: AXUIElement) -> CGWindowID {
        var wid: CGWindowID = 0
        _AXUIElementGetWindow(axWindow, &wid)
        return wid
    }
}
