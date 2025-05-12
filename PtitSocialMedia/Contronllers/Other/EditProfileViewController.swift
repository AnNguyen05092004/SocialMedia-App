//
//  EditProfileViewController.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import SDWebImage

struct EditProfileFormModel {
    let label: String
    let placeholder: String
    var value: String?
}

class EditProfileViewController: UIViewController {
    
    private let tableView: UITableView = {
       let tableView = UITableView()
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)
        
        return tableView
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeaderView()
        
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSave))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapCancel))
        configureModels()
        loadUserData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private var models = [[EditProfileFormModel]]()
    private func configureModels() {
        // name, username, bio
        let section1Labels = ["Name", "Username", "Bio"]
        var section1 = [EditProfileFormModel]()
        for label in section1Labels {
            let model = EditProfileFormModel(label: label, placeholder: "Enter \(label)", value: nil)
            section1.append(model)
        }
        models.append(section1)
        
        // email, phone, gender
        let section2Labels = ["Email", "Phone", "Gender"]
        var section2 = [EditProfileFormModel]()
        for label in section2Labels {
            let model = EditProfileFormModel(label: label, placeholder: "Enter \(label)", value: nil)
            section2.append(model)
        }
        models.append(section2)
    }
    
    //MARK: - Header Table View
    private let profilePhotoButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.tintColor = .label
        button.setBackgroundImage(UIImage(systemName: "person.circle"), for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        return button
    }()

    private func createTableHeaderView() -> UIView {
        let header = UIView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: view.width,
                                          height: view.height/4).integral)
        let size = header.height/1.5
        profilePhotoButton.frame = CGRect(x: (view.width-size)/2, 
                                          y: (header.height-size)/2,
                                          width: size, height: size)
        header.addSubview(profilePhotoButton)

        profilePhotoButton.layer.masksToBounds = true
        profilePhotoButton.layer.cornerRadius = size/2
        profilePhotoButton.tintColor = .label
        profilePhotoButton.addTarget(self, action: #selector(didTapChangeProfilePicture), for: .touchUpInside)
        
        profilePhotoButton.setBackgroundImage(UIImage(systemName: "person.circle"), for: .normal)
        profilePhotoButton.layer.borderWidth = 1
        profilePhotoButton.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        
        return header
    }
    
    
    //MARK: - Button even
    @objc private func didTapProfileButton() {
        
    }
    
    @objc private func didTapSave() {
        view.endEditing(true)

        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        var updatedData: [String: Any] = [:]

        for section in models {
            for item in section {
                let value = item.value ?? ""

                switch item.label.lowercased() {
                case "name":
                    updatedData["name"] = value // 🔁 Không tách tên

                case "username":
                    updatedData["username"] = value

                case "bio":
                    updatedData["bio"] = value

                case "email":
                    updatedData["email"] = value

                case "phone":
                    updatedData["phone"] = value

                case "gender":
                    updatedData["gender"] = value.lowercased()

                default:
                    break
                }
            }
        }

        let db = Firestore.firestore()
        db.collection("users").document(userID).updateData(updatedData) { error in
            if let error = error {
                print("Failed to update: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Không thể lưu thay đổi.")
            } else {
                print("Updated user info")
                self.showAlert(title: "Thành công", message: "Thông tin của bạn đã được cập nhật.")
            }
        }
    }



    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }

    
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
//    @objc private func didTapChangeProfilePicture() {
//        let actionSheet = UIAlertController(title: "Profile Picture",
//                                            message: "Change Profile Picture",
//                                            preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
//            
//        }))
//        
//        actionSheet.addAction(UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in
//            
//        }))
//        
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        actionSheet.popoverPresentationController?.sourceView = view
//        actionSheet.popoverPresentationController?.sourceRect = view.bounds
//        
//        present(actionSheet, animated: true)
//    }
    @objc private func didTapChangeProfilePicture() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "Change Profile Picture",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker(sourceType: .camera)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose From Library", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker(sourceType: .photoLibrary)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // For iPad
        actionSheet.popoverPresentationController?.sourceView = view
        actionSheet.popoverPresentationController?.sourceRect = view.bounds
        
        present(actionSheet, animated: true)
    }

    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    private func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self,
                  let data = snapshot?.data(),
                  error == nil else {
                print("Failed to load user data")
                return
            }

            self.models.removeAll()

            // 🔁 Lấy ảnh đại diện
            if let photoURLString = data["profile_photo_url"] as? String,
               let photoURL = URL(string: photoURLString) {
                DispatchQueue.main.async {
                    self.profilePhotoButton.sd_setBackgroundImage(with: photoURL, for: .normal)
                }
            }

            // 🔁 Lấy lại full name từ field "name"
            let fullName = data["name"] as? String ?? ""

            let section1 = [
                EditProfileFormModel(label: "Name", placeholder: "Enter Name", value: fullName),
                EditProfileFormModel(label: "Username", placeholder: "Enter Username", value: data["username"] as? String),
                EditProfileFormModel(label: "Bio", placeholder: "Enter Bio", value: data["bio"] as? String)
            ]

            let section2 = [
                EditProfileFormModel(label: "Email", placeholder: "Enter Email", value: data["email"] as? String),
                EditProfileFormModel(label: "Phone", placeholder: "Enter Phone", value: data["phone"] as? String),
                EditProfileFormModel(label: "Gender", placeholder: "Enter Gender", value: data["gender"] as? String)
            ]

            self.models = [section1, section2]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    
}

extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.identifier, for: indexPath) as! FormTableViewCell
        let model = models[indexPath.section][indexPath.row]
        
        cell.configure(with: model)
        
        cell.delegate = self // nhận delegate từ formtableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 1 else {
            return nil
        }
        return "Private Information"
    }
}

extension EditProfileViewController: FormTableViewCellDelete {
    func formTableViewCell(_ cell: FormTableViewCell, didUpdatedField updatedModel: EditProfileFormModel) {
        // Cập nhật lại model trong mảng models
        for sectionIndex in 0..<models.count {
            for rowIndex in 0..<models[sectionIndex].count {
                if models[sectionIndex][rowIndex].label == updatedModel.label {
                    models[sectionIndex][rowIndex].value = updatedModel.value
                    break
                }
            }
        }
    }
}

//Xử lý ảnh sau khi chọn
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage,
              let imageData = image.jpegData(compressionQuality: 0.8),
              let userID = Auth.auth().currentUser?.uid else {
            return
        }

        let storageRef = Storage.storage().reference().child("profile_pictures/\(userID).jpg")

        // Upload image
        storageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
            guard error == nil else {
                print("Upload failed: \(error!.localizedDescription)")
                return
            }

            // Get download URL
            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Failed to get download URL")
                    return
                }

                // Update Firestore
                let db = Firestore.firestore()
                db.collection("users").document(userID).updateData([
                    "profile_photo_url": downloadURL.absoluteString
                ]) { error in
                    if let error = error {
                        print("Failed to update Firestore: \(error.localizedDescription)")
                    } else {
                        print("Profile photo updated")

                        // Optional: cập nhật UI
                        DispatchQueue.main.async {
                            self?.updateHeaderImage(url: downloadURL)
                        }
                    }
                }
            }
        }
    }
    private func updateHeaderImage(url: URL) {
        if let header = tableView.tableHeaderView,
           let button = header.subviews.compactMap({ $0 as? UIButton }).first {
            button.sd_setBackgroundImage(with: url, for: .normal)
        }
    }

}
