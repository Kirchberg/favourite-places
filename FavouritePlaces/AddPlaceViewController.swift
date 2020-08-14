//
//  AddPlaceViewController.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 11.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import UIKit

class AddPlaceViewController: BaseViewController {
    
    var imageIsChanged: Bool = false
    
    @IBOutlet weak var addButton: UIBarButtonItem! {
        didSet {
            addButton.isEnabled = false
        }
    }
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeNameTF: UITextField!
    @IBOutlet weak var placeLocationTF: UITextField!
    @IBOutlet weak var placeTypeTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        placeNameTF.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    func saveNewPlace() {
        var image: UIImage?
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        let imageData = image?.pngData()
        let newPlace = Place(name: placeNameTF.text!,
                             location: placeLocationTF.text,
                             type: placeTypeTF.text,
                             imageData: imageData)
        StorageManager.saveObject(newPlace)
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
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - Text Field Delegate

extension AddPlaceViewController: UITextFieldDelegate {
    //Hide the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    private func isEmptyTF(_ textField: String?) -> Bool {
        let str = textField?.filter {!(" ").contains($0)}
        return (str == "") ? true : false
    }
    @objc private func textFieldChanged() {
        if isEmptyTF(placeNameTF.text) == false {
            addButton.isEnabled = true
        } else {
            addButton.isEnabled = false
        }
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
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        imageIsChanged = true
        dismiss(animated: true)
    }
}
