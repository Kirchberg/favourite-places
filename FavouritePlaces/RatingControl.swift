//
//  RatingControl.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 20.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    // MARK: - Properties

    private var ratingButtons = [UIButton]()
    var rating: Int = 0

    @IBInspectable var starSize: CGSize = CGSize(width: 40.0, height: 40.0) {
        didSet {
            setupButtons()
        }
    }

    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }

    // MARK: - Button Action

    @objc func ratingButtonTapped(button _: UIButton) {
        print("🌚")
    }

    // MARK: - Private Methods

    private func setupButtons() {
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }

        ratingButtons.removeAll()

        for _ in 1 ... starCount {
            // Create the button
            let btn = UIButton()
            btn.backgroundColor = .red

            // Add constraints
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            btn.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true

            // Setup button actions
            btn.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)

            // Add the button to the stack
            addArrangedSubview(btn)

            // Add the new button in the rating button array
            ratingButtons.append(btn)
        }
    }
}
