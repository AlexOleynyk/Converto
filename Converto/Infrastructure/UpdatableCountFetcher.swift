import Foundation
import ConvertoDomain

final class UpdatableCountFetcher: TransactionCountFetcher {
    private var countStorage: [Int: Int] = [:]

    func increaseCount(for balance: Balance) {
        countStorage[balance.id] = value(for: balance) + 1
    }

    private func value(for balance: Balance) -> Int {
        countStorage[balance.id] ?? 0
    }

    func count(for balance: Balance, completion: @escaping (Int) -> Void) {
        completion(value(for: balance))
    }
}
