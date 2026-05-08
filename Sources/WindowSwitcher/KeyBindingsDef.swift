import CoreGraphics

enum ModifierKey: String, Codable {
    case control
    case option
    case command
    case shift
    case fn

    var cgEventFlag: CGEventFlags {
        switch self {
        case .control: return .maskControl
        case .option:  return .maskAlternate
        case .command: return .maskCommand
        case .shift:   return .maskShift
        case .fn:      return .maskSecondaryFn
        }
    }
}

enum KeyCode: String, Codable {
    // arrows
    case leftArrow
    case rightArrow
    case upArrow
    case downArrow
    // letters
    case a, b, c, d, e, f, g, h, i, j, k, l, m
    case n, o, p, q, r, s, t, u, v, w, x, y, z
    // numbers
    case one = "1", two = "2", three = "3", four = "4"
    case five = "5", six = "6", seven = "7", eight = "8"
    case nine = "9", zero = "0"

    var cgKeyCode: CGKeyCode {
        switch self {
        case .leftArrow:  return 123
        case .rightArrow: return 124
        case .downArrow:  return 125
        case .upArrow:    return 126
        case .a: return 0
        case .s: return 1
        case .d: return 2
        case .f: return 3
        case .h: return 4
        case .g: return 5
        case .z: return 6
        case .x: return 7
        case .c: return 8
        case .v: return 9
        case .b: return 11
        case .q: return 12
        case .w: return 13
        case .e: return 14
        case .r: return 15
        case .y: return 16
        case .t: return 17
        case .one: return 18
        case .two: return 19
        case .three: return 20
        case .four: return 21
        case .five: return 23
        case .six: return 22
        case .seven: return 26
        case .eight: return 28
        case .nine: return 25
        case .zero: return 29
        case .o: return 31
        case .u: return 32
        case .i: return 34
        case .p: return 35
        case .l: return 37
        case .j: return 38
        case .k: return 40
        case .n: return 45
        case .m: return 46
        }
    }
}
