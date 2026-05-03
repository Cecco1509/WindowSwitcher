import CoreGraphics
import Foundation

class WindowManager {

    // hardcoded list of bundle IDs to ignore    
    private let ignoredBundleIDs: Set<String> = [
        "com.apple.Screenshot",
        "com.apple.dock",
        "com.apple.controlcenter",
        "com.apple.screencaptureui",
    ]

    private func getWindows() -> [Window] {
        return fetchRawWindows().compactMap { parseWindow($0) }
    }

    func getWindowsSortedHorizontally() -> [Window] {
        return getWindows().sorted { $0.frame.minX < $1.frame.minX }
    }

    func getWindowsSortedVertically() -> [Window] {
        return getWindows().sorted { $0.frame.minY < $1.frame.minY }
    }

    private func fetchRawWindows() -> [[String: AnyObject]] {
        let options = CGWindowListOption([.optionOnScreenOnly, .excludeDesktopElements])
        guard let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: AnyObject]] else {
            return []
        }

        return windowList
    }

    // helper to get bundle ID for a given PID, prints the PID and bundle ID for debugging
    private func bundleID(forPID pid: pid_t) -> String? {
        NSRunningApplication(processIdentifier: pid)?.bundleIdentifier
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

        guard let bid = bundleID(forPID: pid), !ignoredBundleIDs.contains(bid) else {
            return nil
        }

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
