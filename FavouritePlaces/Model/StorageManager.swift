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
            place.id = StorageManager.incrementID()
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

    static func appendUserPlaceObject(to user: User, add place: Place) {
        try! realm.write {
            user.places.append(place)
        }
    }

    /// Update information about place
    /// - Parameters:
    ///   - oldPlace: Place that contains old information
    ///   - newPlace: Place that contains new information
    static func updatePlaceObject(update oldPlace: Place, to newPlace: Place) {
        try! realm.write {
            oldPlace.name = newPlace.name
            oldPlace.location = newPlace.location
            oldPlace.type = newPlace.type
            oldPlace.imageData = newPlace.imageData
            oldPlace.descriptionString = newPlace.descriptionString
            oldPlace.rating = newPlace.rating
        }
    }

    private static func incrementID() -> Int {
        (realm.objects(Place.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}
