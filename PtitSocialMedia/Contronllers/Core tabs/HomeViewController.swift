//
//  ViewController.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 27/03/2025.
//
//
//import UIKit
//import Firebase
//import FirebaseFirestore
//
//struct HomeFeedRenderViewModel {
//    let header: PostRenderViewModel
//    let post: PostRenderViewModel
//    let actions: PostRenderViewModel
//    let comments: PostRenderViewModel
//}
//
//class HomeViewController: UIViewController {
//    
//    private var feedRenderModels = [HomeFeedRenderViewModel]()
//    
//    private let tableView: UITableView = {
//        let tableView = UITableView()
//        // register cell
//        tableView.register(FeedPostTableViewCell.self, forCellReuseIdentifier: FeedPostTableViewCell.identifier)
//        tableView.register(FeedPostHeaderTableViewCell.self, forCellReuseIdentifier: FeedPostHeaderTableViewCell.identifier)
//        tableView.register(FeedPostActionsTableViewCell.self, forCellReuseIdentifier: FeedPostActionsTableViewCell.identifier)
//        tableView.register(FeedPostGeneralTableViewCell.self, forCellReuseIdentifier: FeedPostGeneralTableViewCell.identifier)
//        return tableView
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        handleNoAuthenticated()
//        
////        do {
////            try Auth.auth().signOut()
////        } catch {
////            print ("Failed to sign out")
////        }
//        view.addSubview(tableView)
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        createMockModels()
//        fetchPostsFromFirestore()
//    }
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
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        tableView.frame = view.bounds
//    }
//    
//    private func handleNoAuthenticated() {
//        // check the status
//        if Auth.auth().currentUser == nil {
//            // show login
//            let loginVc = LoginViewController()
//            loginVc.modalPresentationStyle = .fullScreen
//            present(loginVc, animated: true)
//        }
//    }
//    
//    func fetchPostsFromFirestore() {
//        let db = Firestore.firestore()
//        db.collection("posts").order(by: "timestamp", descending: true).getDocuments { [weak self] snapshot, error in
//            guard let documents = snapshot?.documents, error == nil else {
//                print("Failed to fetch posts: \(error?.localizedDescription ?? "")")
//                return
//            }
//
//            self?.feedRenderModels.removeAll()
//
//            for doc in documents {
//                let data = doc.data()
//                guard
//                    let username = data["username"] as? String,
//                    let postURLStr = data["post_url"] as? String,
//                    let postURL = URL(string: postURLStr),
//                    let caption = data["caption"] as? String
//                else {
//                    continue
//                }
//
//                let dummyUser = User(
//                    username: username,
//                    bio: "",
//                    name: (first: "", last: ""),
//                    profilePhoto: nil,
//                    birthDate: Date(),
//                    gender: .other,
//                    counts: UserCount(followers: 0, following: 0, posts: 0),
//                    joinDate: Date()
//                )
//
//                let post = UserPost(
//                    identifier: doc.documentID,
//                    postType: .photo,
//                    thumbnailImage: postURL,
//                    postURL: postURL,
//                    caption: caption,
//                    likeCount: [],
//                    comments: [],
//                    createdData: Date(),
//                    taggedUsers: [],
//                    owner: dummyUser
//                )
//
//                let viewModel = HomeFeedRenderViewModel(
//                    header: PostRenderViewModel(renderType: .header(provider: dummyUser)),
//                    post: PostRenderViewModel(renderType: .primaryContent(provider: post)),
//                    actions: PostRenderViewModel(renderType: .action(provider: "")),
//                    comments: PostRenderViewModel(renderType: .comments(comments: []))
//                )
//
//                self?.feedRenderModels.append(viewModel)
//            }
//
//            DispatchQueue.main.async {
//                self?.tableView.reloadData()
//            }
//        }
//    }
//
//}
//
//extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return feedRenderModels.count * 4
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let x = section
//        let model: HomeFeedRenderViewModel
////        if x == 0 {
////            model = feedRenderModels[0]
////        } else {
////            let position = x % 4 == 0 ? x/4 : ((x-(x % 4)) / 4)
////            model = feedRenderModels[position]
////        }
//        let position = x/4
//        model = feedRenderModels[position]
//        
//        let subSection = x % 4
//        if subSection == 0 {
//            // header
//            return 1
//        } else if subSection == 1 {
//            // post
//            return 1
//        } else if subSection == 2 {
//            // actions
//            return 1
//        } else if subSection == 3 {
//            // comments
//            let commentsModel = model.comments
//            switch commentsModel.renderType {
//                case .comments(let comments):
//                    return comments.count > 2 ? 2 : comments.count
//                case .header, .action, .primaryContent: return 0
//            }
//        }
//        
////        switch renderModels[section].renderType {
////            case.action(_): return 1
////            case.comments(let commments): return commments.count>4 ? 4 : commments.count
////            case.primaryContent(_): return 1
////            case.header(_): return 1
////        }
//        return 0
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let x = indexPath.section
//        let model: HomeFeedRenderViewModel
//        //        if x == 0 {
//        //            model = feedRenderModels[0]
//        //        } else {
//        //            let position = x % 4 == 0 ? x/4 : ((x-(x % 4)) / 4)
//        //            model = feedRenderModels[position]
//        //        }
//        let position = x/4
//        model = feedRenderModels[position]
//        
//        let subSection = x % 4
//        if subSection == 0 {
//            // header
//            let headerModel = model.header
//            switch headerModel.renderType {
//                case.header(let user):
//                    let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostHeaderTableViewCell.identifier, for: indexPath) as! FeedPostHeaderTableViewCell
//                    cell.configure(with: user)
//                    cell.delegate = self
//                    return cell
//                case .comments, .action, .primaryContent: return UITableViewCell()
//            }
//        } else if subSection == 1 {
//            // post
//            let postModel = model.post
//            switch postModel.renderType {
//                case.primaryContent(let post):
//                    let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostTableViewCell.identifier, for: indexPath) as! FeedPostTableViewCell
//                    cell.configure(with: post)
//                    return cell
//                case .comments, .action, .header: return UITableViewCell()
//            }
//        } else if subSection == 2 {
//            // actions
//            let actionsModel = model.actions
//            switch actionsModel.renderType {
//                case.action(let actions):
//                    let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostActionsTableViewCell.identifier, for: indexPath) as! FeedPostActionsTableViewCell
//                    cell.delegate = self
//                    return cell
//                case .comments, .primaryContent, .header: return UITableViewCell()
//            }
//        } else if subSection == 3 {
//            // comments
//            let commentModel = model.comments
//            switch commentModel.renderType {
//                case .comments(let comments):
//                    let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostGeneralTableViewCell.identifier, for: indexPath) as! FeedPostGeneralTableViewCell
//                    return cell
//                case .primaryContent, .action, .header: return UITableViewCell()
//            }
//        }
//        return UITableViewCell()
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let subSection = indexPath.section % 4
//        if subSection == 0 {
//            return 70
//        } else if subSection == 1 {
//            return tableView.width
//        } else if subSection == 2 {
//            return 60
//        } else if subSection == 3 {
//            return 50
//        } else {
//            return 0
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return UIView()
//    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        let subSection = section % 4
//        return subSection == 3 ? 70 : 0
//    }
//}
//
//extension HomeViewController: FeedPostHeaderTableViewCellDelegate {
//    func didTapMoreButton() {
//        let actionSheet = UIAlertController(title: "Post Options", message: nil, preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { [weak self] _ in
//            self?.reportPost()
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        present(actionSheet, animated: true)
//    }
//    
//    func reportPost() {
//        
//    }
//}
//
//extension HomeViewController: FeedPostActionsTableViewCellDelegate {
//    func didTapLikeButton() {
//        print("like")
//    }
//    
//    func didTapComnentButton() {
//        print("comment")
//    }
//    
//    func didTapSendButton() {
//        print("send")
//    }
//    
//    
//}




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
        fetchPostsFromFirestore()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc private func didCreateNewPost() {
        fetchPostsFromFirestore()
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

    func fetchPostsFromFirestore() {
        let db = Firestore.firestore()
        db.collection("posts").order(by: "timestamp", descending: true).getDocuments { [weak self] snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Failed to fetch posts: \(error?.localizedDescription ?? "")")
                return
            }

            self?.feedRenderModels.removeAll()
            let group = DispatchGroup()

            for doc in documents {
                let data = doc.data()
                guard
                    let username = data["username"] as? String,
                    let postURLStr = data["post_url"] as? String,
                    let postURL = URL(string: postURLStr),
                    let caption = data["caption"] as? String
                else {
                    continue
                }

                let dummyUser = User(userId: Auth.auth().currentUser?.uid ?? "", username: username, bio: "", name: (""), profilePhoto: nil, birthDate: Date(), gender: .other, counts: UserCount(followers: 0, following: 0, posts: 0), joinDate: Date())

                let postID = doc.documentID
                let postRef = db.collection("posts").document(postID)

                group.enter()

                var postLikes: [PostLike] = []
                var postComments: [PostComment] = []

                // ✅ Fetch likes
                postRef.collection("likes").getDocuments { likeSnapshot, _ in
                    postLikes = likeSnapshot?.documents.compactMap { likeDoc in
                        let data = likeDoc.data()
                        guard let userId = data["userId"] as? String else { return nil }
                        return PostLike(userId: userId, postIdentifier: postID)
                    } ?? []

                    // ✅ Fetch comments
                    postRef.collection("comments").getDocuments { commentSnapshot, _ in
                        postComments = commentSnapshot?.documents.compactMap { commentDoc in
                            let data = commentDoc.data()
                            guard let username = data["username"] as? String,
                                  let text = data["text"] as? String,
                                  let timestamp = data["created_at"] as? Timestamp else {
                                return nil
                            }
                            return PostComment(identifier: commentDoc.documentID, username: username, text: text, createdDate: timestamp.dateValue(), like: [])
                        } ?? []

                        // ✅ Create post
                        let post = UserPost(
                            identifier: postID,
                            postType: .photo,
                            thumbnailImage: postURL,
                            postURL: postURL,
                            caption: caption,
                            likeCount: postLikes,
                            comments: postComments,
                            createdData: Date(),
                            taggedUsers: [],
                            owner: dummyUser
                        )

                        let viewModel = HomeFeedRenderViewModel(
                            header: PostRenderViewModel(renderType: .header(provider: dummyUser)),
                            post: PostRenderViewModel(renderType: .primaryContent(provider: post)),
                            actions: PostRenderViewModel(renderType: .action(provider: post.identifier)),
                            comments: PostRenderViewModel(renderType: .comments(comments: postComments))
                        )

//                        self?.feedRenderModels.append(viewModel)
                        self?.feedRenderModels.insert(viewModel, at: 0)
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                self?.tableView.reloadData()
            }
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
                cell.delegate = self
                return cell
            }
        case 1:
            if case .primaryContent(let post) = model.post.renderType {
                let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostTableViewCell.identifier, for: indexPath) as! FeedPostTableViewCell
                cell.configure(with: post)
                return cell
            }
//        case 2:
//            if case .action(let postID) = model.actions.renderType {
//                let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostActionsTableViewCell.identifier, for: indexPath) as! FeedPostActionsTableViewCell
//                cell.postID = postID
//                cell.delegate = self
//
//                return cell
//            }
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
        let db = Firestore.firestore()
        let likeRef = db.collection("posts").document(postID).collection("likes").document(user.uid)

        likeRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            // Tìm vị trí bài viết trong feedRenderModels
            guard let index = self.feedRenderModels.firstIndex(where: {
                if case .action(let id) = $0.actions.renderType {
                    return id == postID
                }
                return false
            }) else {
                return
            }

            if snapshot?.exists == true {
                // 👎 Đã like → unlike
                likeRef.delete { error in
                    if let error = error {
                        print("Unlike failed: \(error.localizedDescription)")
                    } else {
                        print("Unliked successfully")
                        self.updateLike(at: index, liked: false, userId: user.uid)
                    }
                }
            } else {
                // 👍 Chưa like → thêm like mới
                let likeData: [String: Any] = [
                    "userId": user.uid,
                    "postIdentifier": postID,
                    "timestamp": Timestamp(date: Date())
                ]
                likeRef.setData(likeData) { error in
                    if let error = error {
                        print("Like failed: \(error.localizedDescription)")
                    } else {
                        print("Liked successfully")
                        self.updateLike(at: index, liked: true, userId: user.uid)
                        self.addLikeNotification(postID: postID, likedBy: user.uid)
                    }
                }
            }
        }
    }

    private func updateLike(at index: Int, liked: Bool, userId: String) {
        var model = feedRenderModels[index]
        
        // Cập nhật like trong model.post.renderType
        if case .primaryContent(var post) = model.post.renderType {
            if liked {
                post.likeCount.append(PostLike(userId: userId, postIdentifier: post.identifier))
            } else {
                post.likeCount.removeAll { $0.userId == userId }
            }
            model.post = PostRenderViewModel(renderType: .primaryContent(provider: post))
            model.actions = PostRenderViewModel(renderType: .action(provider: post.identifier))
            feedRenderModels[index] = model

            // Reload chỉ section của bài viết
            let section = index * 4 + 2 // actions nằm ở subSection 2
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: section), with: .none)
            }
        }
    }

    
    
    func addLikeNotification(postID: String, likedBy: String) {
        let db = Firestore.firestore()
        let notificationID = UUID().uuidString

        // Bạn cần lấy owner của bài viết để gửi thông báo cho đúng người
        db.collection("posts").document(postID).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let postOwner = data["user_id"] as? String else {
                return
            }

            guard postOwner != likedBy else {
                return // Không tự thông báo cho chính mình
            }

            let notificationData: [String: Any] = [
                "id": notificationID,
                "type": "like",
                "fromUserId": likedBy,
                "toUserId": postOwner,
                "postId": postID,
                "timestamp": Timestamp(date: Date())
            ]

            db.collection("notifications").document(notificationID).setData(notificationData)
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
