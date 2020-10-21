//
//  PlaceModel.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 11.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import Foundation

class Place {
    var placeID = ""
    var uid: String = ""
    var name: String = ""
    var location: String?
    var type: String?
    var imageData: Data?
    var imageURL: String?
    var descriptionString: String?
    var rating = 0.0
    var date = Date()

    convenience init(uid: String, placeID: String, name: String, location: String?, type: String?, imageData: Data?, imageURL: String?, descriptionString: String?, rating: Double) {
        self.init()
        self.uid = uid
        self.placeID = placeID
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.imageURL = imageURL
        self.descriptionString = descriptionString
        self.rating = rating
    }
}
