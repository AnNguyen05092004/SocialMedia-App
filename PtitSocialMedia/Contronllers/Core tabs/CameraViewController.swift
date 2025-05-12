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
        let actionSheet = UIAlertController(title: "Chọn ảnh", message: "Chọn nguồn ảnh", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .camera)
        }))
        actionSheet.addAction(UIAlertAction(title: "Thư viện ảnh", style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        }))
        actionSheet.addAction(UIAlertAction(title: "Huỷ", style: .cancel, handler: nil))
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
              let imageData = image.jpegData(compressionQuality: 0.8),
              let currentUser = Auth.auth().currentUser else {
            showErrorAlert("Vui lòng chọn ảnh, nhập caption và đăng nhập.")
            return
        }

        let loadingAlert = UIAlertController(title: nil, message: "Đang đăng bài...", preferredStyle: .alert)
        present(loadingAlert, animated: true)

        let imageID = UUID().uuidString
        let storageRef = Storage.storage().reference().child("posts/\(imageID).jpg")

        storageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
            guard let strongSelf = self else { return }
            if let error = error {
                loadingAlert.dismiss(animated: true) {
                    strongSelf.showErrorAlert("Lỗi upload ảnh: \(error.localizedDescription)")
                }
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    loadingAlert.dismiss(animated: true) {
                        strongSelf.showErrorAlert("Lỗi lấy URL ảnh: \(error.localizedDescription)")
                    }
                    return
                }

                guard let imageUrl = url else { return }

                // ✅ Chỉ gọi đúng 1 lần lưu bài
                self?.uploadPostToFirestore(imageURL: imageUrl, caption: caption, dismissAlert: loadingAlert)
            }
        }
    }

    private func uploadPostToFirestore(imageURL: URL, caption: String, dismissAlert: UIAlertController) {
        guard let currentUser = Auth.auth().currentUser else { return }

        let postID = UUID().uuidString
        let db = Firestore.firestore()
        let postData: [String: Any] = [
            "id": postID,
            "user_id": currentUser.uid,
            "username": currentUser.displayName ?? currentUser.email ?? "anonymous",
            "caption": caption,
            "post_url": imageURL.absoluteString,
            "timestamp": Timestamp(date: Date())
        ]

        db.collection("posts").document(postID).setData(postData) { [weak self] error in
            guard let self = self else { return }

            dismissAlert.dismiss(animated: true) {
                if let error = error {
                    self.showErrorAlert("Lỗi lưu bài đăng: \(error.localizedDescription)")
                } else {
                    // Thông báo cho Homview
                    NotificationCenter.default.post(name: Notification.Name("newPostCreated"), object: nil)
                    
                    let successAlert = UIAlertController(title: "Thành công", message: "Bài đăng đã được chia sẻ!", preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.resetForm()
                    })
                    self.present(successAlert, animated: true)
                }
            }
        }
    }


    
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }


    private func resetForm() {
        imageView.image = nil
        captionTextField.text = ""
    }
}


