//
//  MainViewController.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 06.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: BaseViewController {
    
    var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        places = realm.objects(Place.self)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? MainTableViewCell
            else { fatalError("DequeueReusableCell failed while casting") }
        let place = places[indexPath.row]
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.nameOfPlaceLabel.textColor = #colorLiteral(red: 0.03921568627, green: 0.3969546359, blue: 1, alpha: 1)
        cell.nameOfPlaceLabel.text = place.name
        cell.nameOfPlaceLabel.numberOfLines = 0
        cell.locationOfPlaceLabel.text = place.location
        cell.typeOfPlaceLabel.text = place.type
        return cell
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    
    // MARK: - Segues
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? AddPlaceViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let newPlaceVC = segue.destination as? AddPlaceViewController else { return }
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = places[indexPath.row]
            newPlaceVC.currentPlace = place
        }
    }
}
