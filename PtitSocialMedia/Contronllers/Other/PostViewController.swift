//
//  PostViewViewController.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//
/**
 _ Heder model
 - Post Cell model
 - Action Button Cell model
 - n Number of General models
 */

import UIKit
import Firebase

///// States of a rendered cell
//enum PostRenderType {
//    case header(provider: User)
//    case primaryContent(provider: UserPost) //post
//    case action(provider: String) // Like, comment, share
//    case comments(comments: [PostComment])
//}
//
///// Model of rendered Post
//struct PostRenderViewModel {
//    let renderType: PostRenderType
//}

class PostViewController: UIViewController {
    
    private var model: UserPost?
    private var postViewModel: PostViewModel?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FeedPostTableViewCell.self, forCellReuseIdentifier: FeedPostTableViewCell.identifier)
        tableView.register(FeedPostHeaderTableViewCell.self, forCellReuseIdentifier: FeedPostHeaderTableViewCell.identifier)
        tableView.register(FeedPostActionsTableViewCell.self, forCellReuseIdentifier: FeedPostActionsTableViewCell.identifier)
        tableView.register(FeedPostGeneralTableViewCell.self, forCellReuseIdentifier: FeedPostGeneralTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    init(model: UserPost?) {
        super.init(nibName: nil, bundle: nil)
        self.model = model
        configureModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureModel() {
        guard let userPostModel = self.model else { return }
        postViewModel = PostViewModel(post: userPostModel)
    }
}

// Model mới đơn giản hơn
struct PostViewModel {
    var post: UserPost
    
    var user: User {
        return post.owner
    }
    
    var postID: String {
        return post.identifier
    }
    
    var comments: [PostComment] {
        return post.comments
    }
    
    var likeCount: Int {
        return post.likeCount.count
    }
    
    var commentCount: Int {
        return post.comments.count
    }
    
    func isLikedByUser(_ userId: String) -> Bool {
        return post.likeCount.contains { $0.userId == userId }
    }
}

extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4  // Header, Content, Actions, Comments
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = postViewModel else { return 0 }
        
        switch section {
            case 0, 1, 2:
                return 1
            case 3:
                return min(model.comments.count, 5)
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = postViewModel else { return UITableViewCell() }
        
        switch indexPath.section {
            case 0: // Header
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: FeedPostHeaderTableViewCell.identifier,
                    for: indexPath
                ) as! FeedPostHeaderTableViewCell
                cell.configure(with: model.user)
                cell.delegate = self
                return cell
                
            case 1: // Content
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: FeedPostTableViewCell.identifier,
                    for: indexPath
                ) as! FeedPostTableViewCell
                cell.configure(with: model.post)
                return cell
                
            case 2: // Actions
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: FeedPostActionsTableViewCell.identifier,
                    for: indexPath
                ) as! FeedPostActionsTableViewCell
                
                cell.postID = model.postID
                cell.delegate = self
                
                let currentUID = Auth.auth().currentUser?.uid ?? ""
                let isLiked = model.isLikedByUser(currentUID)
                
                cell.configure(
                    with: model.post,
                    isLikedByUser: isLiked,
                    likeCount: model.likeCount,
                    commentCount: model.commentCount
                )
                return cell
                
            case 3: // Comments
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: FeedPostGeneralTableViewCell.identifier,
                    for: indexPath
                ) as! FeedPostGeneralTableViewCell
                
                let comment = model.comments[indexPath.row]
                cell.configure(with: comment)
                return cell
                
            default:
                break
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
            case 0: return 70
            case 1: return tableView.width + 40
            case 2: return 110
            case 3: return 50
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 3 ? 70 : 0
    }
}

extension PostViewController: FeedPostHeaderTableViewCellDelegate {
    func didTapMoreButton() {
        let actionSheet = UIAlertController(title: "Post Options", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { [weak self] _ in
            self?.reportPost()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    func reportPost() {
        // TODO: implement report
    }
}

extension PostViewController: FeedPostActionsTableViewCellDelegate {
    func didTapLikeButton(postID: String) {
        guard let user = Auth.auth().currentUser else { return }
        
        DatabaseManager.shared.toggleLike(postID: postID) { [weak self] liked, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Toggle like error: \(error.localizedDescription)")
                return
            }
            
            self.updateLike(liked: liked, userId: user.uid)
            
            if liked {
                DatabaseManager.shared.addLikeNotification(postID: postID, likedBy: user.uid)
            }
        }
    }
    
    private func updateLike(liked: Bool, userId: String) {
        guard var model = postViewModel else { return }
        
        if liked {
            model.post.likeCount.append(PostLike(userId: userId, postIdentifier: model.postID))
        } else {
            model.post.likeCount.removeAll { $0.userId == userId }
        }
        
        self.postViewModel = model // Gán lại model mới (đã được cập nhật like) vào self.postViewModel để lưu thay đổi.
        
        //Reload lại section thứ 2 của table view
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
        }
    }
    
    func didTapComnentButton(postID: String) {
        let vc = CommentViewController()
        vc.postID = postID
        let nav = UINavigationController(rootViewController: vc)
        
        if #available(iOS 15.0, *) {
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
        }
        
        present(nav, animated: true)
    }
    
    func didTapSendButton() {
        print("send")
    }
}
