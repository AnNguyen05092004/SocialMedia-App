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

/// States of a rendered cell
enum PostRenderType {
    case header(provider: User)
    case primaryContent(provider: UserPost) //post
    case action(provider: String) // Like, comment, share
    case comments(comments: [PostComment])
}

/// Model of rendered Post
struct PostRenderViewModel {
    let renderType: PostRenderType
}

class PostViewController: UIViewController {
    
    private var model: UserPost?
    
    private var renderModels = [PostRenderViewModel]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        
        // register cell
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
        configureModels() // Unless can not render UI
    }
    
//    private func configureModels() {
//        guard let userPostModel = self.model else {
//            return
//        }
//        
//        // Header
//        renderModels.append(PostRenderViewModel(renderType: .header(provider: userPostModel.owner)))
//        
//        // Post
//        renderModels.append(PostRenderViewModel(renderType: .primaryContent(provider: userPostModel)))
//        
//        // Actions
//        renderModels.append(PostRenderViewModel(renderType: .action(provider: "")))
//        
//        // 4 Comment
//        var comments = [PostComment]()
//        for x in 0..<4 {
//            comments.append(PostComment(identifier: "123\(x)", username: "@Binh", text: "Great Post", createdDate: Date(), like: []))
//        }
//        renderModels.append(PostRenderViewModel(renderType: .comments(comments: comments)))
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureModels() {
        guard let userPostModel = self.model else {
            return
        }

        // Header
        renderModels.append(PostRenderViewModel(renderType: .header(provider: userPostModel.owner)))

        // Post
        renderModels.append(PostRenderViewModel(renderType: .primaryContent(provider: userPostModel)))

        // Actions
        renderModels.append(PostRenderViewModel(renderType: .action(provider: userPostModel.identifier)))

        // Comments (dùng comment thật từ model)
        renderModels.append(PostRenderViewModel(renderType: .comments(comments: userPostModel.comments)))
    }

    
}

extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return renderModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch renderModels[section].renderType {
            case.action(_): return 1
            case.comments(let commments): return commments.count>4 ? 4 : commments.count
            case.primaryContent(_): return 1
            case.header(_): return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = renderModels[indexPath.section]
        switch model.renderType {
        case .header(let user):
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostHeaderTableViewCell.identifier, for: indexPath) as! FeedPostHeaderTableViewCell
            cell.configure(with: user)
            return cell

        case .primaryContent(let post):
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostTableViewCell.identifier, for: indexPath) as! FeedPostTableViewCell
            cell.configure(with: post)
            return cell

            case .action(let postID):
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: FeedPostActionsTableViewCell.identifier,
                    for: indexPath
                ) as! FeedPostActionsTableViewCell

                cell.postID = postID
                cell.delegate = self

                // ✅ Tìm UserPost từ renderModels (giả sử section - 1 là .primaryContent)
                if indexPath.section > 0,
                   case .primaryContent(let post) = renderModels[indexPath.section - 1].renderType {
                    let currentUID = Auth.auth().currentUser?.uid ?? ""
                    let isLiked = post.likeCount.contains { $0.userId == currentUID }
                    cell.configure(with: post, isLikedByUser: isLiked, likeCount: post.likeCount.count, commentCount: post.comments.count)
                }

                return cell



        case .comments(let comments):
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: FeedPostGeneralTableViewCell.identifier,
                    for: indexPath
                ) as! FeedPostGeneralTableViewCell

                let comment = comments[indexPath.row]
                cell.configure(with: comment)
                return cell
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = renderModels[indexPath.section]
        
        switch model.renderType {
            case.header(_): return 70
            case.primaryContent(_): return tableView.width + 40
            case.action(_): return 110
            case.comments(_): return 50
        }
    }
}

extension PostViewController: FeedPostActionsTableViewCellDelegate {
    func didTapLikeButton(postID: String) {
        print("Liked post with ID: \(postID)")
        // TODO: handle Firestore like logic if needed
    }

    func didTapComnentButton(postID: String) {
        print("Comment tapped on post ID: \(postID)")
        // TODO: present CommentViewController if needed
    }

    func didTapSendButton() {
        print("Send tapped")
        // TODO: handle share or message
    }
    
}
