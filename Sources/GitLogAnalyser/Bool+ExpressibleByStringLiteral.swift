import Foundation

extension Bool {
    public init(stringLiteral value: String) {
        switch value {
        case "true": self = true
        default: self = false
        }
    }
}
