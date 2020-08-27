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
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}

// MARK: - Extension for Int variables

extension Int {
    func toDouble() -> Double {
        return Double(self)
    }
}

// MARK: - Extension for Double variables

extension Double {
    func toInt() -> Int {
        return Int(self)
    }
}

// MARK: - Extension for String Literals

extension String {
    // String isEmpty
    func isEmpty() -> Bool {
        let str = filter { !" ".contains($0) }
        return (str == "") ? true : false
    }
}
