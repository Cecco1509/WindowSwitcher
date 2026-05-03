import CoreGraphics
import Foundation

struct Window {
    let windowID: CGWindowID
    let appPID: pid_t
    let frame: CGRect
}


func log(_ message: String) {
    let standardOutput = FileHandle.standardOutput
    let output = message + "\n"
    standardOutput.write(output.data(using: .utf8)!)
    fflush(stdout)
}
