import Foundation
import ConvertoDomain

final class CachingExchangeRateFetcherDecorator: ExchangeRateFetcher {

    private var cache: [String: Decimal] = [:]
    private let decoratee: ExchangeRateFetcher

    init(decoratee: ExchangeRateFetcher) {
        self.decoratee = decoratee
    }

    func get(sourceMoney: Money, targetMoney: Money, completion: @escaping (Decimal) -> Void) {
        if let rate =  cache[sourceMoney.currency.code + targetMoney.currency.code] {
            return completion(rate)
        }
        decoratee.get(sourceMoney: sourceMoney, targetMoney: targetMoney) { [weak self] rate in
            self?.cache[sourceMoney.currency.code + targetMoney.currency.code] = rate
            completion(rate)
        }
    }
}

final class RoundingRateFetcherDecorator: ExchangeRateFetcher {

    private let currency: Currency
    private let decoratee: ExchangeRateFetcher

    init(
        currency: Currency,
        decoratee: ExchangeRateFetcher
    ) {
        self.currency = currency
        self.decoratee = decoratee
    }

    func get(sourceMoney: Money, targetMoney: Money, completion: @escaping (Decimal) -> Void) {
        decoratee.get(sourceMoney: sourceMoney, targetMoney: targetMoney) { [weak self] rate in
            if self?.currency == targetMoney.currency {
                return completion(rate.rounded(scale: 0, roundingMode: .down))
            }
            completion(rate)
            
        }
    }
}
