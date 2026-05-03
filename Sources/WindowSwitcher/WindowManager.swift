import CoreGraphics
import Foundation

class WindowManager {
    
    func getWindowsSortedHorizontally() -> [Window] {
        let rawWindows = fetchRawWindows()
        let windows = rawWindows.compactMap { parseWindow($0) }
        return windows.sorted { $0.frame.minX < $1.frame.minX }
    }

    func getWindowsSortedVertically() -> [Window] {
        let rawWindows = fetchRawWindows()
        let windows = rawWindows.compactMap { parseWindow($0) }
        return windows.sorted { $0.frame.minY < $1.frame.minY }
    }

    private func fetchRawWindows() -> [[String: AnyObject]] {
        let options = CGWindowListOption([.optionOnScreenOnly, .excludeDesktopElements])
        guard let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: AnyObject]] else {
            return []
        }

        // Filter out windows that are invisible
        return windowList
    }

    private func parseWindow(_ dict: [String: AnyObject]) -> Window? {
        // extract the window ID
        guard let windowID = dict[kCGWindowNumber as String] as? CGWindowID else {
            return nil
        }

        // extract the PID
        guard let pid = dict[kCGWindowOwnerPID as String] as? pid_t else {
            return nil
        }

        guard let appName = dict[kCGWindowOwnerName as String] as? String else {
            return nil
        }

        if appName.isEmpty || appName == "Screenshot" {
            return nil
        }

        log("appName: \(appName) | ID: \(windowID) | PID: \(pid)")

        // extract the frame
        guard let boundsDict = dict[kCGWindowBounds as String] as? [String: CGFloat],
            let x = boundsDict["X"],
            let y = boundsDict["Y"],
            let width = boundsDict["Width"],
            let height = boundsDict["Height"] else {
            return nil
        }

        let frame = CGRect(x: x, y: y, width: width, height: height)

        // filter out small/irrelevant windows
        guard frame.width > 100 && frame.height > 100 else {
            return nil
        }
        return Window(windowID: windowID, appPID: pid, frame: frame)
    }
}
