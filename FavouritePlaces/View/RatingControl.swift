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
    var rating: Int = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }

    @IBInspectable var starSize = CGSize(width: 40.0, height: 40.0) {
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

    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else { return }

        // Calculate the rating of the selected button
        let selectedRating = index + 1
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }

        print("Easter egg: 🐸")
    }

    // MARK: - Private Methods

    private func setupButtons() {
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }

        ratingButtons.removeAll()

        // Load button image
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar",
                                 in: bundle,
                                 compatibleWith: traitCollection)
        let emptyStar = UIImage(named: "emptyStar",
                                in: bundle,
                                compatibleWith: traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar",
                                      in: bundle,
                                      compatibleWith: traitCollection)

        for _ in 1 ... starCount {
            // Create the button
            let btn = UIButton()

            // Set the button image
            btn.setImage(emptyStar, for: .normal)
            btn.setImage(filledStar, for: .selected)
            btn.setImage(highlightedStar, for: .highlighted)
            btn.setImage(highlightedStar, for: [.highlighted, .selected])

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
        updateButtonSelectionState()
    }

    private func updateButtonSelectionState() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
