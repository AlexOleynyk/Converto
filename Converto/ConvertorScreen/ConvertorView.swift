import UIKit
import ConvertoKit

final class ConvertorView: UIView {
    let container = setup(UIView()) {
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = Asset.Colors.blue200.color.cgColor
        $0.layer.borderWidth = 2
    }

    let sourceMoneyField = TitledMoneyField()
    let targetMoneyField = setup(TitledMoneyField()) {
        $0.moneyField.inputField.isUserInteractionEnabled = false
    }
    let feeView = TitleView()

    let convertButton = PrimaryButton()
    private var bottomConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = Asset.Colors.background.color

        let stack = setup(UIStackView(arrangedSubviews: [
            sourceMoneyField,
            makeSeparator(),
            targetMoneyField,
            makeSeparator(),
            wrappedView(feeView, insets: .init(top: 12, left: 12, bottom: 12, right: 12))
        ])) {
            $0.axis = .vertical
        }

        container.addSubview(stack, constraints: [
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        addSubview(container, constraints: [
            container.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])

        bottomConstraint = convertButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        addSubview(convertButton, constraints: [
            convertButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            convertButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            bottomConstraint
        ])

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        container.layer.borderColor = Asset.Colors.blue200.color.cgColor
    }

    private func makeSeparator() -> UIView {
        setup(UIView()) {
            $0.backgroundColor = Asset.Colors.blue200.color
            $0.addConstraint($0.heightAnchor.constraint(equalToConstant: 2))
        }
    }

    private func wrappedView(_ view: UIView, insets: UIEdgeInsets) -> UIView {
        let wrapper = UIView()
        wrapper.addSubview(view, constraints: [
            view.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: insets.top),
            view.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: insets.left),
            view.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -insets.right),
            view.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -insets.bottom)
        ])
        return wrapper
    }

    @objc func onTap() {
            endEditing(true)
    }

    func adjustForKeyboardHeight(height: CGFloat) {
        bottomConstraint.constant = height == 0 ? -20 : -height - 20  + safeAreaInsets.bottom
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
