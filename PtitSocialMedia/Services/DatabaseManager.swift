//
//  DatabaseManager.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // escaping: dùng Nếu closure được gọi sau khi hàm đã kết thúc, sau khi chạy bất đồng bộ
    func updateUserProfile(uid: String, data: [String: Any], completion: @escaping (Bool) -> Void) {
        db.collection("users").document(uid).updateData(data) { error in
            completion(error == nil)
        }
    }
    
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
    
    
    // MARK: - Fetch Current User
    func fetchCurrentUser(completion: @escaping (User?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("⚠️ Failed to fetch user")
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
    
    // MARK: - Fetch Posts of User
    func fetchUserPosts(uid: String, currentUser: User, completion: @escaping ([UserPost]) -> Void) {
        db.collection("posts")
            .whereField("user_id", isEqualTo: uid)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("⚠️ Failed to fetch posts")
                    completion([])
                    return
                }
                
                var posts = [UserPost]()
                for doc in documents {
                    let data = doc.data()
                    guard let urlStr = data["post_url"] as? String,
                          let url = URL(string: urlStr) else { continue }
                    
                    let post = UserPost(
                        identifier: doc.documentID,
                        postType: .photo,
                        thumbnailImage: url,
                        postURL: url,
                        caption: data["caption"] as? String ?? "",
                        likeCount: [],
                        comments: [],
                        createdData: Date(),
                        taggedUsers: [],
                        owner: currentUser
                    )
                    posts.append(post)
                }
                
                completion(posts)
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
    
    //MARK: - Create post
    func createPost(caption: String, imageURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        let postID = UUID().uuidString
        let postData: [String: Any] = [
            "id": postID,
            "user_id": currentUser.uid,
            "username": currentUser.displayName ?? currentUser.email ?? "anonymous",
            "caption": caption,
            "post_url": imageURL.absoluteString,
            "timestamp": Timestamp(date: Date())
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
    
    // Fetch all Posts
//    func fetchAllPosts(completion: @escaping ([HomeFeedRenderViewModel]) -> Void) {
//        db.collection("posts").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
//            guard let documents = snapshot?.documents, error == nil else {
//                print("⚠️ Failed to fetch posts: \(error?.localizedDescription ?? "")")
//                completion([])
//                return
//            }
//            
//            var renderModels = [HomeFeedRenderViewModel]()
//            let group = DispatchGroup()
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
//                let postID = doc.documentID
//                let postRef = self.db.collection("posts").document(postID)
//               
//                
//                let dummyUser = User(
//                    userId: Auth.auth().currentUser?.uid ?? "",
//                    username: username,
//                    bio: "",
//                    name: "",
//                    profilePhoto: nil,
//                    birthDate: Date(),
//                    gender: .other,
//                    counts: UserCount(followers: 0, following: 0, posts: 0),
//                    joinDate: Date()
//                )
//                
//                group.enter()
//                
//                var postLikes: [PostLike] = []
//                var postComments: [PostComment] = []
//                
//                // Fetch likes
//                postRef.collection("likes").getDocuments { likeSnapshot, _ in
//                    postLikes = likeSnapshot?.documents.compactMap { likeDoc in
//                        let data = likeDoc.data()
//                        guard let userId = data["userId"] as? String else { return nil }
//                        return PostLike(userId: userId, postIdentifier: postID)
//                    } ?? []
//                    
//                    // Fetch comments
//                    postRef.collection("comments").getDocuments { commentSnapshot, _ in
//                        postComments = commentSnapshot?.documents.compactMap { commentDoc in
//                            let data = commentDoc.data()
//                            guard
//                                let username = data["username"] as? String,
//                                let text = data["text"] as? String,
//                                let timestamp = data["created_at"] as? Timestamp,
//                                let postIdentifier = data["postIdentifier"] as? String // 👈 THÊM
//                            else {
//                                return nil
//                            }
//
//                            return PostComment(
//                                identifier: commentDoc.documentID,
//                                postIdentifier: postIdentifier,
//                                username: username,
//                                text: text,
//                                createdDate: timestamp.dateValue(),
//                                like: []
//                            )
//                        } ?? []
//
//                        let post = UserPost(
//                            identifier: postID,
//                            postType: .photo,
//                            thumbnailImage: postURL,
//                            postURL: postURL,
//                            caption: caption,
//                            likeCount: postLikes,
//                            comments: postComments,
//                            createdData: Date(),
//                            taggedUsers: [],
//                            owner: dummyUser
//                        )
//
//                        let viewModel = HomeFeedRenderViewModel(
//                            header: PostRenderViewModel(renderType: .header(provider: dummyUser)),
//                            post: PostRenderViewModel(renderType: .primaryContent(provider: post)),
//                            actions: PostRenderViewModel(renderType: .action(provider: post.identifier)),
//                            comments: PostRenderViewModel(renderType: .comments(comments: postComments))
//                        )
//
//                        renderModels.append(viewModel)
//                        group.leave()
//                    }
//
//                }
//            }
//            
//            group.notify(queue: .main) {
//                completion(renderModels)
//            }
//        }
//    }
    
    func fetchAllPosts(completion: @escaping ([HomeFeedRenderViewModel]) -> Void) {
        db.collection("posts").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("⚠️ Failed to fetch posts: \(error?.localizedDescription ?? "")")
                completion([])
                return
            }
            
            var renderModels: [HomeFeedRenderViewModel] = []
            let group = DispatchGroup()
            
            for doc in documents {
                let data = doc.data()
                guard
                    let username = data["username"] as? String,
                    let postURLStr = data["post_url"] as? String,
                    let postURL = URL(string: postURLStr),
                    let caption = data["caption"] as? String,
                    let userId = data["user_id"] as? String // 👈 Firestore cần lưu userId của người đăng
                else {
                    continue
                }
                
                group.enter()
                
                // Lấy thông tin user từ Firestore
                self.db.collection("users").document(userId).getDocument { userSnapshot, _ in
                    let userData = userSnapshot?.data()
                    let profilePhoto = (userData?["profile_photo_url"] as? String).flatMap { URL(string: $0) }

                    let user = User(
                        userId: userId,
                        username: username,
                        bio: userData?["bio"] as? String ?? "",
                        name: userData?["name"] as? String ?? "",
                        profilePhoto: profilePhoto,
                        birthDate: Date(), // 🔧 Có thể cập nhật lại nếu có field này
                        gender: .other,
                        counts: UserCount(followers: 0, following: 0, posts: 0), // 🔧 Tùy chỉnh nếu cần
                        joinDate: Date()
                    )
                    
                    let postID = doc.documentID
                    let postRef = self.db.collection("posts").document(postID)
                    
                    var postLikes: [PostLike] = []
                    var postComments: [PostComment] = []
                    
                    let innerGroup = DispatchGroup()
                    innerGroup.enter()
                    
                    // Likes
                    postRef.collection("likes").getDocuments { likeSnapshot, _ in
                        postLikes = likeSnapshot?.documents.compactMap { likeDoc in
                            let likeData = likeDoc.data()
                            guard let likeUserId = likeData["userId"] as? String else { return nil }
                            return PostLike(userId: likeUserId, postIdentifier: postID)
                        } ?? []
                        innerGroup.leave()
                    }
                    
                    innerGroup.enter()
                    // Comments
                    postRef.collection("comments").getDocuments { commentSnapshot, _ in
                        postComments = commentSnapshot?.documents.compactMap { commentDoc in
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
                        innerGroup.leave()
                    }

                    // Sau khi fetch cả likes và comments
                    innerGroup.notify(queue: .main) {
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
                    // 👎 Unlike
                    likeRef.delete { error in
                        completion(false, error)
                    }
                } else {
                    // 👍 Like
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
    
//    func addLikeNotification(postID: String, likedBy: String) {
//        let notificationID = UUID().uuidString
//
//        db.collection("posts").document(postID).getDocument { snapshot, error in
//            guard let data = snapshot?.data(),
//                  let postOwner = data["user_id"] as? String,
//                  postOwner != likedBy else {
//                return
//            }
//
//            let notification = NotificationModel(
//                id: notificationID,
//                type: .like,
//                fromUserId: likedBy,
//                toUserId: postOwner,
//                postId: postID,
//                timestamp: Date()
//            )
//
//            self.db.collection("notifications").document(notificationID).setData(notification.toDictionary())
//        }
//    }

    
}

