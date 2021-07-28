import UIKit
import ConvertoKit

final class ConvertorViewController: UIViewController {
    
    enum CurrencySelectionType {
        case source
        case target
        
        var isSource: Bool { self == .source }
    }
    
    let convertorView = ConvertorView()
    
    let getBalanceUseCase: GetUserBalancesUseCase
    let getFeeUseCase: GetExchangeFeeUseCase
    let exchangeMoneyUseCase: ExchangeMoneyUseCase
    let getExchangedAmountUseCase: GetExchangedAmountUseCase
    
    var exchangeMoneyCommand: Result<ExchangeMoneyCommand, ExchangeMoneyCommand.Error>?
    
    var onCurrencySelectionTap: ((CurrencySelectionType, Balance, Balance) -> Void)?

    var sourceBalance: Balance? {
        didSet { updateSourceBalance() }
    }
    var targetBalance: Balance? {
        didSet { updateTargetBalance() }
    }
    
    init(
        getBalanceUseCase: GetUserBalancesUseCase,
        getFeeUseCase: GetExchangeFeeUseCase,
        exchangeMoneyUseCase: ExchangeMoneyUseCase,
        getExchangedAmountUseCase: GetExchangedAmountUseCase
    ) {
        self.getBalanceUseCase = getBalanceUseCase
        self.getFeeUseCase = getFeeUseCase
        self.exchangeMoneyUseCase = exchangeMoneyUseCase
        self.getExchangedAmountUseCase = getExchangedAmountUseCase
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = convertorView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Currency converter"
        
        
        updateBalances()
        convertorView.convertButton.setTitle("Exchange", for: [])
        
        convertorView.sourceMoneyField.moneyField.inputField.placeholder = "0.00"
        convertorView.sourceMoneyField.titleView.titleLabel.text = "Sell"
        convertorView.sourceMoneyField.titleView.iconView.image = Asset.Icons.sellArrow.image
 
        convertorView.targetMoneyField.moneyField.inputField.placeholder = "0.00"
        convertorView.targetMoneyField.titleView.titleLabel.text = "Receive"
        convertorView.targetMoneyField.titleView.iconView.image = Asset.Icons.sellArrow.image
        
        convertorView.sourceMoneyField.moneyField.inputField.addTarget(self, action: #selector(onSourceAmountChange), for: .editingChanged)
        convertorView.convertButton.addTarget(self, action: #selector(onEchangeButtontap), for: .primaryActionTriggered)
        convertorView.sourceMoneyField.moneyField.addTarget(self, action: #selector(onCurrencySelectionTap(_:)), for: .touchUpInside)
        convertorView.targetMoneyField.moneyField.addTarget(self, action: #selector(onCurrencySelectionTap(_:)), for: .touchUpInside)
    }
    
    private func updateBalances() {
        getBalanceUseCase.get(currency: sourceBalance?.money.currency ?? .init(id: 2, code: "EUR")) { [weak self] in
            self?.sourceBalance = $0
        }
        getBalanceUseCase.get(currency: targetBalance?.money.currency ?? .init(id: 1, code: "USD")) { [weak self] in
            self?.targetBalance = $0
        }
        
        updateFees(amount: enteredAmount(), convertedAmount: 0)
    }
    //
    private func updateSourceBalance() {
        convertorView.sourceMoneyField.moneyField.currencyLabel.text = sourceBalance?.money.currency.code
        convertorView.sourceMoneyField.balanceLabel.text = "Available: \(sourceBalance?.money.amount ?? 0)"
    }
    //
    private func updateTargetBalance() {
        convertorView.targetMoneyField.moneyField.currencyLabel.text = targetBalance?.money.currency.code
        convertorView.targetMoneyField.balanceLabel.text = "Available: \(targetBalance?.money.amount ?? 0)"
    }
    //
    
    private func updateFees(amount: Decimal, convertedAmount: Decimal) {
        if let sourceBalance = sourceBalance, let targetBalance = targetBalance {
            
            getFeeUseCase.get(sourceBalance: sourceBalance, targetBalance: targetBalance, amount: amount) { [weak self] in
                let fees = $0
                //
                self?.convertorView.feeView.setComposedTitle(bold: "\(fees.amount) \(fees.currency.code)", regular: "commission fee")
                self?.convertorView.feeView.iconView.image = Asset.Icons.sellArrow.image
                //
                
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
            //
            convertorView.convertButton.isEnabled = (try? exchangeMoneyCommand?.get()) != nil
            //
        }
    }
    @objc private func onEchangeButtontap() {
        if let command = try? exchangeMoneyCommand?.get() {
            //
            convertorView.convertButton.isLoading = true
            //
            exchangeMoneyUseCase.exchange(command: command) { [weak self] success in
                //
                self?.convertorView.convertButton.isLoading = false
                //
                guard success else { return }
                self?.updateBalances()
                self?.onSourceAmountChange()
            }
        }
    }
    
    @objc private func onSourceAmountChange() {
        
        if let sourceBalance = sourceBalance, let targetBalance = targetBalance {
            getExchangedAmountUseCase.get(sourceBalance: sourceBalance, targetBalance: targetBalance, amount: enteredAmount()) { [weak self] in
                //
                self?.convertorView.targetMoneyField.moneyField.inputField.text = "\($0.amount)"
                //
                self?.updateFees(amount: self?.enteredAmount() ?? 0, convertedAmount: $0.amount)
                
            }
        }
    }
    
    @objc private func onCurrencySelectionTap(_ moneyField: MoneyField) {
        if let sourceBalance = sourceBalance, let targetBalance = targetBalance {
            let type: CurrencySelectionType = moneyField == convertorView.targetMoneyField.moneyField ? .target : .source
            onCurrencySelectionTap?(type, sourceBalance, targetBalance)
        }
    }
    
    private func enteredAmount() -> Decimal {
        Decimal(string: convertorView.sourceMoneyField.moneyField.inputField.text ?? "") ?? 0
    }
}

