import UIKit
import ConvertoKit

final class ConvertorViewController: UIViewController {

    enum CurrencySelectionType {
        case source
        case target

        var isSource: Bool { self == .source }
    }

    var onCurrencySelectionTap: ((CurrencySelectionType) -> Void)?
    var presenter: ConvertorPresenter?

    private let decimalFieldController: UITextFieldDelegate
    private let convertorView = ConvertorView()

    init(decimalFieldController: UITextFieldDelegate) {
        self.decimalFieldController = decimalFieldController
        super.init(nibName: nil, bundle: nil)
        self.convertorView.sourceMoneyField.moneyField.inputField.delegate = decimalFieldController
    }

    override func loadView() {
        view = convertorView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Currency converter"
        configureView()
        registerForKeyboardEvents()
        presenter?.updateBalances()
    }

    private func configureView() {
        convertorView.convertButton.setTitle("Exchange", for: [])

        convertorView.sourceMoneyField.moneyField.inputField.placeholder = "0.00"
        convertorView.sourceMoneyField.titleView.titleLabel.text = "Sell"
        convertorView.sourceMoneyField.titleView.iconView.image = Asset.Icons.sellArrow.image

        convertorView.targetMoneyField.moneyField.inputField.placeholder = "0.00"
        convertorView.targetMoneyField.titleView.titleLabel.text = "Receive"
        convertorView.targetMoneyField.titleView.iconView.image = Asset.Icons.receiveArrow.image

        convertorView.feeView.iconView.image = Asset.Icons.feeCommission.image

        convertorView.sourceMoneyField.moneyField.inputField
            .addTarget(self, action: #selector(onSourceAmountChange), for: .editingChanged)
        convertorView.convertButton
            .addTarget(self, action: #selector(onEchangeButtontap), for: .primaryActionTriggered)
        convertorView.sourceMoneyField.moneyField
            .addTarget(self, action: #selector(onCurrencySelectionTap(_:)), for: .touchUpInside)
        convertorView.targetMoneyField.moneyField
            .addTarget(self, action: #selector(onCurrencySelectionTap(_:)), for: .touchUpInside)
    }

    @objc private func onEchangeButtontap() {
        presenter?.exchangeMoney()
    }

    @objc private func onSourceAmountChange() {
        presenter?.onSourceAmountChange(amount: convertorView.sourceMoneyField.moneyField.inputField.text ?? "")
    }

    @objc private func onCurrencySelectionTap(_ moneyField: MoneyField) {
        let type: CurrencySelectionType = moneyField == convertorView.targetMoneyField.moneyField ? .target : .source
        onCurrencySelectionTap?(type)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ConvertorViewController: ConvertorPresantableView {
    func display(buttonIsEnabled: Bool) {
        convertorView.convertButton.isEnabled = buttonIsEnabled
    }

    func display(isLoading: Bool) {
        convertorView.convertButton.isLoading = isLoading
    }

    func display(convertedAmount: String) {
        convertorView.targetMoneyField.moneyField.inputField.text = convertedAmount
    }

    func display(sourceBalanceAmount: String, currency: String) {
        convertorView.sourceMoneyField.balanceLabel.text = sourceBalanceAmount
        convertorView.sourceMoneyField.moneyField.currencyLabel.text = currency
    }

    func display(targetBalanceAmount: String, currency: String) {
        convertorView.targetMoneyField.balanceLabel.text = targetBalanceAmount
        convertorView.targetMoneyField.moneyField.currencyLabel.text = currency
    }

    func display(feeAmount: String, description: String, isPositive: Bool) {
        if isPositive {
            convertorView.feeView.setComposedTitle(bold: feeAmount, regular: description)
            convertorView.feeView.iconView.tintColor = Asset.Colors.red500.color
        } else {
            convertorView.feeView.iconView.tintColor = Asset.Colors.green500.color
            convertorView.feeView.titleLabel.text = description
        }
    }
}

extension ConvertorViewController: RatesFetcherErrorView {
    func display(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }
}

extension ConvertorViewController: KeyboardObserving {
    func keyboardWillShow(_ notification: Notification) {
        convertorView.adjustForKeyboardHeight(height: notification.keyboardSize?.height ?? 0)
    }

    func keyboardWillHide(_ notification: Notification) {
        convertorView.adjustForKeyboardHeight(height: 0)
    }
}
