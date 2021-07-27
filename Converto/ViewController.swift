import UIKit
import ConvertoKit

final class ViewController: UIViewController {
    
    let convertorView = ConvertorView()
    
    let getBalanceUseCase = GetUserBalancesUseCase()
    let getFeeUseCase = GetExchangeFeeUseCase()
    var exchangeMoneyCommand: Result<ExchangeMoneyCommand, ExchangeMoneyCommand.Error>?
    let exchangeMoneyUseCase = ExchangeMoneyUseCase()
    let getExchangedAmountUseCase = GetExchangedAmountUseCase()
    
    var sourceBalance: Balance? {
        didSet { updateSourceBalance() }
    }
    var targetBalance: Balance? {
        didSet { updateTargetBalance() }
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
    }
    
    private func updateBalances() {
        sourceBalance = getBalanceUseCase.get(currency: .init(id: 1, code: "USD"))
        targetBalance = getBalanceUseCase.get(currency: .init(id: 2, code: "EUR"))
        
        updateFees(amount: enteredAmount(), convertedAmount: 0)
    }
    
    private func updateSourceBalance() {
        convertorView.sourceMoneyField.moneyField.currencyLabel.text = sourceBalance?.money.currency.code
        convertorView.sourceMoneyField.balanceLabel.text = "Available: \(sourceBalance?.money.amount ?? 0)"
    }
    
    private func updateTargetBalance() {
        convertorView.targetMoneyField.moneyField.currencyLabel.text = targetBalance?.money.currency.code
        convertorView.targetMoneyField.balanceLabel.text = "Available: \(targetBalance?.money.amount ?? 0)"
    }
    
    private func updateFees(amount: Decimal, convertedAmount: Decimal) {
        if let sourceBalance = sourceBalance, let targetBalance = targetBalance {
            
            let fees = getFeeUseCase.get(sourceBalance: sourceBalance, targetBalance: targetBalance, amount: amount)
            
            convertorView.feeView.setComposedTitle(bold: "\(fees.amount) \(fees.currency.code)", regular: "commission fee")
            convertorView.feeView.iconView.image = Asset.Icons.sellArrow.image
            
            checkForExchangePossibility(amount: amount, convertedAmount: convertedAmount, fee: fees.amount)
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
            convertorView.convertButton.isEnabled = (try? exchangeMoneyCommand?.get()) != nil
        }
    }
    @objc private func onEchangeButtontap() {
        if let command = try? exchangeMoneyCommand?.get() { exchangeMoneyUseCase.exchange(command: command)
            updateBalances()
            onSourceAmountChange()
        }
    }
    
    @objc private func onSourceAmountChange() {
        
        if let sourceBalance = sourceBalance, let targetBalance = targetBalance {
        let exchangedMoney = getExchangedAmountUseCase.get(sourceBalance: sourceBalance, targetBalance: targetBalance, amount: enteredAmount())
            convertorView.targetMoneyField.moneyField.inputField.text = "\(exchangedMoney.amount)"
            updateFees(amount: enteredAmount(), convertedAmount: exchangedMoney.amount)
        }
    }
    
    private func enteredAmount() -> Decimal {
        Decimal(string: convertorView.sourceMoneyField.moneyField.inputField.text ?? "") ?? 0
    }
}

