import Foundation

public protocol TwoWayFormatter {
    associatedtype Value
    func toString(_ value: Value?) -> String
    func fromString(_ string: String) -> Value?
}
