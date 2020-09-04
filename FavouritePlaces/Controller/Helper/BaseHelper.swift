//
//  BaseMethods.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 03.09.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import UIKit

// MARK: - Setup custom interface style

public extension UIViewController {
    func setupCustomInterfaceStyle() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
            self.navigationController?.navigationBar.titleTextAttributes
                = [NSAttributedString.Key.foregroundColor: UIColor.black]
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}

// MARK: - Extension for Int variables

public extension Int {
    func toDouble() -> Double {
        return Double(self)
    }
}

// MARK: - Extension for Double variables

public extension Double {
    func toInt() -> Int {
        return Int(self)
    }
}

// MARK: - Extension for String Literals

public extension String {
    func isEmpty() -> Bool {
        let str = filter { !" ".contains($0) }
        return (str == "") ? true : false
    }
}

// MARK: - Implementation of the default UITableViewCell appearance animation

public func firstAppearanceCell(_ cell: UITableViewCell, forRowAt indexPath: IndexPath, for tableView: UITableView!, checkFor finishedLoadingInitialTableCells: Bool) -> Bool {
    var finishedLoadingInitialTableCells = finishedLoadingInitialTableCells
    var lastInitialDisplayableCell = false
    if !finishedLoadingInitialTableCells {
        if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows,
            let lastIndexPath = indexPathsForVisibleRows.last, lastIndexPath.row == indexPath.row
        {
            lastInitialDisplayableCell = true
        }
    }
    if !finishedLoadingInitialTableCells {
        if lastInitialDisplayableCell {
            finishedLoadingInitialTableCells = true
        }
        cell.transform = CGAffineTransform(translationX: 0.5, y: 0.5)
        cell.alpha = 0

        UIView.animate(withDuration: 0.5, delay: 0.1 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
            cell.transform = CGAffineTransform(translationX: 0, y: 0)
            cell.alpha = 1
        }, completion: nil)
    }
    return finishedLoadingInitialTableCells
}
