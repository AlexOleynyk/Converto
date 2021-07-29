import Foundation
import ConvertoDomain

final class UserWalletRepository: WalletRepository, UserBalanceFetcher {
    private var mockWallet = Wallet(balances: [
        Balance(id: 1, money: Money(amount: 0, currency: Currency(id: 1, code: "USD"))),
        Balance(id: 2, money: Money(amount: 1000, currency: Currency(id: 2, code: "EUR"))),
        Balance(id: 3, money: Money(amount: 0, currency: Currency(id: 3, code: "JPY")))
    ])

    func updateWallet(_ wallet: Wallet, completion: @escaping (Bool) -> Void) {
        simulateNetworkDelay {
            self.mockWallet = wallet
            completion(true)
        }
    }

    func fetchWallet(completion: @escaping (Wallet) -> Void) {
        simulateNetworkDelay {
            completion(self.mockWallet)
        }
    }

    func get(currency: Currency, completion: @escaping (Balance?) -> Void) {
        simulateNetworkDelay {
            completion(self.mockWallet.balances.first(where: { $0.money.currency == currency }))
        }
    }
}

final class BankWalletRepository: WalletRepository {
    private var bankWallet = Wallet(balances: [
        Balance(id: 1, money: Money(amount: 0, currency: Currency(id: 1, code: "USD"))),
        Balance(id: 2, money: Money(amount: 0, currency: Currency(id: 2, code: "EUR"))),
        Balance(id: 3, money: Money(amount: 0, currency: Currency(id: 3, code: "JPY")))
    ])

    func updateWallet(_ wallet: Wallet, completion: @escaping (Bool) -> Void) {
        bankWallet = wallet
        completion(true)
    }

    func fetchWallet(completion: @escaping (Wallet) -> Void) {
        completion(bankWallet)
    }
}

final class ExcludingWalletRepositoryDecorator: WalletRepository {

    private let decoratee: WalletRepository
    private let exculedBalance: Balance

    init(decoratee: WalletRepository, exculedBalance: Balance) {
        self.decoratee = decoratee
        self.exculedBalance = exculedBalance
    }

    func updateWallet(_ wallet: Wallet, completion: @escaping (Bool) -> Void) {
        decoratee.updateWallet(wallet, completion: completion)
    }

    func fetchWallet(completion: @escaping (Wallet) -> Void) {
        decoratee.fetchWallet(completion: { [weak self] wallet in
            let newWallet = Wallet(balances: wallet.balances.filter { $0.id != self?.exculedBalance.id })
            completion(newWallet)
        })
    }

}
