import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private lazy var userWalletRepository = UserWalletRepository()
    private lazy var countFetcher = UpdatableCountFetcher()

    private lazy var rootController = UINavigationController(
        rootViewController: ConvertorViewController(
            getBalanceUseCase: GetUserBalancesUseCase(userBalanceFetcher: userWalletRepository),
            getFeeUseCase: CountBasedDecoratorGetExchangeFeeUseCase(
                countFetcher: countFetcher,
                freeLimitCount: 5,
                decoratee: PercentBasedGetExchangeFeeUseCase(percent: 0.007)
            ),
            exchangeMoneyUseCase: ObservingExchangeMoneyUseCaseDecorator(
                decoratee: ExchangeMoneyUseCaseImpl(
                    userWalletRepository: userWalletRepository,
                    bankWalletRepository: BankWalletRepository()
                )
            ) { [weak self] in if $0 { self?.countFetcher.increaseCount()} },
            getExchangedAmountUseCase: RateBasedGetExchangedAmountUseCase(
                exchangeRateFetcher: CachingExchangeRateFetcherDecorator(
                    decoratee: RemoteRateFetcher()
                )
            )
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.mockWallet = wallet
            completion(true)
        }
    }
    
    func fetchWallet(completion: @escaping (Wallet) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
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

private class ObservingExchangeMoneyUseCaseDecorator: ExchangeMoneyUseCase {

    private let decoratee: ExchangeMoneyUseCase
    private let callback: (Bool) -> Void
    
    init(
        decoratee: ExchangeMoneyUseCase,
        callback: @escaping (Bool) -> Void
    ) {
        self.decoratee = decoratee
        self.callback = callback
    }
    
    func exchange(command: ExchangeMoneyCommand, completion: @escaping (Bool) -> Void) {
        decoratee.exchange(command: command) { [weak self] result in
            self?.callback(result)
            completion(result)
        }
    }
}

private class UpdatableCountFetcher: TransactionCountFetcher {
    private var count = 0
    
    func increaseCount() {
        count += 1
    }
    
    func count(for balance: Balance, completion: @escaping (Int) -> Void) {
        completion(count)
    }
}

private class CachingExchangeRateFetcherDecorator: ExchangeRateFetcher {
    
    private var cache: [String:Decimal] = [:]
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

private class RemoteRateFetcher: ExchangeRateFetcher {
    func get(sourceMoney: Money, targetMoney: Money, completion: @escaping (Decimal) -> Void) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "api.evp.lt"
        components.path = "/currency/commercial/exchange/1-\(sourceMoney.currency.code)/\(targetMoney.currency.code)/latest"
        guard let url = components.url else { return completion(1) }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
                  let data = data,
                  let result = try? JSONDecoder().decode(RateResponseDTO.self, from: data) else {
                return DispatchQueue.main.async {
                    completion(1)
                }
            }
            DispatchQueue.main.async {
                completion(Decimal(string: result.amount) ?? 1)                
            }
                
        }
        task.resume()
    }
    
    private struct RateResponseDTO: Decodable {
        let amount: String
    }
}

