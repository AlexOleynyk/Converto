import Foundation

protocol UserBalanceFetcher {
    func get(currency: Currency, completion: @escaping (Balance?) -> Void)
}

final class GetUserBalancesUseCase {
    
    private let userBalanceFetcher: UserBalanceFetcher
    
    init(userBalanceFetcher: UserBalanceFetcher) {
        self.userBalanceFetcher = userBalanceFetcher
    }
    
    func get(currency: Currency, completion: @escaping (Balance?) -> Void) {
        userBalanceFetcher.get(currency: currency, completion: completion)
    }
}
