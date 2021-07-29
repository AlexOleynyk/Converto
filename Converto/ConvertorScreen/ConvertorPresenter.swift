import Foundation
import ConvertoDomain

protocol ConvertedAmountView {
    func display(convertedAmount: String)
}

protocol FeeAmountView {
    func display(feeAmount: String, description: String, isPositive: Bool)
}

protocol ConvertorPresantableView: ConvertedAmountView, FeeAmountView {
    func display(isLoading: Bool)
    func display(buttonIsEnabled: Bool)
    func display(sourceBalanceAmount: String, currency: String)
    func display(targetBalanceAmount: String, currency: String)
}

final class ConvertorPresenter {
    var presantableView: ConvertorPresantableView?

    var sourceBalance: Balance? {
        didSet { updateSourceBalance() }
    }
    var targetBalance: Balance? {
        didSet { updateTargetBalance() }
    }

    private let getBalanceUseCase: GetUserBalancesUseCase
    private let getFeeUseCase: GetExchangeFeeUseCase
    private let exchangeMoneyUseCase: ExchangeMoneyUseCase
    private let getExchangedAmountUseCase: GetExchangedAmountUseCase
    private let decimalFormatter: DecimalTwoWayFormatter
    private let inititalSourceCurrency: Currency
    private let inititalTargetCurrency: Currency
    
    private var exchangeMoneyCommand: Result<ExchangeMoneyCommand, ExchangeMoneyCommand.Error>?
    private var enteredAmount: Decimal = 0

    init(
        getBalanceUseCase: GetUserBalancesUseCase,
        getFeeUseCase: GetExchangeFeeUseCase,
        exchangeMoneyUseCase: ExchangeMoneyUseCase,
        getExchangedAmountUseCase: GetExchangedAmountUseCase,
        decimalFormatter: DecimalTwoWayFormatter,
        inititalSourceCurrency: Currency,
        inititalTargetCurrency: Currency
    ) {
        self.getBalanceUseCase = getBalanceUseCase
        self.getFeeUseCase = getFeeUseCase
        self.exchangeMoneyUseCase = exchangeMoneyUseCase
        self.getExchangedAmountUseCase = getExchangedAmountUseCase
        self.decimalFormatter = decimalFormatter
        self.inititalSourceCurrency = inititalSourceCurrency
        self.inititalTargetCurrency = inititalTargetCurrency
    }

    func updateBalances() {
        presantableView?.display(isLoading: true)
        getBalanceUseCase.get(currency: sourceBalance?.money.currency ?? inititalSourceCurrency) { [weak self] in
            self?.sourceBalance = $0
            self?.presantableView?.display(isLoading: false)
        }
        getBalanceUseCase.get(currency: targetBalance?.money.currency ?? inititalTargetCurrency) { [weak self] in
            self?.targetBalance = $0
            self?.presantableView?.display(isLoading: false)
        }

        updateFees(amount: enteredAmount, convertedAmount: 0)
    }

    func exchangeMoney() {
        if let command = try? exchangeMoneyCommand?.get() {
            presantableView?.display(isLoading: true)
            exchangeMoneyUseCase.exchange(command: command) { [weak self] success in
                self?.presantableView?.display(isLoading: false)
                guard success else { return }
                self?.updateBalances()
                self?.updateExchangedAmount()
            }
        }
    }

    func onSourceAmountChange(amount: String) {
        enteredAmount = decimalFormatter.fromString(amount) ?? 0
        updateExchangedAmount()
    }

    private func updateSourceBalance() {
        presantableView?.display(
            sourceBalanceAmount: "Available: \(sourceBalance?.money.amount ?? 0)",
            currency: sourceBalance?.money.currency.code ?? ""
        )
        updateExchangedAmount()
    }

    private func updateTargetBalance() {
        presantableView?.display(
            targetBalanceAmount: "Available: \(targetBalance?.money.amount ?? 0)",
            currency: targetBalance?.money.currency.code ?? ""
        )
        updateExchangedAmount()
    }

    private func updateFees(amount: Decimal, convertedAmount: Decimal) {
        if let sourceBalance = sourceBalance, let targetBalance = targetBalance {

            getFeeUseCase.get(sourceBalance: sourceBalance, targetBalance: targetBalance, amount: amount) { [weak self] fees in
                self?.presantableView?.display(
                    feeAmount: "\(fees.amount) \(fees.currency.code)",
                    description: fees.amount > 0 ? "Commission fee" : "No fee commission",
                    isPositive: fees.amount > 0
                )

                self?.checkForExchangePossibility(amount: amount, convertedAmount: convertedAmount, fee: fees.amount)
            }
        }
    }

    private func checkForExchangePossibility(
        amount: Decimal,
        convertedAmount: Decimal,
        fee: Decimal
    ) {
        if let sourceBalance = sourceBalance, let targetBalance = targetBalance {
            exchangeMoneyCommand = ExchangeMoneyCommand.make(
                sourceBalance: sourceBalance,
                targetBalance: targetBalance,
                amount: amount,
                convertedAmount: convertedAmount,
                fee: fee
            )
            presantableView?.display(buttonIsEnabled: (try? exchangeMoneyCommand?.get()) != nil)
        }
    }

    private func updateExchangedAmount() {
        if let sourceBalance = sourceBalance, let targetBalance = targetBalance {
            getExchangedAmountUseCase.get(sourceBalance: sourceBalance, targetBalance: targetBalance, amount: enteredAmount) { [weak self] in
                self?.presantableView?.display(convertedAmount: self?.decimalFormatter.toString($0.amount) ?? "")
                self?.updateFees(amount: self?.enteredAmount ?? 0, convertedAmount: $0.amount)

            }
        }
    }
}
