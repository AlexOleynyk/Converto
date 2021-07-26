//
//  ViewController.swift
//  Converto
//
//  Created by alex.oleynyk on 26.07.2021.
//

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
        // Do any additional setup after loading the view.
    }


}

