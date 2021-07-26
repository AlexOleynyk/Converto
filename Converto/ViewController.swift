import UIKit
import ConvertoKit

class ViewController: UIViewController {
    
    let button = PrimaryButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        button.setTitle("test", for: [])
        view.addSubview(button, constraints: [
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        
        button.addTarget(self, action: #selector(toogleLoading), for: .primaryActionTriggered)
    }

    @objc private func toogleLoading() {
        button.isLoading.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [button] in
            button.isLoading.toggle()
        }
    }
}

