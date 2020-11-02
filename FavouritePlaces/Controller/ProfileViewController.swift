//
//  ProfileViewController.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 08.10.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import Firebase
import FirebaseDatabase
import UIKit

class ProfileViewController: UIViewController {
    // MARK: - Outlet

    @IBOutlet var profileImage: UIImageView! {
        didSet {
            profileImage.alpha = 0
            profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
            profileImage.clipsToBounds = true
        }
    }

    @IBOutlet var emailUserLabel: UILabel! {
        didSet {
            emailUserLabel.alpha = 0
            emailUserLabel.font = UIFont(name: "Ubuntu", size: 17.0)
        }
    }

    @IBOutlet var signOutButton: UIButton! {
        didSet {
            signOutButton.alpha = 0
            signOutButton.setTitle("Sign Out", for: .normal)
            signOutButton.titleLabel?.font = UIFont(name: "Ubuntu", size: 20.0)
            signOutButton.layer.cornerRadius = 20.0
            signOutButton.setTitleColor(.white, for: .normal)
            signOutButton.backgroundColor = .systemRed
        }
    }

    // MARK: - Default

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomInterfaceStyle()
        showSpinner {
            self.userSetup()
        }
    }

    // MARK: - Sign out

    @IBAction func signOutUserButton(_: UIButton) {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            self.signOut()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }

    private func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            showLoginViewController()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    private func showLoginViewController() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "loginForm") as! LoginViewController
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .fullScreen
        UserDefaults.standard.setIsLoggedIn(value: false)
        present(navigationVC, animated: true, completion: nil)
    }

    // MARK: - Firebase Database

    private func userSetup() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let rootRef = Database.database().reference()
        let userRef = rootRef.child("Users").child(uid).child("Email")
        userRef.observeSingleEvent(of: .value) { snapshot in
            guard let email = snapshot.value as? String else { return }
            self.emailUserLabel.text = "Email: \(email)"
            self.hideSpinner {
                self.animateUserSetup()
            }
        }
    }

    private func animateUserSetup() {
        UIView.animate(withDuration: 0.5, delay: 0.1 * 1, options: [.curveEaseInOut], animations: {
            self.profileImage.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 0.5, delay: 0.1 * 2, options: [.curveEaseInOut], animations: {
            self.emailUserLabel.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 0.5, delay: 0.1 * 3, options: [.curveEaseInOut], animations: {
            self.signOutButton.alpha = 1
        }, completion: nil)
    }
}
