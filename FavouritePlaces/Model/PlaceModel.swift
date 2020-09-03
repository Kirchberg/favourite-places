//
//  PlaceModel.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 11.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import RealmSwift

class Place: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var descriptionString: String?
    @objc dynamic var rating = 0.0
    @objc dynamic var date = Date()

    convenience init(name: String, location: String?, type: String?, imageData: Data?, descriptionString: String?, rating: Double) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.descriptionString = descriptionString
        self.rating = rating
    }
}
