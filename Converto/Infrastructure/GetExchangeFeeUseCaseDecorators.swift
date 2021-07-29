import Foundation
import ConvertoDomain

protocol TransactionCountFetcher {
    func count(for balance: Balance, completion: @escaping (Int) -> Void)
}

final class LimitBasedGetExchangeFeeUseCaseDecorator: GetExchangeFeeUseCase {

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

final class RoundingGetExchangeFeeUseCaseDecorator: GetExchangeFeeUseCase {

    private let currency: Currency
    private let decoratee: GetExchangeFeeUseCase

    init(
        currency: Currency,
        decoratee: GetExchangeFeeUseCase
    ) {
        self.currency = currency
        self.decoratee = decoratee
    }

    func get(sourceBalance: Balance, targetBalance: Balance, amount: Decimal, completion: @escaping (Money) -> Void) {
        decoratee.get(sourceBalance: sourceBalance, targetBalance: targetBalance, amount: amount) { [weak self] money in
            guard let self = self else { return }
            if self.currency == sourceBalance.money.currency {
                return completion(Money(amount: money.amount.rounded(scale: 0, roundingMode: .up), currency: self.currency))
            }
            completion(money)
            
        }
    }
}
