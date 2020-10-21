//
//  AppDelegate.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 06.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import Firebase
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true

        configureInitialViewController()

        return true
    }

    private func configureInitialViewController() {
        let initialViewController: UIViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        window = UIWindow()

        if UserDefaults.standard.isLoggedIn() {
            let mainViewController = storyboard.instantiateViewController(withIdentifier: "mainForm")
            initialViewController = mainViewController
        } else {
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "loginForm")
            initialViewController = loginViewController
        }
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
    }
}
