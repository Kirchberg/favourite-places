//
//  PlaceModel.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 11.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import UIKit

struct Place {
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var restaurantImage: String?
    static let restaurantNames: [String] = ["Mirazur",
                                            "Noma",
                                            "Asador",
                                            "Gaggan",
                                            "Geranium",
                                            "Central",
                                            "Mugaritz",
                                            "Maido",
                                            "Arpege",
                                            "Disfutar"]
    static func getPlaces() -> [Place] {
        var places = [Place]()
        for place in restaurantNames {
            places.append(Place(name: place,
                                location: "Moscow",
                                type: "Restaurant",
                                image: nil,
                                restaurantImage: place))
        }
        return places
    }
}
