import Foundation

public protocol UserBalanceFetcher {
    func get(currency: Currency, completion: @escaping (Balance?) -> Void)
}

public final class GetUserBalancesUseCase {

    private let userBalanceFetcher: UserBalanceFetcher

    public init(userBalanceFetcher: UserBalanceFetcher) {
        self.userBalanceFetcher = userBalanceFetcher
    }

    public func get(currency: Currency, completion: @escaping (Balance?) -> Void) {
        userBalanceFetcher.get(currency: currency, completion: completion)
    }
}
