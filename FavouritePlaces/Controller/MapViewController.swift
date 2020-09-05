//
//  MapViewController.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 29.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import MapKit
import UIKit

class MapViewController: UIViewController {
    var place = Place()
    let annotationIdentfier: String = "annotationIdentfier"

    @IBOutlet var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupPlacemark()
    }

    @IBAction func closeVC() {
        dismiss(animated: true)
    }

    // MARK: - Converting an address name to a coordinate on the map

    private func setupPlacemark() {
        guard let location = place.location else { return }

        // Object that converts the names of the places between geographic coordinates
        let geocoder = CLGeocoder()

        // Attempt to get placemarks of place and show the place on the map
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error {
                print(error)
                return
            }

            // Get placemarks of place
            guard let placemarks = placemarks else { return }

            // In our task we need only one placemark
            let placemark = placemarks.first

            // Create annotation for placemark
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type

            // Get latitude and longitude location of a place
            guard let placemarkLocation = placemark?.location else { return }

            // Attach an annotation to a placemark
            annotation.coordinate = placemarkLocation.coordinate

            // Show and select a place annotation on a map
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    // Creating a custom annotaion on the map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Check that annotation in not user current position
        guard !(annotation is MKUserLocation) else { return nil }

        // If we had an annotationView earlier then we use this value instead of creating a new one
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentfier) as? MKPinAnnotationView

        // Else we create a new annotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentfier)
            annotationView?.canShowCallout = true
        }
        if let imageData = place.imageData, let image = UIImage(data: imageData) {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.image = image
            imageView.layer.cornerRadius = 10.0
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }
}
