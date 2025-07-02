import Foundation

extension NumberFormatter {
    func string<Value: BinaryFloatingPoint>(from value: Value) -> String {
        string(from: NSNumber(value: Double(value)))!
    }
}
