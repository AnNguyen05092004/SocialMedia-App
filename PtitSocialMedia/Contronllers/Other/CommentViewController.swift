//
//  CommentViewController.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 08/05/2025.
//

// CommentViewController.swift

import UIKit
import Firebase
import FirebaseFirestore
// CommentViewController.swift (hiển thị dạng modal 3/4 màn hình)


class CommentViewController: UIViewController {

    var postID: String = ""
    private var comments: [PostComment] = []

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "commentCell")
        return tableView
    }()

    private let commentInputField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Viết bình luận..."
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Gửi", for: .normal)
        return button
    }()

    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        view.addSubview(commentInputField)
        view.addSubview(sendButton)

        tableView.dataSource = self
        tableView.delegate = self

        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)

        observeComments()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let inputHeight: CGFloat = 50
        commentInputField.frame = CGRect(x: 10, y: view.height - inputHeight - view.safeAreaInsets.bottom, width: view.width - 80, height: inputHeight)
        sendButton.frame = CGRect(x: commentInputField.frame.maxX + 5, y: commentInputField.frame.minY, width: 50, height: inputHeight)
        tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: commentInputField.frame.minY)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Đặt modal sheet style để hiển thị 3/4 chiều cao
        if #available(iOS 15.0, *) {
            if let presentationController = presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()] // hoặc [.medium(), .large()] nếu muốn cho phép kéo lên toàn màn
                presentationController.prefersGrabberVisible = true
            }
        } else {
            // Fallback on earlier versions
        }
    }

    private func observeComments() {
        let db = Firestore.firestore()
        listener = db.collection("posts").document(postID).collection("comments").order(by: "created_at", descending: false).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, error == nil, let documents = snapshot?.documents else { return }

            self.comments = documents.compactMap { doc in
                let data = doc.data()
                guard let username = data["username"] as? String,
                      let text = data["text"] as? String,
                      let timestamp = data["created_at"] as? Timestamp else {
                    return nil
                }
                return PostComment(identifier: doc.documentID, username: username, text: text, createdDate: timestamp.dateValue(), like: [])
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    deinit {
        listener?.remove()
    }

    @objc private func didTapSend() {
        guard let text = commentInputField.text, !text.isEmpty,
              let user = Auth.auth().currentUser else {
            return
        }

        let db = Firestore.firestore()
        let newCommentID = UUID().uuidString
        let commentData: [String: Any] = [
            "username": user.displayName ?? user.email ?? "anonymous",
            "text": text,
            "created_at": Timestamp(date: Date())
        ]

        db.collection("posts").document(postID).collection("comments").document(newCommentID).setData(commentData) { [weak self] error in
            guard let self = self, error == nil else { return }
            self.commentInputField.text = ""
        }
    }
}

extension CommentViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let comment = comments[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(comment.username): \(comment.text)"
        return cell
    }
}
