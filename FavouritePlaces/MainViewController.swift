//
//  MainViewController.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 06.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {
    var places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? MainTableViewCell
            else { fatalError("DequeueReusableCell failed while casting") }
        let place = places[indexPath.row]
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true
        if place.image == nil {
            cell.imageOfPlace.image = UIImage(named: place.restaurantImage!)
        } else {
            cell.imageOfPlace.image = place.image
        }
        cell.nameOfPlaceLabel.textColor = #colorLiteral(red: 0.03921568627, green: 0.3969546359, blue: 1, alpha: 1)
        cell.nameOfPlaceLabel.text = place.name
        cell.nameOfPlaceLabel.numberOfLines = 0
        cell.locationOfPlaceLabel.text = place.location
        cell.typeOfPlaceLabel.text = place.type
        return cell
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? AddPlaceViewController else { return }
        newPlaceVC.saveNewPlace()
        places.append(newPlaceVC.newPlace!)
        tableView.reloadData()
    }
}
