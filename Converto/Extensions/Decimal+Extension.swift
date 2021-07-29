import Foundation

extension Decimal {
    var whole: Decimal { self < 0 ? rounded(roundingMode: .up) : rounded(roundingMode: .down) }

    func rounded(scale: Int = 2, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var amountBefore = self
        var result: Decimal = self
        NSDecimalRound(&result, &amountBefore, scale, roundingMode)
        return result
    }
}
