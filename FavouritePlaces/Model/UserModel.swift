//
//  UserModel.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 21.10.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import RealmSwift

class User: Object {
    @objc dynamic var uid: String = ""
    @objc dynamic var email: String = ""
    let places = List<Place>()

    convenience init(uid: String, email: String) {
        self.init()
        self.uid = uid
        self.email = email
    }
}