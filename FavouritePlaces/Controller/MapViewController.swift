//
//  MapViewController.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 29.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

class MapViewController: UIViewController {
    var place = Place()
    var incomeSegueIdentifier = String()
    let regionInMeters = 5000.0
    let annotationIdentfier: String = "annotationIdentfier"

    // Object that helps us get the user's location
    let locationManager = CLLocationManager()

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var centerUserLocationButton: UIButton!
    @IBOutlet var markerLocationView: UIImageView!
    @IBOutlet var doneButton: UIButton! {
        didSet {
            doneButton.backgroundColor = .black
            doneButton.setTitleColor(.white, for: .normal)
            doneButton.layer.cornerRadius = 7.0
            doneButton.setTitle("Done", for: .normal)
            doneButton.titleLabel?.font = UIFont(name: "EuphemiaUCAS", size: 16.0)
        }
    }

    @IBOutlet var currentAddressLabel: UILabel! {
        didSet {
            currentAddressLabel.font = UIFont(name: "EuphemiaUCAS", size: 30.0)
            currentAddressLabel.text = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationServices()
        setupMapView()
    }

    @IBAction func centerViewInUserLocation() {
        // Get user location
        showUserLocation()
    }

    @IBAction func closeVC() {
        dismiss(animated: true)
    }

    @IBAction func doneButtonPressed() {}

    private func setupMapView() {
        if incomeSegueIdentifier == "showMap" {
            setupPlacemark()
            markerLocationView.isHidden = true
            currentAddressLabel.isHidden = true
            doneButton.isHidden = true
        }
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

    // MARK: - User location services

    private func checkLocationServices() {
        // Checking the functionality of geolocation services and set user location
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Load alert after 1 second if geolocation services are disabled
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.errorLocationServices()
            }
        }
    }

    // Setting up an object that gives us access to use the map
    private func setupLocationManager() {
        locationManager.delegate = self

        // GPS accuracy type
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getLocationMap" {
                centerUserLocationButton.isHidden = true
                showUserLocation()
            }
        case .authorizedAlways:
            break
        case .denied:
            errorLocationServices()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            errorLocationServices()
        @unknown default:
            print("I hate new features 👺. \nBut I love programming 💌.")
        }
    }

    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            // A rectangular geographic region centered around a specific latitude and longitude.
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)

            // Changes the currently visible region and optionally animates the change
            mapView.setRegion(region, animated: true)
        }
    }

    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude

        return CLLocation(latitude: latitude, longitude: longitude)
    }

    private func errorLocationServices() {
        let alert = UIAlertController(title: "Geolocation services are disabled", message: "Change an app’s location authorization in Settings > Privacy > Location Services.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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

    // This method is called every time we change the current region on the map
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated _: Bool) {
        let center = getCenterLocation(for: mapView)

        // Object that converts map coordinates to a street address
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            DispatchQueue.main.async {
                if let streetName = streetName, let buildNumber = buildNumber {
                    self.currentAddressLabel.text = "\(streetName), \(buildNumber)"
                } else if let streetName = streetName {
                    self.currentAddressLabel.text = "\(streetName)"
                } else {
                    self.currentAddressLabel.text = ""
                }
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didChangeAuthorization _: CLAuthorizationStatus) {
        // If authorization status changed, we would need to take actions
        checkLocationAuthorization()
    }
}
