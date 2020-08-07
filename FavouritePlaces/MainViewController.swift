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
        self.tableView.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.1843137255, blue: 0.2431372549, alpha: 1)
        self.tableView.separatorColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantNames.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? MainTableViewCell
            else { fatalError("DequeueReusableCell failed while casting") }
        cell.textLabel?.textColor = #colorLiteral(red: 0.2039215686, green: 0.1215686275, blue: 0.5921568627, alpha: 1)
        cell.textLabel?.font = UIFont(name: "EuphemiaUCAS", size: 22)
        cell.textLabel?.text = restaurantNames[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.layer.cornerRadius = 10
        cell.imageView?.image = UIImage(named: restaurantNames[indexPath.row])
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
