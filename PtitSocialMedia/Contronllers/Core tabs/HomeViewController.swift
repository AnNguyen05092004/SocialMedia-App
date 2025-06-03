//
//  ViewController.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 27/03/2025.
//

//    
//    private func createMockModels() {
//        let user = User(username: "@an",
//                        bio: "Ptit student",
//                        name: (first: "Nguyen", last: "An"),
//                        profilePhoto: URL(string: "https://www.google.com/")!,
//                        birthDate: Date(),
//                        gender: .male,
//                        counts: UserCount(followers: 1, following: 2, posts: 2),
//                        joinDate: Date())
//        let post = UserPost(identifier: "",
//                            postType: .photo,
//                            thumbnailImage: URL(string: "https://www.google.com/")!,
//                            postURL: URL(string: "https://www.google.com/")!,
//                            caption: "This post is hardcode",
//                            likeCount: [],
//                            comments: [],
//                            createdData: Date(),
//                            taggedUsers: [],
//                            owner: user)
//        var comments = [PostComment]()
//        for x in 0..<4 {
//            comments.append(PostComment(identifier: "\(x)", username: "@Binh", text: "This is the besst Post", createdDate: Date(), like: []))
//        }
//        
//        for x in 0..<5 {
//            let viewModel = HomeFeedRenderViewModel(header: PostRenderViewModel(renderType: .header(provider: user)),
//                                                    post: PostRenderViewModel(renderType: .primaryContent(provider: post)),
//                                                    actions: PostRenderViewModel(renderType: .action(provider: "")),
//                                                    comments: PostRenderViewModel(renderType: .comments(comments: comments)))
//            feedRenderModels.append(viewModel)
//        }
//    }


import UIKit
import Firebase
import FirebaseFirestore

struct HomeFeedRenderViewModel {
    let header: PostRenderViewModel
    var post: PostRenderViewModel
    var actions: PostRenderViewModel
    let comments: PostRenderViewModel
}

class HomeViewController: UIViewController {
    
    private var feedRenderModels = [HomeFeedRenderViewModel]()
    
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
        handleNoAuthenticated()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(didCreateNewPost), name: Notification.Name("newPostCreated"), object: nil)
        // đăng ký lắng nghe notification "newPostCreated", để khi có bài viết mới thì gọi tiếp
        loadPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func handleNoAuthenticated() {
        if Auth.auth().currentUser == nil {
            let loginVc = LoginViewController()
            loginVc.modalPresentationStyle = .fullScreen
            present(loginVc, animated: true)
        }
    }
    
    @objc private func didCreateNewPost() {
        loadPosts()
    }

    private func loadPosts() {
        DatabaseManager.shared.fetchAllPosts { [weak self] models in
            self?.feedRenderModels = models
            self?.tableView.reloadData()
        }
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedRenderModels.count * 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let position = section / 4
        let model = feedRenderModels[position]
        let subSection = section % 4
        switch subSection {
            case 0, 1, 2:
                return 1
            case 3:
                switch model.comments.renderType {
                    case .comments(let comments):
                        return comments.count > 2 ? 2 : comments.count
                    default: return 0
                }
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let position = indexPath.section / 4
        let model = feedRenderModels[position]
        let subSection = indexPath.section % 4
        
        switch subSection {
            case 0:
                if case .header(let user) = model.header.renderType {
                    let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostHeaderTableViewCell.identifier, for: indexPath) as! FeedPostHeaderTableViewCell
                    cell.configure(with: user)
                    return cell
                }

            case 1:
                if case .primaryContent(let post) = model.post.renderType {
                    let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostTableViewCell.identifier, for: indexPath) as! FeedPostTableViewCell
                    cell.configure(with: post)
                    return cell
                }
                
            case 2:
                if case .action(let postID) = model.actions.renderType,
                   case .primaryContent(let post) = model.post.renderType {
                    
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: FeedPostActionsTableViewCell.identifier,
                        for: indexPath
                    ) as! FeedPostActionsTableViewCell
                    
                    cell.postID = postID
                    cell.delegate = self
                    
                    let likes = post.likeCount
                    let currentUID = Auth.auth().currentUser?.uid ?? ""
                    let isLiked = likes.contains { $0.userId == currentUID }
                    
                    //  GỌI CẤU HÌNH MỚI CÓ COMMENT COUNT
                    cell.configure(
                        with: post,
                        isLikedByUser: isLiked,
                        likeCount: likes.count,
                        commentCount: post.comments.count
                    )
                    
                    return cell
                }
                
                
            case 3:
                if case .comments(let comments) = model.comments.renderType {
                    let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostGeneralTableViewCell.identifier, for: indexPath) as! FeedPostGeneralTableViewCell
                    // TODO: configure comments later
                    return cell
                }
            default:
                break
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let subSection = indexPath.section % 4
        switch subSection {
            case 0: return 70
            case 1: return tableView.width + 40
            case 2: return 60
            case 3: return 50
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section % 4 == 3 ? 70 : 0
    }
}

extension HomeViewController: FeedPostHeaderTableViewCellDelegate {
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

extension HomeViewController: FeedPostActionsTableViewCellDelegate {
    
    func didTapLikeButton(postID: String) {
            guard let user = Auth.auth().currentUser else { return }

            // Tìm vị trí bài viết trong feedRenderModels
            guard let index = self.feedRenderModels.firstIndex(where: {
                if case .action(let id) = $0.actions.renderType {
                    return id == postID
                }
                return false
            }) else {
                return
            }

            DatabaseManager.shared.toggleLike(postID: postID) { [weak self] liked, error in
                guard let self = self else { return }

                if let error = error {
                    print("Toggle like error: \(error.localizedDescription)")
                    return
                }

                self.updateLike(at: index, liked: liked, userId: user.uid)

                if liked {
                    DatabaseManager.shared.addLikeNotification(postID: postID, likedBy: user.uid)
                }
            }
        }

        private func updateLike(at index: Int, liked: Bool, userId: String) {
            var model = feedRenderModels[index]

            if case .primaryContent(var post) = model.post.renderType {
                if liked {
                    post.likeCount.append(PostLike(userId: userId, postIdentifier: post.identifier))
                } else {
                    post.likeCount.removeAll { $0.userId == userId }
                }

                model.post = PostRenderViewModel(renderType: .primaryContent(provider: post))
                model.actions = PostRenderViewModel(renderType: .action(provider: post.identifier))
                feedRenderModels[index] = model

                let section = index * 4 + 2
                DispatchQueue.main.async {
                    self.tableView.reloadSections(IndexSet(integer: section), with: .none)
                }
            }
        }
    
    
    func didTapComnentButton(postID: String) {
        let vc = CommentViewController()
        vc.postID = postID
        let nav = UINavigationController(rootViewController: vc)
        
        if #available(iOS 15.0, *) {
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.medium(), .large()] // Cho phép kéo lên
                sheet.prefersGrabberVisible = true    // Hiện thanh kéo
                sheet.preferredCornerRadius = 20
            }
        } else {
            // Fallback on earlier versions
        }
        
        present(nav, animated: true)
    }
    
    
    
    func didTapSendButton() {
        print("send")
    }
}
