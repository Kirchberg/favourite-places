//
//  MainViewController.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 06.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import Firebase
import RealmSwift
import UIKit

class MainViewController: UIViewController {
    private var finishedLoadingInitialTableCells = false
    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomInterfaceStyle()
        let uid = Auth.auth().currentUser!.uid
        let getUserPlaces = realm.objects(Place.self)
        let resultPredicate = NSPredicate(format: "uid == '\(uid)'")
        places = getUserPlaces.filter(resultPredicate)
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
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            newPlaceVC.currentPlace = place
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
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else if segmentedControl.selectedSegmentIndex == 1 {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "rating", ascending: !ascendingSorting)
        }
        tableView.reloadData()
    }
}

// MARK: - Table View Delegate

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { _, _ in
            StorageManager.deletePlaceObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Table view data source

extension MainViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return isFiltering ? filteredPlaces.count : places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MainTableViewCell
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
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
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@ AND uid = \(Auth.auth().currentUser!.uid)", searchText, searchText)
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
