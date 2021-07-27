//
//  SceneDelegate.swift
//  Converto
//
//  Created by alex.oleynyk on 26.07.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    lazy var rootController = UINavigationController(
        rootViewController: ViewController(
            getBalanceUseCase: GetUserBalancesUseCase(),
            getFeeUseCase: GetExchangeFeeUseCase(),
            exchangeMoneyUseCase: ExchangeMoneyUseCase(),
            getExchangedAmountUseCase: GetExchangedAmountUseCase()
        )
    )

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.rootViewController = rootController
        window.makeKeyAndVisible()
    }
}

