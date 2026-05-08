import Foundation
import TOMLKit

struct WindowSwitcherConfig {
    let modifiers: [ModifierKey]
    let keys: DirectionalKeys
    let pacman: Bool

    struct DirectionalKeys {
        let left: KeyCode
        let right: KeyCode
        let up: KeyCode
        let down: KeyCode
    }

    static let defaultConfig = WindowSwitcherConfig(
        modifiers: [.control, .option],
        keys: DirectionalKeys(
            left: .leftArrow,
            right: .rightArrow,
            up: .upArrow,
            down: .downArrow
        ),
        pacman: true
    )

    static func load() -> WindowSwitcherConfig {
        let configPath = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".config/WindowSwitcher/config.toml")

        guard let contents = try? String(contentsOf: configPath, encoding: .utf8) else {
            log("Config file not found at \(configPath.path) — using defaults")
            return .defaultConfig
        }

        do {
            let table = try TOMLKit.TOMLTable(string: contents)

            let modifiers: [ModifierKey] = table["modifiers"]?["switch_window"]?
                .array?
                .compactMap { $0.string }
                .compactMap { ModifierKey(rawValue: $0) } ?? defaultConfig.modifiers

            let keysTable = table["keys"]
            let left   = keysTable?["left"]?.string.flatMap   { KeyCode(rawValue: $0) } ?? defaultConfig.keys.left
            let right  = keysTable?["right"]?.string.flatMap  { KeyCode(rawValue: $0) } ?? defaultConfig.keys.right
            let up     = keysTable?["up"]?.string.flatMap     { KeyCode(rawValue: $0) } ?? defaultConfig.keys.up
            let down   = keysTable?["down"]?.string.flatMap   { KeyCode(rawValue: $0) } ?? defaultConfig.keys.down
            let pacman = table["behavior"]?["pacman"]?.bool ?? defaultConfig.pacman

            log("Config loaded from \(configPath.path)")
            return WindowSwitcherConfig(
                modifiers: modifiers,
                keys: DirectionalKeys(left: left, right: right, up: up, down: down),
                pacman: pacman
            )
        } catch {
            log("Failed to parse config: \(error) — using defaults")
            return .defaultConfig
        }
    }
}
