//
//  DatabaseManager.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//
// escaping: dùng Nếu closure được gọi sau khi hàm đã kết thúc, sau khi chạy bất đồng bộ

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let db = Firestore.firestore()
    
    private init() {}

    // MARK: - User
    func updateUserProfile(uid: String, data: [String: Any], completion: @escaping (Bool) -> Void) {
        db.collection("users").document(uid).updateData(data) { error in
            completion(error == nil)
        }
    }
    // Lấy đủ các trường của user
    func getUserProfile(uid: String, completion: @escaping ([String: Any]?) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            completion(snapshot?.data())
        }
    }
    
    func updateUserProfilePhotoURL(uid: String, url: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(uid).updateData([
            "profile_photo_url": url
        ]) { error in
            completion(error == nil)
        }
    }
    
    
    // Fetch Current User: Lấy những trường cần thiết để hiển thị lên màn hình
    func fetchCurrentUser(completion: @escaping (User?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print(" Failed to fetch user")
                completion(nil)
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

// MARK: - Post
// Fetch Posts of User by userId
    func fetchUserPosts(uid: String, currentUser: User, completion: @escaping ([UserPost]) -> Void) {
        db.collection("posts")
            .whereField("user_id", isEqualTo: uid)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents, error == nil else {
                    print(" Failed to fetch posts")
                    completion([])
                    return
                }
                
                var posts = [UserPost]()
                let group = DispatchGroup()
                
                for doc in documents {
                    let data = doc.data()
                    guard let urlStr = data["post_url"] as? String,
                          let url = URL(string: urlStr) else { continue }
                    
                    let postID = doc.documentID
                    group.enter()
                    
                    var postLikes: [PostLike] = []
                    var postComments: [PostComment] = []
                    
                    let innerGroup = DispatchGroup()
                    
                    // Fetch likes
                    innerGroup.enter()
                    self.fetchLikes(for: postID) { likes in
                        postLikes = likes
                        innerGroup.leave()
                    }
                    
                    // Fetch comments
                    innerGroup.enter()
                    self.fetchComments(for: postID) { comments in
                        postComments = comments
                        innerGroup.leave()
                    }
                    
                    innerGroup.notify(queue: .main) {
                        let post = UserPost(
                            identifier: postID,
                            postType: .photo,
                            thumbnailImage: url,
                            postURL: url,
                            caption: data["caption"] as? String ?? "",
                            likeCount: postLikes,
                            comments: postComments,
                            createdData: Date(),
                            taggedUsers: [],
                            owner: currentUser
                        )
                        posts.append(post)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(posts)
                }
            }
    }


// Create post
    func createPost(caption: String, imageURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        let postID = UUID().uuidString
        let timestamp = Timestamp(date: Date())
        let postData: [String: Any] = [
            "id": postID,
            "user_id": currentUser.uid,
            "username": currentUser.displayName ?? currentUser.email ?? "anonymous",
            "caption": caption,
            "post_url": imageURL.absoluteString,
            "timestamp": timestamp
        ]
        
        db.collection("posts").document(postID).setData(postData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                NotificationCenter.default.post(name: Notification.Name("newPostCreated"), object: nil)
                completion(.success(()))
            }
        }
    }


// Fetch All Posts
    func fetchAllPosts(completion: @escaping ([HomeFeedRenderViewModel]) -> Void) {
        db.collection("posts")
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents, error == nil else {
                    print(" Failed to fetch posts: \(error?.localizedDescription ?? "")")
                    completion([])
                    return
                }
                
                var renderModels: [HomeFeedRenderViewModel] = []
                let group = DispatchGroup()
                
                for doc in documents {
                    let data = doc.data()
                    guard
                        let postURLStr = data["post_url"] as? String,
                        let postURL = URL(string: postURLStr),
                        let userId = data["user_id"] as? String,
                        let timestamp = data["timestamp"] as? Timestamp
                    else {
                        continue
                    }
                    
                    group.enter()
                    
                    // Lấy thông tin user từ Firestore
                    self.db.collection("users").document(userId).getDocument { userSnapshot, _ in
                        let userData = userSnapshot?.data()
                        let user = self.createUserModel(from: userData ?? [:], userId: userId)
                        
                        let postID = doc.documentID
                        var postLikes: [PostLike] = []
                        var postComments: [PostComment] = []
                        
                        let innerGroup = DispatchGroup()
                        
                        // Fetch likes
                        innerGroup.enter()
                        self.fetchLikes(for: postID) { likes in
                            postLikes = likes
                            innerGroup.leave()
                        }
                        
                        // Fetch comments
                        innerGroup.enter()
                        self.fetchComments(for: postID) { comments in
                            postComments = comments
                            innerGroup.leave()
                        }
                        
                        // Sau khi fetch cả likes và comments
                        innerGroup.notify(queue: .main) {
                            let post = UserPost(
                                identifier: postID,
                                postType: .photo,
                                thumbnailImage: postURL,
                                postURL: postURL,
                                caption: data["caption"] as? String ?? "",
                                likeCount: postLikes,
                                comments: postComments,
                                createdData: timestamp.dateValue(),
                                taggedUsers: [],
                                owner: user
                            )

                            let viewModel = HomeFeedRenderViewModel(
                                header: PostRenderViewModel(renderType: .header(provider: user)),
                                post: PostRenderViewModel(renderType: .primaryContent(provider: post)),
                                actions: PostRenderViewModel(renderType: .action(provider: post.identifier)),
                                comments: PostRenderViewModel(renderType: .comments(comments: postComments))
                            )

                            renderModels.append(viewModel)
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    completion(renderModels)
                }
            }
    }



// - Explore Posts
    func fetchExplorePosts(completion: @escaping ([UserPost]) -> Void) {
        db.collection("posts").order(by: "timestamp", descending: true).getDocuments { [weak self] snapshot, error in
            guard let self = self,
                  let documents = snapshot?.documents, error == nil else {
                print("Failed to fetch explore posts: \(error?.localizedDescription ?? "")")
                completion([])
                return
            }

            var newModels: [UserPost] = []
            let group = DispatchGroup()

            for doc in documents {
                let data = doc.data()
                guard let postURLStr = data["post_url"] as? String,
                      let url = URL(string: postURLStr),
                      let userId = data["user_id"] as? String else {
                    continue
                }

                group.enter()
                
                // Fetch user data
                self.db.collection("users").document(userId).getDocument { userSnapshot, _ in
                    let userData = userSnapshot?.data()
                    let user = self.createUserModel(from: userData ?? [:], userId: userId)

                    let postID = doc.documentID
                    var likes: [PostLike] = []
                    var comments: [PostComment] = []

                    let innerGroup = DispatchGroup()
                    
                    // Fetch likes
                    innerGroup.enter()
                    self.fetchLikes(for: postID) { fetchedLikes in
                        likes = fetchedLikes
                        innerGroup.leave()
                    }
                    
                    // Fetch comments
                    innerGroup.enter()
                    self.fetchComments(for: postID) { fetchedComments in
                        comments = fetchedComments
                        innerGroup.leave()
                    }

                    innerGroup.notify(queue: .main) {
                        let post = UserPost(
                            identifier: postID,
                            postType: .photo,
                            thumbnailImage: url,
                            postURL: url,
                            caption: data["caption"] as? String ?? "",
                            likeCount: likes,
                            comments: comments,
                            createdData: Date(),
                            taggedUsers: [],
                            owner: user
                        )

                        newModels.append(post)
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                completion(newModels)
            }
        }
    }



// MARK: - Like
    func toggleLike(
            postID: String,
            completion: @escaping (Bool, Error?) -> Void
        ) {
            guard let user = Auth.auth().currentUser else {
                completion(false, nil)
                return
            }

            let likeRef = db.collection("posts").document(postID).collection("likes").document(user.uid)

            likeRef.getDocument { snapshot, error in
                if snapshot?.exists == true {
                    // Unlike
                    likeRef.delete { error in
                        completion(false, error)
                    }
                } else {
                    // Like
                    let likeData: [String: Any] = [
                        "userId": user.uid,
                        "postIdentifier": postID,
                        "timestamp": Timestamp(date: Date())
                    ]
                    likeRef.setData(likeData) { error in
                        completion(true, error)
                    }
                }
            }
        }

        func addLikeNotification(postID: String, likedBy: String) {
            let notificationID = UUID().uuidString

            db.collection("posts").document(postID).getDocument { snapshot, error in
                guard let data = snapshot?.data(),
                      let postOwner = data["user_id"] as? String,
                      postOwner != likedBy else {
                    return
                }

                let notificationData: [String: Any] = [
                    "id": notificationID,
                    "type": "like",
                    "fromUserId": likedBy,
                    "toUserId": postOwner,
                    "postId": postID,
                    "timestamp": Timestamp(date: Date())
                ]

                self.db.collection("notifications").document(notificationID).setData(notificationData)
            }
        }


    
    // MARK: - Follower / Following Count
    func fetchFollowerFollowingCount(uid: String, completion: @escaping (Int, Int) -> Void) {
        let userRef = db.collection("users").document(uid)
        let group = DispatchGroup() //xử lý bất đồng bộ song song
        var followers = 0
        var following = 0
        
        group.enter()
        userRef.collection("followers").getDocuments { snapshot, _ in
            followers = snapshot?.documents.count ?? 0
            group.leave()
        }
        
        group.enter()
        userRef.collection("following").getDocuments { snapshot, _ in
            following = snapshot?.documents.count ?? 0
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(followers, following)
        }
    }
    
 
    
    
    // MARK: - Fetch Notifications
    // - Fetch User by Id
    func fetchUser(uid: String, completion: @escaping (User) -> Void) {
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
    
    // - Fetch Post by Id
    func fetchPost(postId: String, completion: @escaping (UserPost) -> Void) {
        let postRef = db.collection("posts").document(postId)
        
        postRef.getDocument { [weak self] snapshot, error in
            guard let self = self,
                  let data = snapshot?.data(),
                  let postURLStr = data["post_url"] as? String,
                  let postURL = URL(string: postURLStr),
                  let userId = data["user_id"] as? String else {
                return
            }
            
            // Fetch user data
            self.db.collection("users").document(userId).getDocument { userSnapshot, _ in
                let userData = userSnapshot?.data()
                let user = self.createUserModel(from: userData ?? [:], userId: userId)
                
                // Fetch likes and comments
                let group = DispatchGroup()
                var likes: [PostLike] = []
                var comments: [PostComment] = []
                
                // Fetch likes
                group.enter()
                self.fetchLikes(for: postId) { fetchedLikes in
                    likes = fetchedLikes
                    group.leave()
                }
                
                // Fetch comments
                group.enter()
                self.fetchComments(for: postId) { fetchedComments in
                    comments = fetchedComments
                    group.leave()
                }
                
                // Create post after fetching all data
                group.notify(queue: .main) {
                    let post = UserPost(
                        identifier: postId,
                        postType: .photo,
                        thumbnailImage: postURL,
                        postURL: postURL,
                        caption: data["caption"] as? String ?? "",
                        likeCount: likes,
                        comments: comments,
                        createdData: Date(),
                        taggedUsers: [],
                        owner: user
                    )
                    completion(post)
                }
            }
        }
    }

    // - Fetch Notifications
    func fetchNotifications(completion: @escaping ([UserNotification]) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }

        db.collection("notifications")
            .whereField("toUserId", isEqualTo: currentUserID)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    completion([])
                    return
                }

                var notifications: [UserNotification] = []
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
                            notifications.append(model)
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    completion(notifications)
                }
            }
    }

    // MARK: - Helper Methods
    
    func fetchLikes(for postID: String, completion: @escaping ([PostLike]) -> Void) {
        let postRef = db.collection("posts").document(postID)
        postRef.collection("likes").getDocuments { snapshot, _ in
            let likes: [PostLike] = snapshot?.documents.compactMap { likeDoc in
                let likeData = likeDoc.data()
                guard let likeUserId = likeData["userId"] as? String else { return nil }
                return PostLike(userId: likeUserId, postIdentifier: postID)
            } ?? []
            completion(likes)
        }
    }
    
    func fetchComments(for postID: String, completion: @escaping ([PostComment]) -> Void) {
        let postRef = db.collection("posts").document(postID)
        postRef.collection("comments").getDocuments { snapshot, _ in
            let comments: [PostComment] = snapshot?.documents.compactMap { commentDoc in
                let commentData = commentDoc.data()
                guard
                    let commentUsername = commentData["username"] as? String,
                    let text = commentData["text"] as? String,
                    let timestamp = commentData["created_at"] as? Timestamp,
                    let postIdentifier = commentData["postIdentifier"] as? String
                else {
                    return nil
                }
                
                return PostComment(
                    identifier: commentDoc.documentID,
                    postIdentifier: postIdentifier,
                    username: commentUsername,
                    text: text,
                    createdDate: timestamp.dateValue(),
                    like: []
                )
            } ?? []
            completion(comments)
        }
    }
    
    private func createUserModel(from data: [String: Any], userId: String) -> User {
        let profilePhoto = (data["profile_photo_url"] as? String).flatMap { URL(string: $0) }
        return User(
            userId: userId,
            username: data["username"] as? String ?? "",
            bio: data["bio"] as? String ?? "",
            name: data["name"] as? String ?? "",
            profilePhoto: profilePhoto,
            birthDate: Date(),
            gender: .other,
            counts: UserCount(followers: 0, following: 0, posts: 0),
            joinDate: Date()
        )
    }

    // MARK: - Comment Operations
    
    func addComment(postID: String, text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        // Lấy username từ user profile
        getUserProfile(uid: user.uid) { [weak self] userData in
            guard let self = self else { return }
            
            let username = userData?["username"] as? String ?? user.displayName ?? user.email ?? "anonymous"
            let newCommentID = UUID().uuidString
            let now = Date()
            
            let commentData: [String: Any] = [
                "username": username,
                "userId": user.uid,
                "text": text,
                "postIdentifier": postID,
                "created_at": Timestamp(date: now)
            ]
            
            let commentRef = self.db.collection("posts").document(postID).collection("comments").document(newCommentID)
            
            commentRef.setData(commentData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    
    func observeComments(for postID: String, completion: @escaping ([PostComment]) -> Void) -> ListenerRegistration {
        return db.collection("posts")
            .document(postID)
            .collection("comments")
            .order(by: "created_at", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    completion([])
                    return
                }
                
                let comments = documents.compactMap { doc -> PostComment? in
                    let data = doc.data()
                    guard
                        let username = data["username"] as? String,
                        let text = data["text"] as? String,
                        let timestamp = data["created_at"] as? Timestamp,
                        let postIdentifier = data["postIdentifier"] as? String
                    else {
                        return nil
                    }
                    
                    return PostComment(
                        identifier: doc.documentID,
                        postIdentifier: postIdentifier,
                        username: username,
                        text: text,
                        createdDate: timestamp.dateValue(),
                        like: []
                    )
                }
                
                completion(comments)
            }
    }
}

