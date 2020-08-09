//
//  MainViewController.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 06.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    let restaurantNames: [String] = ["Mirazur",
                                     "Noma",
                                     "Asador",
                                     "Gaggan",
                                     "Geranium",
                                     "Central",
                                     "Mugaritz",
                                     "Maido",
                                     "Arpege",
                                     "Disfutar"]
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantNames.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? MainTableViewCell
            else { fatalError("DequeueReusableCell failed while casting") }
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true
        cell.imageOfPlace.image = UIImage(named: restaurantNames[indexPath.row])
        cell.nameOfPlaceLabel.textColor = #colorLiteral(red: 0.03921568627, green: 0.3969546359, blue: 1, alpha: 1)
        cell.nameOfPlaceLabel.text = restaurantNames[indexPath.row]
        cell.nameOfPlaceLabel.numberOfLines = 0
        return cell
    }
}
