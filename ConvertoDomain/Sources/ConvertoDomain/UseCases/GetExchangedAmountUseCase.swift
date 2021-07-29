import Foundation

public protocol GetExchangedAmountUseCase {
    func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void)
}

public protocol ExchangeRateFetcher {
    func get(sourceMoney: Money, targetMoney: Money, completion: @escaping (Decimal) -> Void)
}

public class RateBasedGetExchangedAmountUseCase: GetExchangedAmountUseCase {

    private let exchangeRateFetcher: ExchangeRateFetcher

    public init(exchangeRateFetcher: ExchangeRateFetcher) {
        self.exchangeRateFetcher = exchangeRateFetcher
    }

    public func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void) {
        exchangeRateFetcher.get(sourceMoney: sourceBalance.money, targetMoney: targetBalance.money) { rate in
            completion(.init(amount: (amount * rate).rounded(), currency: sourceBalance.money.currency))
        }
    }
}

public extension Decimal {
    func rounded(scale: Int = 2, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var amountBefore = self
        var result: Decimal = self
        NSDecimalRound(&result, &amountBefore, scale, roundingMode)
        return result
    }
}
