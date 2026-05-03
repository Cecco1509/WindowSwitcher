import Foundation

func log(_ message: String) {
    let standardOutput = FileHandle.standardOutput
    let output = message + "\n"
    standardOutput.write(output.data(using: .utf8)!)
    fflush(stdout)
}
