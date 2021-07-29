import UIKit

public final class TitledMoneyField: UIView {

    public let titleView = TitleView()

    public let balanceLabel = setup(UILabel()) {
        $0.textColor = Asset.Colors.gray700.color
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }

    public let moneyField = MoneyField()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Asset.Colors.background.color

        addSubview(titleView, constraints: [
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleView.topAnchor.constraint(equalTo: topAnchor, constant: 12)
        ])
        titleView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        addSubview(balanceLabel, constraints: [
            balanceLabel.leadingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: 12),
            balanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            balanceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12)
        ])
        balanceLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        balanceLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        addSubview(moneyField, constraints: [
            moneyField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            moneyField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            moneyField.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 8),
            moneyField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
