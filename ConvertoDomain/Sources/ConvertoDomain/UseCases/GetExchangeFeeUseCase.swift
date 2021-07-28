import Foundation

public protocol GetExchangeFeeUseCase {
    func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void)
}

public protocol TransactionCountFetcher {
    func count(for balance: Balance, completion: @escaping (Int) -> Void)
}

public final class CountBasedDecoratorGetExchangeFeeUseCase: GetExchangeFeeUseCase {
    
    private let countFetcher: TransactionCountFetcher
    private let freeLimitCount: Int
    private let decoratee: GetExchangeFeeUseCase
    
    public init(
        countFetcher: TransactionCountFetcher,
        freeLimitCount: Int,
        decoratee: GetExchangeFeeUseCase
    ) {
        self.countFetcher = countFetcher
        self.freeLimitCount = freeLimitCount
        self.decoratee = decoratee
    }
    
    public func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void) {
        countFetcher.count(for: targetBalance) { [weak self] count in
            guard let self = self else { return }
            if count < self.freeLimitCount { return completion(.init(amount: 0, currency: sourceBalance.money.currency)) }
            self.decoratee.get(sourceBalance: sourceBalance, targetBalance: targetBalance, amount: amount, completion: completion)
        }
    }
}

public final class PercentBasedGetExchangeFeeUseCase: GetExchangeFeeUseCase {
    
    private let percent: Decimal
    
    public init(percent: Decimal) {
        self.percent = percent
    }
    
    public func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void) {
        var initialValue = amount * percent
        var result: Decimal = 0
        NSDecimalRound(&result, &initialValue, 2, .plain)
        completion(.init(amount: result, currency: sourceBalance.money.currency))
    }
}
