//
//  LoginViewController.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 26.09.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

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
            loginButton.setTitle("Sign In", for: .normal)
            loginButton.setTitleColor(.white, for: .normal)
            loginButton.backgroundColor = .systemBlue
            loginButton.titleLabel?.font = UIFont(name: "Ubuntu", size: 24.0)
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

    override func viewDidLoad() {
        emailTF.tag = 0
        passwordTF.tag = 1
        emailTF.delegate = self
        passwordTF.delegate = self

//        let emailImage = #imageLiteral(resourceName: "icons8-secured_letter")
//        let passwordImage = #imageLiteral(resourceName: "icons8-password")
//        addLeftImageTo(for: emailTF, image: emailImage)
//        addLeftImageTo(for: passwordTF, image: passwordImage)

        super.viewDidLoad()
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        view.endEditing(true)
    }

//    private func addLeftImageTo(for textField: UITextField, image img: UIImage) {
//        let leftImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 10, height: 10))
//        leftImageView.image = img
//        leftImageView.contentMode = .scaleAspectFit
//        textField.leftView = leftImageView
//        textField.leftViewMode = .always
//    }
}

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
}
