//
//  UserModel.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 21.10.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import Foundation

class User {
    var uid: String = ""
    var email: String = ""

    convenience init(uid: String, email: String) {
        self.init()
        self.uid = uid
        self.email = email
    }
}
