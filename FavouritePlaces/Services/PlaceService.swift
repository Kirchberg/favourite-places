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
    private static var imageRef = Storage.storage().reference().child("placePhotos")

    static func saveNewPlace(_ place: Place) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        imageRef = imageRef.child("\(place.placeID)\(place.uid)")
        imageRef.putData(place.imageData!, metadata: metadata) { metadata, error in
            if let error = error {
                print(error.localizedDescription)
            }

            guard let _ = metadata else { return }
            imageRef.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                }

                let placeInfo: [String: Any] = [
                    "placeID": place.placeID,
                    "userID": place.uid,
                    "Name": place.name,
                    "Location": place.location ?? "",
                    "Type": place.type ?? "",
                    "Image": url?.absoluteString ?? "",
                    "Description": place.descriptionString ?? "",
                    "Rating": place.rating,
                ]

                ref.child(place.placeID).setValue(placeInfo) { error, _ in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }

    static func updateOldPlace(from newPlace: Place, to currentPlace: Place) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        PlaceService.deletePhoto(for: currentPlace)

        imageRef.putData(newPlace.imageData!, metadata: metadata) { metadata, error in
            if let error = error {
                print(error.localizedDescription)
            }

            guard let _ = metadata else { return }
            imageRef.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                }

                let placeInfo: [String: Any] = [
                    "placeID": newPlace.placeID,
                    "userID": newPlace.uid,
                    "Name": newPlace.name,
                    "Location": newPlace.location ?? "",
                    "Type": newPlace.type ?? "",
                    "Image": url?.absoluteString ?? "",
                    "Description": newPlace.descriptionString ?? "",
                    "Rating": newPlace.rating,
                ]

                ref.child(newPlace.placeID).updateChildValues(placeInfo) { error, _ in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }

    static func deletePlace(delete place: Place) {
        deletePhoto(for: place)
        ref.child("\(place.placeID)").removeValue { error, _ in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    private static func deletePhoto(for place: Place) {
        let storage = Storage.storage()
        let url = place.imageURL
        let storageRef = storage.reference(forURL: url!)
        storageRef.delete { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
