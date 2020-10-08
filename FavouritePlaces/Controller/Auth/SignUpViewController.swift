//
//  SignUpViewController.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 04.10.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import Firebase
import UIKit

class SignUpViewController: UIViewController {
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

    @IBOutlet var signUpLabel: UILabel! {
        didSet {
            signUpLabel.text = "Now we need to sign up for a new account"
            signUpLabel.font = UIFont(name: "Ubuntu", size: 17.0)
            signUpLabel.textColor = .black
        }
    }

    @IBOutlet var signUpButton: UIButton! {
        didSet {
            signUpButton.setTitle("Sign Up", for: .normal)
            signUpButton.titleLabel?.font = UIFont(name: "Ubuntu", size: 20.0)
            signUpButton.layer.cornerRadius = 20.0
            signUpButton.setTitleColor(.white, for: .normal)
            signUpButton.backgroundColor = .systemBlue
        }
    }

    @IBAction func closeVC(_: Any) {
        dismiss(animated: true)
    }

    @IBAction func signUpButton(_: UIButton) {
        guard let email = emailTF.text,
            let password = passwordTF.text,
            !email.isEmpty(),
            !password.isEmpty()
        else {
            errorSignUp(title: nil, message: "Email or Password can't be empty!")
            emailTF.text = nil
            passwordTF.text = nil
            return
        }
        showSpinner {
            self.createUser(with: email, password: password)
        }
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

    // MARK: - Firebase Auth

    private func createUser(with email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.hideSpinner {
                    self.errorSignUp(title: nil, message: "This email has already been registered")
                    print("Failed to sign user up with error: ", error.localizedDescription)
                }
                return
            }

            guard let uid = result?.user.uid else { return }
            let userInfo = ["Email": email, "Password": password]

            Database.database().reference().child("Users").child(uid).updateChildValues(userInfo) { error, _ in
                if let error = error {
                    print("Failed to database values with error: ", error.localizedDescription)
                    return
                }
                print("Success: Sign Up")
                UserDefaults.standard.setIsLoggedIn(value: true)
                self.saveUser(uid: uid, email: email)
                self.hideSpinner {
                    self.performSegue(withIdentifier: "signUpSuccess", sender: nil)
                }
            }
        }
    }

    private func saveUser(uid: String, email: String) {
        let newUser = User(uid: uid, email: email)
        StorageManager.saveUserObject(newUser)
    }

    // MARK: - Error

    private func errorSignUp(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension SignUpViewController: UITextFieldDelegate {
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
