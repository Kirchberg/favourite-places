//
//  AppDelegate.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 06.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import Firebase
import RealmSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let schemaVersion: UInt64 = 8

        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: schemaVersion,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < schemaVersion {
                    var nextID = 0
                    migration.enumerateObjects(ofType: Place.className()) { _, newObject in
                        newObject!["id"] = nextID
                        nextID += 1
                    }
                }
            }
        )

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

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
