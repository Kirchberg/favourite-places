//
//  AddPlaceViewController.swift
//  FavouritePlaces
//
//  Created by Kirill Kostarev on 11.08.2020.
//  Copyright © 2020 Kostarev Kirill Pavlovich. All rights reserved.
//

import Firebase
import UIKit

class AddPlaceViewController: UITableViewController {
    var currentPlace: Place?
    var oldPlaceID: String?
    private let ref = Database.database().reference().child("Places")
    private var currentUser: User!
    private let uid = Auth.auth().currentUser!.uid
    var imageIsChanged: Bool = false
    private var finishedLoadingInitialTableCells = false

    @IBOutlet var addButton: UIBarButtonItem! {
        didSet {
            addButton.isEnabled = false
        }
    }

    @IBOutlet var placeImage: UIImageView! {
        didSet {
            placeImage.layer.masksToBounds = true
            placeImage.layer.cornerRadius = 10
        }
    }

    @IBOutlet var imageViewCell: UITableViewCell! {
        didSet {
            imageViewCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            imageViewCell.directionalLayoutMargins = .zero
        }
    }

    @IBOutlet var placeNameTF: UITextField!
    @IBOutlet var placeLocationTF: UITextField!
    @IBOutlet var placeTypeTF: UITextField!
    @IBOutlet var placeRating: RatingControl!
    @IBOutlet var placeDescriptionTV: UITextView! {
        didSet {
            placeDescriptionTV.enablesReturnKeyAutomatically = true
            placeDescriptionTV.allowsEditingTextAttributes = true
            placeDescriptionTV.autocorrectionType = .default
            placeDescriptionTV.autocapitalizationType = .sentences
            placeDescriptionTV.returnKeyType = .default
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let user = realm.objects(User.self)
        let findByUserPredicate = NSPredicate(format: "uid == '\(uid)'")
        currentUser = user.filter(findByUserPredicate).first
        setupCustomInterfaceStyle()
        addToolBar(textView: placeDescriptionTV)
        setupEditScreen()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1))
        placeNameTF.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }

    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        finishedLoadingInitialTableCells = firstAppearanceCell(cell, forRowAt: indexPath, for: tableView, checkFor: finishedLoadingInitialTableCells)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        placeDescriptionTV.resignFirstResponder()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        guard let mapVC = segue.destination as? MapViewController, let identifier = segue.identifier
        else { return }
        mapVC.incomeSegueIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
        if identifier == "showMap" {
            mapVC.place.name = placeNameTF.text!
            mapVC.place.location = placeLocationTF.text
            mapVC.place.type = placeTypeTF.text
            mapVC.place.imageData = placeImage.image?.pngData()
        }
    }

    // MARK: - Save place to DB

    func savePlace() {
        let image: UIImage? = imageIsChanged ? placeImage.image : #imageLiteral(resourceName: "imagePlaceholder")
        let imageData = image?.jpegData(compressionQuality: 0.5)
        guard let key = ref.childByAutoId().key else { return }
        let newPlace = Place(uid: uid,
                             placeID: oldPlaceID ?? key,
                             name: placeNameTF.text!,
                             location: placeLocationTF.text,
                             type: placeTypeTF.text,
                             imageData: imageData,
                             imageURL: nil,
                             descriptionString: placeDescriptionTV.text,
                             rating: placeRating.rating.toDouble())
        guard let currentPlace = currentPlace else {
            PlaceService.saveNewPlace(newPlace)
            return
        }
        PlaceService.updateOldPlace(from: newPlace, to: currentPlace)
    }

    // MARK: - Table View Delegate

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let cameraIconImage = #imageLiteral(resourceName: "camera")
            let libraryIconImage = #imageLiteral(resourceName: "photo")
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title: "Camera",
                                             style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            cameraAction.setValue(cameraIconImage, forKey: "image")
            cameraAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            let photoAction = UIAlertAction(title: "Photo",
                                            style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photoAction.setValue(libraryIconImage, forKey: "image")
            photoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            actionSheet.addAction(cameraAction)
            actionSheet.addAction(photoAction)
            actionSheet.addAction(cancelAction)
            present(actionSheet, animated: true, completion: nil)
        } else {
            let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }
    }

    private func setupEditScreen() {
        guard let currentPlace = currentPlace else { return }
        imageIsChanged = true
        setupNavigationBar()
        guard let data = currentPlace.imageData, let image = UIImage(data: data) else { return }
        placeImage.image = image
        placeImage.contentMode = .scaleAspectFill
        placeLocationTF.text = currentPlace.location
        placeNameTF.text = currentPlace.name
        placeTypeTF.text = currentPlace.type
        placeDescriptionTV.text = currentPlace.descriptionString
        placeRating.rating = currentPlace.rating.toInt()
    }

    private func setupNavigationBar() {
        navigationController!.navigationBar.topItem!.title = ""
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        addButton.isEnabled = true
    }

    private func addToolBar(textView: UITextView) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearPressed))
        clearButton.tintColor = .red
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        toolBar.setItems([clearButton, flexButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textView.inputAccessoryView = toolBar
    }

    @objc private func donePressed() {
        view.endEditing(true)
    }

    @objc private func clearPressed() {
        placeDescriptionTV.text = nil
    }

    @IBAction func cancelAction(_: Any) {
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension AddPlaceViewController: UITextFieldDelegate {
    // Hide the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func textFieldChanged() {
        if placeNameTF.text?.isEmpty == false {
            addButton.isEnabled = true
        } else {
            addButton.isEnabled = false
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

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

    func imagePickerController(_: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    {
        placeImage.image = info[.editedImage] as? UIImage
        imageIsChanged = true
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        imageViewCell.isSelected = false
        dismiss(animated: true)
    }
}

// MARK: - MapViewControllerDelegate

extension AddPlaceViewController: MapViewControllerDelegate {
    func getInfoAboutPlace(_ address: String) {
        placeLocationTF.text = address
    }
}
