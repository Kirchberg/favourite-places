//
//  MainTableViewCell.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 07.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    @IBOutlet var imageOfPlace: UIImageView!
    @IBOutlet var nameOfPlaceLabel: UILabel!
    @IBOutlet var locationOfPlaceLabel: UILabel!
    @IBOutlet var typeOfPlaceLabel: UILabel!
    @IBOutlet var placeStar: [UIImageView]!
}
