//
//  NotificationsViewController.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

//enum UserNotificationType {
//    case like(post: UserPost)
//    case follow(state: FollowState)
//}
//
//struct UserNotification {
//    let type: UserNotificationType
//    let text: String
//    let user: User
//}

class NotificationsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        //tableView.isHidden = true
        tableView.register(NotificationLikeEventTableViewCell.self, forCellReuseIdentifier: NotificationLikeEventTableViewCell.identifier)
        tableView.register(NotificationFollowEventTableViewCell.self, forCellReuseIdentifier: NotificationFollowEventTableViewCell.identifier)
        return tableView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.tintColor = .label
        return spinner
    }()
    
    private lazy var noNotificationsView = NoNotificationsView()
    
    private var models = [UserNotification]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notifications"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(spinner)
        //spinner.startAnimating()
        
        fetchNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
        spinner.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        spinner.center = view.center
    }
    
//    private func fetchNotifications() {
//        for x in 0...100 {
//            let user = User(username: "@an",
//                            bio: "Ptit student",
//                            name: (first: "Nguyen", last: "An"),
//                            profilePhoto: URL(string: "https://www.google.com/")!,
//                            birthDate: Date(),
//                            gender: .male,
//                            counts: UserCount(followers: 1, following: 2, posts: 2),
//                            joinDate: Date())
//            let post = UserPost(identifier: "",
//                                postType: .photo,
//                                thumbnailImage: URL(string: "https://www.google.com/")!,
//                                postURL: URL(string: "https://www.google.com/")!,
//                                caption: "This post is hardcode",
//                                likeCount: [],
//                                comments: [],
//                                createdData: Date(),
//                                taggedUsers: [], 
//                                owner: user)
//            let model = UserNotification(type: x%2==0 ?.like(post: post) : .follow(state: .following),
//                                         text: "An like your post",
//                                         user: user)
//            models.append(model)
//        }
//    }
    
    private func fetchNotifications() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("notifications")
            .whereField("toUserId", isEqualTo: currentUserID)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents, error == nil else {
                    return
                }

                self.models.removeAll()
                let group = DispatchGroup()

                for doc in documents {
                    let data = doc.data()
                    guard let type = data["type"] as? String,
                          let fromUserId = data["fromUserId"] as? String,
                          let postId = data["postId"] as? String else {
                        continue
                    }

                    group.enter()
                    self.fetchUser(uid: fromUserId) { user in
                        self.fetchPost(postId: postId) { post in
                            let model = UserNotification(
                                type: .like(post: post),
                                text: "\(user.username) liked your post",
                                user: user
                            )
                            self.models.append(model)
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    self.tableView.reloadData()
                    if self.models.isEmpty {
                        self.addNoNotificationsView()
                    }
                }
            }
    }


    private func fetchUser(uid: String, completion: @escaping (User) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Failed to fetch user info")
                return
            }

            let user = User(
                userId: uid,
                username: data["username"] as? String ?? "",
                bio: data["bio"] as? String ?? "",
                name: data["name"] as? String ?? "",
                profilePhoto: URL(string: data["profile_photo_url"] as? String ?? ""),
                birthDate: Date(),
                gender: .other,
                counts: UserCount(followers: 0, following: 0, posts: 0),
                joinDate: Date()
            )
            completion(user)
        }
    }


    private func fetchPost(postId: String, completion: @escaping (UserPost) -> Void) {
        let db = Firestore.firestore()
        db.collection("posts").document(postId).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let username = data["username"] as? String,
                  let postURLStr = data["post_url"] as? String,
                  let postURL = URL(string: postURLStr) else {
                return
            }

            let dummyUser = User(userId: Auth.auth().currentUser?.uid ?? "", username: username, bio: "", name: (""), profilePhoto: nil, birthDate: Date(), gender: .other, counts: UserCount(followers: 0, following: 0, posts: 0), joinDate: Date())

            let post = UserPost(identifier: postId,
                                postType: .photo,
                                thumbnailImage: postURL,
                                postURL: postURL,
                                caption: data["caption"] as? String,
                                likeCount: [],
                                comments: [],
                                createdData: Date(),
                                taggedUsers: [],
                                owner: dummyUser)
            completion(post)
        }
    }

    
    private func addNoNotificationsView() {
        tableView.isHidden = true
        view.addSubview(tableView)
        noNotificationsView.frame = CGRect(x: 0, y: 0, width: view.width/2, height: view.width/3)
        noNotificationsView.center = view.center
    }
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = models[indexPath.row]
        switch model.type {
            case.like(_):
                // like cell
                let cell = tableView.dequeueReusableCell(withIdentifier: NotificationLikeEventTableViewCell.identifier,
                                                         for: indexPath) as! NotificationLikeEventTableViewCell
                cell.configure(with: model)
                cell.delegate = self
                return cell
            case.follow:
                // follow cell
                let cell = tableView.dequeueReusableCell(withIdentifier: NotificationFollowEventTableViewCell.identifier,
                                                         for: indexPath) as! NotificationFollowEventTableViewCell
                cell.configure(with: model)
                cell.delegate = self
                return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
}

extension NotificationsViewController: NotificationLikeEventTableViewCellDelegate {
    func didTapRelatedPostButton(model: UserNotification) {
        print("Tapped post")
        // Open the post
        switch model.type {
            case.like(let post):
                let vc = PostViewController(model: post)
                vc.title = post.postType.rawValue
                vc.navigationItem.largeTitleDisplayMode = .never
                navigationController?.pushViewController(vc, animated: true)
            case.follow(_):
                fatalError("Dev issue: Should never get called")
        }
    }
}

extension NotificationsViewController: NotificationFollowEventTableViewCellDelegate {
    func didTapFollowUnfollowButton(model: UserNotification) {
        print("Tapped Button")
        // perform database update
        
    }
    
    
}
