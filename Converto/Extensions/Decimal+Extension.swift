import Foundation

extension Decimal {
    var whole: Decimal { Decimal(NSDecimalNumber(decimal: self).intValue) }
}
