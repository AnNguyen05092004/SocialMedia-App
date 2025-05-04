//
//  NotificationsViewController.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//

import UIKit

enum UserNotificationType {
    case like(post: UserPost)
    case follow(state: FollowState)
}

struct UserNotification {
    let type: UserNotificationType
    let text: String
    let user: User
}

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
    
    private func fetchNotifications() {
        for x in 0...100 {
            let user = User(username: "@an",
                            bio: "Ptit student",
                            name: (first: "Nguyen", last: "An"),
                            profilePhoto: URL(string: "https://www.google.com/")!,
                            birthDate: Date(),
                            gender: .male,
                            counts: UserCount(followers: 1, following: 2, posts: 2),
                            joinDate: Date())
            let post = UserPost(identifier: "",
                                postType: .photo,
                                thumbnailImage: URL(string: "https://www.google.com/")!,
                                postURL: URL(string: "https://www.google.com/")!,
                                caption: "This post is hardcode",
                                likeCount: [],
                                comments: [],
                                createdData: Date(),
                                taggedUsers: [], 
                                owner: user)
            let model = UserNotification(type: x%2==0 ?.like(post: post) : .follow(state: .following),
                                         text: "An like your post",
                                         user: user)
            models.append(model)
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
