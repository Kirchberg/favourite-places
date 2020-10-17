//
//  MainViewController.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 06.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import Firebase
import UIKit

class MainViewController: UIViewController {
    private var finishedLoadingInitialTableCells = false
    private let searchController = UISearchController(searchResultsController: nil)
    private let uid = Auth.auth().currentUser!.uid
    private var userPlaces = [Place]()
    private var filteredPlaces = [Place]()
    private var ascendingSorting: Bool = true
    private var isSearchBarEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }

    private var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }

    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var sortButton: UIBarButtonItem!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = "Favourite Places"
        getAllPlaces()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomInterfaceStyle()
        searchController.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        tableView.rowHeight = UITableView.automaticDimension
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        finishedLoadingInitialTableCells = firstAppearanceCell(cell, forRowAt: indexPath, for: tableView, checkFor: finishedLoadingInitialTableCells)
    }

    // MARK: - Segues

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? AddPlaceViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        guard let newPlaceVC = segue.destination as? AddPlaceViewController else { return }
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = isFiltering ? filteredPlaces[indexPath.row] : userPlaces[indexPath.row]
            newPlaceVC.currentPlace = place
            newPlaceVC.oldPlaceID = place.placeID
        }
    }

    // MARK: - Sort

    @IBAction func sortSelection(_: UISegmentedControl) {
        sorting()
    }

    @IBAction func reversedSorting(_: Any) {
        ascendingSorting.toggle()
        if ascendingSorting {
            sortButton.image = #imageLiteral(resourceName: "AZ")
            segmentedControl.setTitle("A-Z", forSegmentAt: 1)
        } else {
            sortButton.image = #imageLiteral(resourceName: "ZA")
            segmentedControl.setTitle("Z-A", forSegmentAt: 1)
        }
        sorting()
    }

    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            if ascendingSorting {
                userPlaces = userPlaces.sorted(by: { $0.date < $1.date })
            } else {
                userPlaces = userPlaces.sorted(by: { $0.date > $1.date })
            }
        } else if segmentedControl.selectedSegmentIndex == 1 {
            if ascendingSorting {
                userPlaces = userPlaces.sorted(by: { $0.name < $1.name })
            } else {
                userPlaces = userPlaces.sorted(by: { $0.name > $1.name })
            }
        } else {
            if !ascendingSorting {
                userPlaces = userPlaces.sorted(by: { $0.rating < $1.rating })
            } else {
                userPlaces = userPlaces.sorted(by: { $0.rating > $1.rating })
            }
        }
        tableView.reloadData()
    }
}

// MARK: - Table View Delegate

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let place = userPlaces[indexPath.row]
            deletePlace(delete: place)
            userPlaces.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Table view data source

extension MainViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return isFiltering ? filteredPlaces.count : userPlaces.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MainTableViewCell
        let place = isFiltering ? filteredPlaces[indexPath.row] : userPlaces[indexPath.row]
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.nameOfPlaceLabel.text = place.name
        cell.locationOfPlaceLabel.text = place.location
        cell.typeOfPlaceLabel.text = place.type
        setImageStar(cell, place)
        return cell
    }

    private func setImageStar(_ cell: MainTableViewCell, _ place: Place) {
        for star in cell.placeStar {
            star.image = #imageLiteral(resourceName: "emptyStar")
        }
        for (index, star) in cell.placeStar.enumerated() where index < place.rating.toInt() {
            star.image = #imageLiteral(resourceName: "filledStar")
        }
    }
}

// MARK: - Search results updating

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    private func filterContentForSearchText(_ searchText: String) {
        let resultPredicate = NSPredicate(format: "name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText)
        filteredPlaces = userPlaces.filter { resultPredicate.evaluate(with: $0) }
        tableView.reloadData()
    }
}

// MARK: - Search Bar Customization

extension MainViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.tintColor = UIColor.black
        searchController.searchBar.backgroundColor = .white
    }
}

extension MainViewController {
    func getAllPlaces() {
        let ref = Database.database().reference().child("/Places").queryOrdered(byChild: "userID").queryEqual(toValue: "\(uid)")
        ref.keepSynced(true)
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.childrenCount > 0 {
                self.userPlaces.removeAll()
                for places in snapshot.children.allObjects as! [DataSnapshot] {
                    let placeObject = places.value as? [String: AnyObject]
                    let descriptionPlace = placeObject?["Description"]
                    let locationPlace = placeObject?["Location"]
                    let namePlace = placeObject?["Name"]
                    let ratingPlace = placeObject?["Rating"]
                    let typePlace = placeObject?["Type"]
                    let placeIDPlace = placeObject?["placeID"]
                    let userIDPlace = placeObject?["userID"]
                    let imagePlace = placeObject?["Image"]

                    var imageDataPlace: Data!
                    guard let imageURL = URL(string: imagePlace as! String) else { return }
                    let ref = Storage.storage().reference(forURL: imageURL.absoluteString)
                    let megaByte = Int64(1024 * 1024)
                    ref.getData(maxSize: megaByte) { data, error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        guard let imageData = data else { return }
                        imageDataPlace = imageData
                    }
                    let place = Place(uid: userIDPlace as! String, placeID: placeIDPlace as! String, name: namePlace as! String, location: locationPlace as! String?, type: typePlace as! String?, imageData: imageDataPlace, descriptionString: descriptionPlace as! String?, rating: ratingPlace as! Double)
                    self.userPlaces.append(place)
                }
            }
            self.tableView.reloadData()
        }
    }

    func deletePlace(delete place: Place) {
        let ref = Database.database().reference()
        ref.child("/Places").child("\(place.placeID)").removeValue { error, _ in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
