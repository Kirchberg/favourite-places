//
//  UserDefaultsHelper.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 08.10.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum UserDefaultKeys: String {
        case isLoggedIn
    }

    func setIsLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultKeys.isLoggedIn.rawValue)
        synchronize()
    }

    func isLoggedIn() -> Bool {
        bool(forKey: UserDefaultKeys.isLoggedIn.rawValue)
    }
}
