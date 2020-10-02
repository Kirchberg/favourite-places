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

protocol MapViewControllerDelegate {
    func getInfoAboutPlace(_ address: String)
}

class MapViewController: UIViewController {
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    var incomeSegueIdentifier = String()
    let regionInMeters = 1000.0
    var placeCoordinate: CLLocationCoordinate2D?
    var previousUserLocation: CLLocation? {
        didSet {
            startTrackingUserLocation()
        }
    }

    var directionsArray: [MKDirections] = []
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
            doneButton.titleLabel?.font = UIFont(name: "Ubuntu", size: 16.0)
        }
    }

    @IBOutlet var setRouteAutomobileButton: UIButton!

    @IBOutlet var setRouteWalkingButton: UIButton!

    @IBOutlet var currentAddressLabel: UILabel! {
        didSet {
            currentAddressLabel.font = UIFont(name: "Ubuntu", size: 30.0)
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

    @IBAction func zoomInButtonPressed(_: UIButton) {
        print("Zoom in works! 🐸")
        var region = mapView.region
        region.span.latitudeDelta /= 2.0
        region.span.longitudeDelta /= 2.0
        mapView.setRegion(region, animated: true)
    }

    @IBAction func zoomOutButtonPressed(_: UIButton) {
        print("Zoom out works! 🐸")
        var region = mapView.region
        region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
        region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
        mapView.setRegion(region, animated: true)
    }

    @IBAction func setRouteButtonPressed(_ sender: UIButton) {
        getDirections(sender)
    }

    @IBAction func closeVC() {
        dismiss(animated: true)
    }

    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getInfoAboutPlace(currentAddressLabel.text ?? "")
        dismiss(animated: true)
    }

    private func setupMapView() {
        centerUserLocationButton.isHidden = true
        setRouteWalkingButton.isHidden = true
        setRouteAutomobileButton.isHidden = true

        if incomeSegueIdentifier == "showMap" {
            setupPlacemark()
            markerLocationView.isHidden = true
            currentAddressLabel.isHidden = true
            doneButton.isHidden = true
            centerUserLocationButton.isHidden = false
            setRouteWalkingButton.isHidden = false
            setRouteAutomobileButton.isHidden = false
        }
    }

    // Clears the map from the previous overlays
    private func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
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
            self.placeCoordinate = placemarkLocation.coordinate

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
                self.errorLocationServices(title: "Geolocation services are disabled",
                                           message: "Change an app’s location authorization in Settings > Privacy > Location Services.")
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
                showUserLocation()
            }
        case .authorizedAlways:
            break
        case .denied:
            errorLocationServices(title: "Geolocation services are disabled",
                                  message: "Change an app’s location authorization in Settings > Privacy > Location Services.")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            errorLocationServices(title: "Geolocation services are disabled",
                                  message: "Change an app’s location authorization in Settings > Privacy > Location Services.")
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

    // Centering on the user when the location changes
    private func startTrackingUserLocation() {
        guard let previousUserLocation = previousUserLocation else { return }

        let center = getCenterLocation(for: mapView)
        guard center.distance(from: previousUserLocation) > 3 else { return }

        self.previousUserLocation = center
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showUserLocation()
        }
    }

    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude

        return CLLocation(latitude: latitude, longitude: longitude)
    }

    private func getDirections(_ sender: UIButton) {
        guard let userLocation = locationManager.location?.coordinate else {
            errorLocationServices(title: "Error", message: "The current location can't be determined")
            return
        }

        // Start monitoring the user's movement
        locationManager.startUpdatingLocation()
        previousUserLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)

        guard let request = createDirectionRequest(from: userLocation, sender) else {
            errorLocationServices(title: "Error", message: "The current destination can't be calculated")
            return
        }

        let directions = MKDirections(request: request)
        // Reset previous requests and overlays
        resetMapView(withNew: directions)

        directions.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.errorLocationServices(title: "Error", message: "The route isn't available")
                return
            }

            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)

                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime

                print("\(distance)\n\(timeInterval) 🥳")
            }
        }
    }

    private func createDirectionRequest(from sourceCoordinate: CLLocationCoordinate2D, _ sender: UIButton) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }

        let startPosition = MKPlacemark(coordinate: sourceCoordinate)
        let endPosition = MKPlacemark(coordinate: destinationCoordinate)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startPosition)
        request.destination = MKMapItem(placemark: endPosition)
        switch sender.accessibilityIdentifier {
        case "walking":
            request.transportType = .walking
        default:
            request.transportType = .automobile
        }
        request.requestsAlternateRoutes = false

        return request
    }

    private func errorLocationServices(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
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

        // Cancel previous geocoding request
        geocoder.cancelGeocode()

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

    func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue

        return renderer
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didChangeAuthorization _: CLAuthorizationStatus) {
        // If authorization status changed, we would need to take actions
        checkLocationAuthorization()
    }
}
