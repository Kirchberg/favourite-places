//
//  AddPlaceViewController.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 11.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import UIKit

class AddPlaceViewController: BaseViewController {
    @IBOutlet weak var imageOfPlace: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let cameraIconImage = #imageLiteral(resourceName: "camera")
            let libraryIconImage = #imageLiteral(resourceName: "photo")
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title: "Take Photo",
                                             style: .default) { _ in
                                                self.chooseImagePicker(source: .camera)
            }
            cameraAction.setValue(cameraIconImage, forKey: "image")
            let photoAction = UIAlertAction(title: "Choose Photo",
                                            style: .default) { _ in
                                                self.chooseImagePicker(source: .photoLibrary)
            }
            photoAction.setValue(libraryIconImage, forKey: "image")
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            actionSheet.addAction(cameraAction)
            actionSheet.addAction(photoAction)
            actionSheet.addAction(cancelAction)
            self.present(actionSheet, animated: true, completion: nil)
        } else {
            let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }
    }
}

// MARK: - Text Field Delegate

extension AddPlaceViewController: UITextFieldDelegate {
    //Hide the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Work With Image

extension AddPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        imageOfPlace.image = info[.editedImage] as? UIImage
        imageOfPlace.contentMode = .scaleAspectFill
        imageOfPlace.clipsToBounds = true
        dismiss(animated: true)
    }
}
