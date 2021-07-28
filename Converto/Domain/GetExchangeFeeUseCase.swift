import Foundation


protocol GetExchangeFeeUseCase {
    func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void)
}

protocol TransactionCountFetcher {
    func count(for balance: Balance, completion: @escaping (Int) -> Void)
}

final class CountBasedDecoratorGetExchangeFeeUseCase: GetExchangeFeeUseCase {
    
    private let countFetcher: TransactionCountFetcher
    private let freeLimitCount: Int
    private let decoratee: GetExchangeFeeUseCase
    
    init(
        countFetcher: TransactionCountFetcher,
        freeLimitCount: Int,
        decoratee: GetExchangeFeeUseCase
    ) {
        self.countFetcher = countFetcher
        self.freeLimitCount = freeLimitCount
        self.decoratee = decoratee
    }
    
    func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void) {
        countFetcher.count(for: targetBalance) { [weak self] count in
            guard let self = self else { return }
            if count < self.freeLimitCount { return completion(.init(amount: 0, currency: sourceBalance.money.currency)) }
            self.decoratee.get(sourceBalance: sourceBalance, targetBalance: targetBalance, amount: amount, completion: completion)
        }
    }
}

final class PercentBasedGetExchangeFeeUseCase: GetExchangeFeeUseCase {
    
    private let percent: Decimal
    
    init(percent: Decimal) {
        self.percent = percent
    }
    
    func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void) {
        var initialValue = amount * percent
        var result: Decimal = 0
        NSDecimalRound(&result, &initialValue, 2, .plain)
        completion(.init(amount: result, currency: sourceBalance.money.currency))
    }
}
