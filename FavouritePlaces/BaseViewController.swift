//
//  BaseViewController.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 11.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import UIKit

class BaseViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
            self.navigationController?.navigationBar.titleTextAttributes
                = [NSAttributedString.Key.foregroundColor: UIColor.black]
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.03702176504, green: 0.740731391, blue: 0.941593536, alpha: 1)
        }
    }
}

extension Int {
    func toDouble() -> Double {
        return Double(self)
    }
}

extension Double {
    func toInt() -> Int {
        return Int(self)
    }
}
