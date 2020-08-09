//
//  MainTableViewCell.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 07.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var nameOfPlaceLabel: UILabel!
    @IBOutlet weak var locationOfPlaceLabel: UILabel!
    @IBOutlet weak var typeOfPlaceLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.contentView.backgroundColor = #colorLiteral(red: 0.8846201301, green: 0.9258134365, blue: 0.6525990963, alpha: 0.8470588235)
        } else {
            self.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}
