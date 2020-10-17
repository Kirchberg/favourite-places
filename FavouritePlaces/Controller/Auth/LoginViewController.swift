//
//  LoginViewController.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 26.09.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import Firebase
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var appLabel: UILabel! {
        didSet {
            appLabel.text = "Favourite Places"
            appLabel.font = UIFont(name: "Ubuntu", size: 30.0)
            appLabel.textColor = .black
        }
    }

    @IBOutlet var emailTF: UITextField! {
        didSet {
            emailTF.placeholder = "Email"
            emailTF.font = UIFont(name: "Ubuntu", size: 17.0)
            emailTF.keyboardType = .emailAddress
            emailTF.returnKeyType = .continue
        }
    }

    @IBOutlet var passwordTF: UITextField! {
        didSet {
            passwordTF.placeholder = "Password"
            passwordTF.font = UIFont(name: "Ubuntu", size: 17.0)
            passwordTF.keyboardType = .asciiCapable
            passwordTF.isSecureTextEntry = true
            passwordTF.returnKeyType = .done
        }
    }

    @IBOutlet var loginButton: UIButton! {
        didSet {
            loginButton.setTitle("Log In", for: .normal)
            loginButton.setTitleColor(.white, for: .normal)
            loginButton.backgroundColor = .systemBlue
            loginButton.titleLabel?.font = UIFont(name: "Ubuntu", size: 20.0)
            loginButton.layer.cornerRadius = 20.0
        }
    }

    @IBOutlet var signUpLabel: UILabel! {
        didSet {
            signUpLabel.text = "Don't have an account?"
            signUpLabel.font = UIFont(name: "Ubuntu", size: 17.0)
            signUpLabel.textColor = .black
        }
    }

    @IBOutlet var signUpButton: UIButton! {
        didSet {
            signUpButton.setTitle("Sign Up Now", for: .normal)
            signUpButton.titleLabel?.font = UIFont(name: "Ubuntu", size: 17.0)
            signUpButton.layer.cornerRadius = 20.0
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        setupCustomInterfaceStyle()
        emailTF.tag = 0
        passwordTF.tag = 1
        emailTF.delegate = self
        passwordTF.delegate = self
        super.viewDidLoad()
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func logInButton(_: UIButton) {
        guard let email = emailTF.text,
            let password = passwordTF.text,
            !email.isEmpty(),
            !password.isEmpty()
        else {
            errorSignUp(title: "Error", message: "Email or password can't be empty!")
            emailTF.text = nil
            passwordTF.text = nil
            return
        }
        showSpinner {
            self.logUserIn(with: email, password: password)
        }
    }

    // MARK: - Firebase Auth

    private func logUserIn(with email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                self.hideSpinner {
                    self.errorSignUp(title: "Error", message: error.localizedDescription)
                    self.emailTF.text = nil
                    self.passwordTF.text = nil
                    print("Failed to log user in with error: ", error.localizedDescription)
                }
                return
            }
            UserDefaults.standard.setIsLoggedIn(value: true)
            self.hideSpinner {
                self.performSegue(withIdentifier: "loginSuccess", sender: nil)
            }
        }
    }

    // MARK: - Error

    private func errorSignUp(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1

        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    func textFieldDidBeginEditing(_: UITextField) {
        animateViewMoving(up: true, moveValue: 100)
    }

    func textFieldDidEndEditing(_: UITextField) {
        animateViewMoving(up: false, moveValue: 100)
    }

    private func animateViewMoving(up: Bool, moveValue: CGFloat) {
        let movementDuration: TimeInterval = 0.3
        let movement: CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        view.frame = view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}
