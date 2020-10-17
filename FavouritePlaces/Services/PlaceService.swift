//
//  PlaceService.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 17.10.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import Firebase
import FirebaseDatabase
import Foundation

struct PlaceService {
    private static let ref = Database.database().reference().child("Places")
    private static var storageRef = Storage.storage().reference().child("placePhotos")

    static func saveNewPlace(_ place: Place) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef = storageRef.child("\(place.placeID)\(place.uid)")
        storageRef.putData(place.imageData!, metadata: metadata) { metadata, error in
            if let error = error {
                print(error.localizedDescription)
            }

            guard let _ = metadata else { return }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                }

                let nilImageURL = "https://firebasestorage.googleapis.com/v0/b/coursework-favourite-places.appspot.com/o/placePhotos%2FimagePlaceholder%403x.png?alt=media&token=a15b8b99-7f5b-49ec-a0d2-cd33d64c659e"

                let placeInfo: [String: Any] = [
                    "placeID": place.placeID,
                    "userID": place.uid,
                    "Name": place.name,
                    "Location": place.location ?? "",
                    "Type": place.type ?? "",
                    "Image": url?.absoluteString ?? nilImageURL,
                    "Description": place.descriptionString ?? "",
                    "Rating": place.rating,
                ]

                ref.child(place.placeID).updateChildValues(placeInfo) { error, _ in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
