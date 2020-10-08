//
//  SceneDelegate.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 06.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//
import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        configureInitialRootViewController(scene)
    }

    private func configureInitialRootViewController(_ scene: UIScene) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)

        let initialViewController: UIViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.window = window

        if UserDefaults.standard.isLoggedIn() {
            let mainViewController = storyboard.instantiateViewController(withIdentifier: "mainForm")
            initialViewController = mainViewController
        } else {
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "loginForm")
            initialViewController = loginViewController
        }

        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }
}
