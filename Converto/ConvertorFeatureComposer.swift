import UIKit
import ConvertoDomain

final class ConvertorFeatureComposer {

    var rootController: UIViewController {
        convertorViewController
    }

    private let decimalFormaterProvider = DecimalFormaterProvider()
    private lazy var convertorViewController = makeConvertorViewController()
    private lazy var userWalletRepository: WalletRepository & UserBalanceFetcher = UserWalletRepository()

    private func makeConvertorViewController() -> ConvertorViewController {
        let countFetcher = UpdatableCountFetcher()
        let increaseTargetBalanceCountOnSuccess: (ExchangeMoneyCommand, Bool) -> Void = { if $1 { countFetcher.increaseCount(for: $0.targetBalance) } }
        let sourceCurrency = Currency.makeJpy()
        let targetCurrency = Currency.makeUsd()
        let sourceDecimalFormatter = decimalFormaterProvider.makeDecimalFormatter(for: sourceCurrency)
        let sourceDecimalFieldController = FormattedTextFieldController(twoWayFormatter: sourceDecimalFormatter)

        let controller = ConvertorViewController(decimalFieldController: sourceDecimalFieldController)

        let errorAdapter = ErrorHandlerAdapter()

        let presenter = ConvertorPresenter(
            getBalanceUseCase: GetUserBalancesUseCase(userBalanceFetcher: userWalletRepository),
            getFeeUseCase: LimitBasedGetExchangeFeeUseCaseDecorator(
                countFetcher: countFetcher,
                freeLimitCount: 5,
                decoratee: RoundingGetExchangeFeeUseCaseDecorator(
                    currency: .makeJpy(),
                    decoratee: PercentBasedGetExchangeFeeUseCase(percent: 0.007)
                )
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
                    decoratee: RoundingRateFetcherDecorator(
                        currency: .makeJpy(),
                        decoratee: RemoteRateFetcher(
                            request: ApiRequest(),
                            errorHandler: errorAdapter.handleError
                        )
                    )
                )
            ),
            sourceBalanceFormatter: sourceDecimalFormatter,
            targetBalanceFormatter: decimalFormaterProvider.makeDecimalFormatter(for: targetCurrency),
            inititalSourceCurrency: sourceCurrency,
            inititalTargetCurrency: targetCurrency
        )
        controller.presenter = presenter
        presenter.presantableView = WeakRef(controller)
        
        let errorPresenter = RatesFetcherErrorPresenter()
        errorPresenter.errorView = WeakRef(controller)
        errorAdapter.errorPresenter = errorPresenter
        errorAdapter.convertedView = WeakRef(controller)
        errorAdapter.feeAmountView = WeakRef(controller)
        
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

    private func makeBalanceSelectionViewContorller(excludedBalance: Balance) -> BalanceSelectionViewController {
        BalanceSelectionViewController(
            getUserWalleUseCase: GetUserBalancesForSelectionUseCaseImpl(
                userWalletRepository: ExcludingWalletRepositoryDecorator(
                    decoratee: userWalletRepository,
                    exculedBalance: excludedBalance
                )
            ),
            decimalFormatterForCurrency: decimalFormaterProvider.makeDecimalFormatter
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
            guard let self = self else { return }
            let formatter = self.decimalFormaterProvider.makeDecimalFormatter(for: selectedBalance.money.currency)
            if type.isSource {
                self.convertorViewController.decimalFieldController = FormattedTextFieldController(twoWayFormatter: formatter)
                self.convertorViewController.presenter?.setSource(balance: selectedBalance, formatter: formatter)
            } else {
                self.convertorViewController.presenter?.setTarget(balance: selectedBalance, formatter: formatter)
            }
        }
        rootController.present(
            UINavigationController(rootViewController: balanceSelectionController),
            animated: true
        )
    }
}

extension WeakRef: FeeAmountView where T: FeeAmountView {
    func display(feeAmount: String, description: String, isPositive: Bool) {
        object?.display(feeAmount: feeAmount, description: description, isPositive: isPositive)
    }
}

extension WeakRef: ConvertedAmountView where T: ConvertedAmountView {
    func display(convertedAmount: String) {
        object?.display(convertedAmount: convertedAmount)
    }
}

extension WeakRef: ConvertorPresantableView where T: ConvertorPresantableView {
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
}

extension WeakRef: RatesFetcherErrorView where T: RatesFetcherErrorView {
    func display(errorMessage: String) {
        object?.display(errorMessage: errorMessage)
    }
}

private class ErrorHandlerAdapter {
    
    var convertedView: ConvertedAmountView?
    var feeAmountView: FeeAmountView?
    var errorPresenter: RatesFetcherErrorPresenter?
    
    func handleError(_ error: ApiRequest.Error) {
        errorPresenter?.show(error: error)
        convertedView?.display(convertedAmount: "0")
        feeAmountView?.display(feeAmount: "Can't calculate fee amount", description: "", isPositive: true)
    }
}
