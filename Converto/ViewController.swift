import UIKit
import ConvertoKit

class ViewController: UIViewController {
    
    let field = TitledMoneyField()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(field, constraints: [
            field.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            field.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            field.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        field.moneyField.addTarget(self, action: #selector(toogleLoading), for: .touchUpInside)
        
        field.moneyField.currencyLabel.text = "USD"
        field.titleView.setComposedTitle(bold: "Sell", regular: "No fee")
        field.titleView.iconView.image = Asset.Icons.sellArrow.image
        field.balanceLabel.text = "Available: 1000.00"
    }

    @objc private func toogleLoading() {
        field.moneyField.currencyLabel.text = "EUR"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [field] in
            field.moneyField.currencyLabel.text = "USD"
        }
    }
}

