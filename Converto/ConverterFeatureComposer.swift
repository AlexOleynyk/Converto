import UIKit
import ConvertoDomain

final class ConverterFeatureComposer {

    var rootController: UIViewController {
        convertorViewController
    }

    private lazy var convertorViewController = makeConvertorViewController()
    private lazy var userWalletRepository: WalletRepository & UserBalanceFetcher = UserWalletRepository()

    private func makeConvertorViewController() -> ConvertorViewController {
        let countFetcher = UpdatableCountFetcher()
        let increaseTargetBalanceCountOnSuccess: (ExchangeMoneyCommand, Bool) -> Void = { if $1 { countFetcher.increaseCount(for: $0.targetBalance) } }
        let decimalFormatter = DecimalTwoWayFormatter()
        let decimalFieldController = FormattedTextFieldController(twoWayFormatter: decimalFormatter)

        let controller = ConvertorViewController(decimalFieldController: decimalFieldController)
        
        let errorPresenter = RatesFetcherErrorPresenter()
        errorPresenter.erorrView = WeakRef(controller)

        let presenter = ConvertorPresenter(
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
                    decoratee: RemoteRateFetcher(
                        request: ApiRequest(),
                        errorHandler: errorPresenter.show
                    )
                )
            ),
            decimalFormatter: decimalFormatter
        )
        controller.presenter = presenter
        presenter.presantableView = WeakRef(controller)
        controller.onCurrencySelectionTap = { type in
            guard let sourceBalance = presenter.sourceBalance, let targetBalance = presenter.targetBalance else { return }
            self.routeToBalanceSelection(
                with: type,
                sourceBalance: sourceBalance,
                targetBalance: targetBalance
            )
        }

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
        let balanceSelectionController = makeBalanceSelectionViewContorller(excludedBalance: excludedBalance)
        balanceSelectionController.shouldDimmZeroBalances = type.isSource
        balanceSelectionController.selectedBalance = selectedBalance
        balanceSelectionController.onBalanceSelected = { [weak self] selectedBalance in
            if type.isSource {
                self?.convertorViewController.presenter?.sourceBalance = selectedBalance
            } else {
                self?.convertorViewController.presenter?.targetBalance = selectedBalance
            }
        }
        rootController.present(
            UINavigationController(rootViewController: makeConvertorViewController()),
            animated: true
        )
    }
}

extension WeakRef: ConvertorPresantableView where T: ConvertorPresantableView {
    func display(convertedAmount: String) {
        object?.display(convertedAmount: convertedAmount)
    }

    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }

    func display(buttonIsEnabled: Bool) {
        object?.display(buttonIsEnabled: buttonIsEnabled)
    }

    func display(sourceBalanceAmount: String, currency: String) {
        object?.display(sourceBalanceAmount: sourceBalanceAmount, currency: currency)
    }

    func display(targetBalanceAmount: String, currency: String) {
        object?.display(targetBalanceAmount: targetBalanceAmount, currency: currency)
    }

    func display(feeAmount: String, description: String, isPositive: Bool) {
        object?.display(feeAmount: feeAmount, description: description, isPositive: isPositive)
    }
}

extension WeakRef: RatesFetcherErrorView where T: RatesFetcherErrorView {
    func display(errorMessage: String) {
        object?.display(errorMessage: errorMessage)
    }
}
