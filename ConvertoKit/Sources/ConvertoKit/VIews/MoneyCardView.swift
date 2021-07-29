import UIKit

public final class MoneyCardView: UIView {
    public var isSelected: Bool = false {
        didSet { updateAppearance() }
    }

    public let amountLabel = setup(UILabel()) {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = Asset.Colors.gray900.color
    }

    public let currencyLabel = setup(UILabel()) {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = Asset.Colors.gray900.color
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        let stack = setup(UIStackView(arrangedSubviews: [amountLabel, currencyLabel])) {
            $0.spacing = 8
        }

        addSubview(stack, constraints: [
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        amountLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        currencyLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        currencyLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        layer.cornerRadius = 8
        layer.borderWidth = 2

        updateAppearance()
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateAppearance()
    }

    private func updateAppearance() {
        layer.borderColor = isSelected
            ? Asset.Colors.blue500.color.cgColor
            : Asset.Colors.blue200.color.cgColor
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
