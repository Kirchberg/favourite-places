//
//  MainTableViewCell.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 07.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    @IBOutlet var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }

    @IBOutlet var nameOfPlaceLabel: UILabel! {
        didSet {
            nameOfPlaceLabel.textColor = #colorLiteral(red: 0.03921568627, green: 0.3969546359, blue: 1, alpha: 1)
            nameOfPlaceLabel.numberOfLines = 3
        }
    }

    @IBOutlet var locationOfPlaceLabel: UILabel! {
        didSet {
            locationOfPlaceLabel.numberOfLines = 3
        }
    }

    @IBOutlet var typeOfPlaceLabel: UILabel! {
        didSet {
            typeOfPlaceLabel.numberOfLines = 3
        }
    }

    @IBOutlet var placeStar: [UIImageView]!
}
