import Foundation

public protocol GetUserBalancesForSelectionUseCase {
    func get(completion: @escaping ([Balance]) -> Void)
}

public class GetUserBalancesForSelectionUseCaseImpl: GetUserBalancesForSelectionUseCase {

    private let userWalletRepository: WalletRepository

    public init(userWalletRepository: WalletRepository) {
        self.userWalletRepository = userWalletRepository
    }

    public func get(completion: @escaping ([Balance]) -> Void) {
        userWalletRepository.fetchWallet {
            let sortedBalances = $0.balances
                .sorted {
                    if $0.money.amount != 0 && $1.money.amount != 0 { return false }
                    if $0.money.amount == 0 && $1.money.amount == 0 { return false }
                    return ($0.money.amount == 0 ? Decimal(Int.max) : $0.money.amount) < ($1.money.amount == 0 ? Decimal(Int.max) : $1.money.amount)
                }
            completion(sortedBalances)
        }
    }
}
