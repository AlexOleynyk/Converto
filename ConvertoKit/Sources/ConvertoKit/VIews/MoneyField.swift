import UIKit

public final class MoneyField: UIControl {
    
    public let inputField: UITextField = setup(PaddingTextField()) {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = Asset.Colors.gray900.color
        $0.tintColor = Asset.Colors.blue500.color
        $0.backgroundColor = Asset.Colors.blue200.color
        $0.keyboardType = .decimalPad
        $0.padding = .init(top: 8, left: 12, bottom: 8, right: 12)
    }
    
    public let currencyLabel = setup(UILabel()) {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = Asset.Colors.blue500.color
    }
    
    private let currencyContainerView = setup(UIView()) {
        $0.backgroundColor = Asset.Colors.blue200.color
    }
    
    private let currencySelectionImageView = setup(UIImageView()) {
        $0.image = Asset.Icons.chevronDown.image
        $0.tintColor = Asset.Colors.blue500.color
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(inputField, constraints: [
            inputField.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputField.topAnchor.constraint(equalTo: topAnchor),
            inputField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        inputField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        inputField.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        currencyContainerView.addSubview(currencyLabel, constraints: [
            currencyLabel.leadingAnchor.constraint(equalTo: currencyContainerView.leadingAnchor, constant: 10),
            currencyLabel.topAnchor.constraint(equalTo: currencyContainerView.topAnchor),
            currencyLabel.bottomAnchor.constraint(equalTo: currencyContainerView.bottomAnchor)
        ])
        
        currencyContainerView.addSubview(currencySelectionImageView, constraints: [
            currencySelectionImageView.leadingAnchor.constraint(equalTo: currencyLabel.trailingAnchor, constant: 6),
            currencySelectionImageView.centerYAnchor.constraint(equalTo: currencyLabel.centerYAnchor),
            currencySelectionImageView.widthAnchor.constraint(equalToConstant: 12),
            currencySelectionImageView.trailingAnchor.constraint(equalTo: currencyContainerView.trailingAnchor, constant: -10)
        ])
        
        
        addSubview(currencyContainerView, constraints: [
            currencyContainerView.leadingAnchor.constraint(equalTo: inputField.trailingAnchor, constant: 2),
            currencyContainerView.topAnchor.constraint(equalTo: topAnchor),
            currencyContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            currencyContainerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        currencyLabel.setContentHuggingPriority(.required, for: .horizontal)
        currencyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onCurrencyTap))
        currencyContainerView.addGestureRecognizer(tapRecognizer)
        
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    @objc private func onCurrencyTap() {
        sendActions(for: .touchUpInside)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


private class PaddingTextField: UITextField {

    var padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
