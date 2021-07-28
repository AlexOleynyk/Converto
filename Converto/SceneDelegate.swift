import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
  

    private lazy var rootController = UINavigationController(
        rootViewController: convertorViewController
    )
    
    private lazy var convertorViewController = makeConvertorViewController()
    private lazy var userWalletRepository = UserWalletRepository()
    
    private func makeConvertorViewController() -> ConvertorViewController {
        let countFetcher = UpdatableCountFetcher()
        let increaseTargetBalanceCountOnSuccess: (ExchangeMoneyCommand, Bool) -> Void = { if $1 { countFetcher.increaseCount(for: $0.targetBalance) } }
        let controller = ConvertorViewController(
            getBalanceUseCase: GetUserBalancesUseCase(userBalanceFetcher: userWalletRepository),
            getFeeUseCase: CountBasedDecoratorGetExchangeFeeUseCase(
                countFetcher: countFetcher,
                freeLimitCount: 2,
                decoratee: PercentBasedGetExchangeFeeUseCase(percent: 0.007)
            ),
            exchangeMoneyUseCase: ObservingExchangeMoneyUseCaseDecorator(
                decoratee: ExchangeMoneyUseCaseImpl(
                    userWalletRepository: userWalletRepository,
                    bankWalletRepository: BankWalletRepository()
                ),
                callback: increaseTargetBalanceCountOnSuccess
            ),
            getExchangedAmountUseCase: RateBasedGetExchangedAmountUseCase(
                exchangeRateFetcher: CachingExchangeRateFetcherDecorator(
                    decoratee: RemoteRateFetcher()
                )
            )
        )
        controller.onCurrencySelectionTap = routeToBalanceSelection
        return controller
    }
    
    private func makeBalanceSelectionViewContorller(excludedBalance: Balance) -> BalanceSelectionViewContorller {
        BalanceSelectionViewContorller(
            getUserWalleUseCase: GetUserBalancesForSelectionUseCaseImpl(
                userWalletRepository: ExcludingWalletRepositoryDecorator(
                    decoratee: userWalletRepository,
                    exculedBalance: excludedBalance
                )
            )
        )
    }
    
    private func routeToBalanceSelection(
        with type: ConvertorViewController.CurrencySelectionType,
        sourceBalance: Balance,
        targetBalance: Balance
    ) {
        let selectedBalance = type.isSource ? sourceBalance : targetBalance
        let excludedBalance = type.isSource ? targetBalance : sourceBalance
        let balanceSelectionController =  makeBalanceSelectionViewContorller(excludedBalance: excludedBalance)
        balanceSelectionController.shouldDimmZeroBalances = type.isSource
        balanceSelectionController.selectedBalance = selectedBalance
        balanceSelectionController.onBalanceSelected = { [weak self] selectedBalance in
            if type.isSource {
                self?.convertorViewController.sourceBalance = selectedBalance
            } else {
                self?.convertorViewController.targetBalance = selectedBalance
            }
        }
        rootController.present(
            UINavigationController(rootViewController: balanceSelectionController),
            animated: true
        )
    }

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
        Balance(id: 1, money: Money(amount: 0, currency: Currency(id: 1, code: "USD"))),
        Balance(id: 2, money: Money(amount: 1000, currency: Currency(id: 2, code: "EUR"))),
        Balance(id: 3, money: Money(amount: 0, currency: Currency(id: 3, code: "JPY")))
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

private class ExcludingWalletRepositoryDecorator: WalletRepository {
    
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
            let newWallet = Wallet(balances: wallet.balances.filter { $0.id != self?.exculedBalance.id } )
            completion(newWallet)
        })
    }
    
}

private class BankWalletRepository: WalletRepository {
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

private class ObservingExchangeMoneyUseCaseDecorator: ExchangeMoneyUseCase {

    private let decoratee: ExchangeMoneyUseCase
    private let callback: (ExchangeMoneyCommand, Bool) -> Void
    
    init(
        decoratee: ExchangeMoneyUseCase,
        callback: @escaping (ExchangeMoneyCommand, Bool) -> Void
    ) {
        self.decoratee = decoratee
        self.callback = callback
    }
    
    func exchange(command: ExchangeMoneyCommand, completion: @escaping (Bool) -> Void) {
        decoratee.exchange(command: command) { [weak self] result in
            self?.callback(command, result)
            completion(result)
        }
    }
}

private class UpdatableCountFetcher: TransactionCountFetcher {
    private var countStorage: [Int:Int] = [:]
    
    
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

