//
//  CameraViewController.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//

import UIKit
import AVFoundation
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import Photos

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .secondarySystemBackground
        imageView.clipsToBounds = true
        return imageView
    }()

    private let captionTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter Your Caption..."
        field.borderStyle = .roundedRect
        return field
    }()

    private let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    private let chooseImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose your photo", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(imageView)
        view.addSubview(captionTextField)
        view.addSubview(postButton)
        view.addSubview(chooseImageButton)

        chooseImageButton.addTarget(self, action: #selector(didTapChooseImage), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(didTapPost), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let padding: CGFloat = 20
        imageView.frame = CGRect(x: padding, y: 100, width: view.frame.size.width - 2 * padding, height: view.frame.size.width - 2 * padding)
        captionTextField.frame = CGRect(x: padding, y: imageView.frame.maxY + 20, width: view.frame.size.width - 2 * padding, height: 40)
        postButton.frame = CGRect(x: padding, y: captionTextField.frame.maxY + 15, width: view.frame.size.width - 2 * padding, height: 45)
        chooseImageButton.frame = CGRect(x: padding, y: postButton.frame.maxY + 15, width: view.frame.size.width - 2 * padding, height: 30)
    }

    @objc private func didTapChooseImage() {
        let actionSheet = UIAlertController(title: "Choose your photo", message: "Select image source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .camera)
        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    @objc private func didTapPost() {
        guard let image = imageView.image,
              let caption = captionTextField.text, !caption.isEmpty,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            showErrorAlert("Please select a photo and enter a caption.")
            return
        }

        let loadingAlert = UIAlertController(title: nil, message: "Posting...", preferredStyle: .alert)
        present(loadingAlert, animated: true)

        let fileName = UUID().uuidString // tạo ra một chuỗi tên file duy nhất

        StorageManager.shared.uploadPostImage(data: imageData, fileName: fileName) { [weak self] result in
            switch result {
            case .success(let imageURL):
                DatabaseManager.shared.createPost(caption: caption, imageURL: imageURL) { dbResult in
                    DispatchQueue.main.async {
                        loadingAlert.dismiss(animated: true) {
                            switch dbResult {
                            case .success:
                                // Post notification để HomeViewController biết có bài mới
                                NotificationCenter.default.post(name: Notification.Name("newPostCreated"), object: nil)
                                let alert = UIAlertController(title: "Success", message: "Your post has been shared!", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                                    self?.resetForm()
                                })
                                self?.present(alert, animated: true)

                            case .failure(let error):
                                self?.showErrorAlert("Error saving post: \(error.localizedDescription)")
                            }
                        }
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        self?.showErrorAlert("Error uploading image: \(error.localizedDescription)")
                    }
                }
            }
        }
    }


    
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }


    private func resetForm() {
        imageView.image = nil
        captionTextField.text = ""
    }
}


