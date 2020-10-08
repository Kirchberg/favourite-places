//
//  StorageManager.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 13.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    static func savePlaceObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }

    static func deletePlaceObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }

    static func saveUserObject(_ user: User) {
        try! realm.write {
            realm.add(user)
        }
    }
}
