import Foundation

protocol GetExchangedAmountUseCase {
    func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void)
}

protocol ExchangeRateFetcher {
    func get(sourceMoney: Money, targetMoney: Money, completion: @escaping (Decimal) -> Void)
}

class RateBasedGetExchangedAmountUseCase: GetExchangedAmountUseCase {
    
    private let exchangeRateFetcher: ExchangeRateFetcher
    
    init(exchangeRateFetcher: ExchangeRateFetcher) {
        self.exchangeRateFetcher = exchangeRateFetcher
    }
    
    func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void) {
        exchangeRateFetcher.get(sourceMoney: sourceBalance.money, targetMoney: targetBalance.money) { rate in
            var initialValue = amount * rate
            var result: Decimal = 0
            NSDecimalRound(&result, &initialValue, 2, .plain)
            completion(.init(amount: result, currency: sourceBalance.money.currency))
        }
    }
}
