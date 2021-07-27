//
//  SceneDelegate.swift
//  Converto
//
//  Created by alex.oleynyk on 26.07.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private lazy var userWalletRepository = UserWalletRepository()
    private lazy var rootController = UINavigationController(
        rootViewController: ViewController(
            getBalanceUseCase: GetUserBalancesUseCase(userBalanceFetcher: userWalletRepository),
            getFeeUseCase: CountBasedDecoratorGetExchangeFeeUseCase(
                countFetcher: SingleValueCountFetcher(),
                freeLimitCount: 5,
                decoratee: PercentBasedGetExchangeFeeUseCase(percent: 0.007)
            ),
            exchangeMoneyUseCase: ExchangeMoneyUseCaseImpl(userWalletRepository: userWalletRepository, bankWalletRepository: BankWalletRepository()),
            getExchangedAmountUseCase: RateBasedGetExchangedAmountUseCase(exchangeRateFetcher: MockExchangeRateFetcher())
        )
    )

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.rootViewController = rootController
        window.makeKeyAndVisible()
    }
}

// MARK: - Mocked data and classes


private class UserWalletRepository: WalletRepository, UserBalanceFetcher {
    private var mockWallet = Wallet(balances: [
        Balance(id: 1, money: Money(amount: 1000, currency: Currency(id: 1, code: "USD"))),
        Balance(id: 2, money: Money(amount: 100, currency: Currency(id: 2, code: "EUR")))
    ])

    
    func updateWallet(_ wallet: Wallet, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.mockWallet = wallet
            completion(true)
        }
    }
    
    func fetchWallet(completion: @escaping (Wallet) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(self.mockWallet)
        }
    }
    
    func get(currency: Currency, completion: @escaping (Balance?) -> Void) {
        completion(mockWallet.balances.first(where: { $0.money.currency == currency }))
    }
}

private class BankWalletRepository: WalletRepository {
    private var bankWallet = Wallet(balances: [
        Balance(id: 1, money: Money(amount: 0, currency: Currency(id: 1, code: "USD"))),
        Balance(id: 2, money: Money(amount: 0, currency: Currency(id: 2, code: "EUR")))
    ])

    func updateWallet(_ wallet: Wallet, completion: @escaping (Bool) -> Void) {
        bankWallet = wallet
        completion(true)
    }
    
    func fetchWallet(completion: @escaping (Wallet) -> Void) {
        completion(bankWallet)
    }
}


private class SingleValueCountFetcher: TransactionCountFetcher {
    func count(for balance: Balance, completion: @escaping (Int) -> Void) {
        completion(6)
    }
}

private class MockExchangeRateFetcher: ExchangeRateFetcher {
    func get(sourceMoney: Money, targetMoney: Money, completion: @escaping (Decimal) -> Void) {
        completion(1.2)
    }
}
