import Foundation

public protocol GetExchangeFeeUseCase {
    func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void)
}

public final class PercentBasedGetExchangeFeeUseCase: GetExchangeFeeUseCase {

    private let percent: Decimal

    public init(percent: Decimal) {
        self.percent = percent
    }

    public func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void) {
        var initialValue = amount * percent
        var result: Decimal = 0
        NSDecimalRound(&result, &initialValue, 2, .up)
        completion(.init(amount: result, currency: sourceBalance.money.currency))
    }
}
