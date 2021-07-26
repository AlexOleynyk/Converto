import UIKit
import ConvertoKit

class ViewController: UIViewController {
    
    let field = MoneyField()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(field, constraints: [
            field.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            field.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            field.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        field.addTarget(self, action: #selector(toogleLoading), for: .touchUpInside)
    }

    @objc private func toogleLoading() {
        field.currencyLabel.text = "USD"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [field] in
            field.currencyLabel.text = "EUR"
        }
    }
}

