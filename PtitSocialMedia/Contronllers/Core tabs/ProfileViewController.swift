//
//  ProfileViewController.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    private var collectionView: UICollectionView?
    
    private var userPosts = [UserPost]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
        
        layout.minimumInteritemSpacing = 1 //kcach giữa các item
        layout.minimumLineSpacing = 1
        
        let size = (view.width - 4)/3
        layout.itemSize = CGSize(width: size, height: size)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        // cell
        collectionView?.register(PhotoCollectionViewCell.self,
                                 forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        // Header
        collectionView?.register(ProfileInfoHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ProfileInfoHeaderCollectionReusableView.identifier)
        collectionView?.register(ProfileTabsCollectionReusableView.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                 withReuseIdentifier: ProfileTabsCollectionReusableView.identifier)
        
        guard let collectionView = collectionView else {
            return
        }
        view.addSubview(collectionView)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrentUser()
    }


    private func configureNavigationBar(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettingButton))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    @objc private func didTapSettingButton() {
        let vc = SettingsViewController()
        vc.title = "Setting"
        navigationController?.pushViewController(vc, animated: true) //chuyển sang màn hình mới có nút back về.
    }
    
    
    private var currentUser: User?
    private func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self,
                  let data = snapshot?.data(),
                  error == nil else {
                print("Failed to fetch user")
                return
            }

            let username = data["username"] as? String ?? ""
            let bio = data["bio"] as? String ?? ""
            let name = data["name"] as? String ?? ""
            let profilePhotoURL = URL(string: data["profile_photo_url"] as? String ?? "")

            // Fetch followers & following count
            self.fetchFollowerFollowingCount(for: uid) { followers, following in
                let user = User(
                    userId: uid,
                    username: username,
                    bio: bio,
                    name: name,
                    profilePhoto: profilePhotoURL,
                    birthDate: Date(),
                    gender: .other,
                    counts: UserCount(followers: followers, following: following, posts: 0),
                    joinDate: Date()
                )

                self.currentUser = user
                self.fetchUserPosts() // fetch bài post sau khi có user
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        }
    }

    
    private func fetchUserPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("posts")
            .whereField("user_id", isEqualTo: uid)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents,
                      error == nil else {
                    print("Failed to fetch posts")
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
                        owner: self.currentUser!
                    )
                    posts.append(post)
                }

                self.userPosts = posts

                // ✅ Cập nhật số lượng bài đăng vào currentUser.counts
                if var user = self.currentUser {
                    let newCounts = UserCount(
                        followers: user.counts.followers,
                        following: user.counts.following,
                        posts: posts.count
                    )
                    self.currentUser = User(
                        userId: user.userId,
                        username: user.username,
                        bio: user.bio,
                        name: user.name,
                        profilePhoto: user.profilePhoto,
                        birthDate: user.birthDate,
                        gender: user.gender,
                        counts: newCounts,
                        joinDate: user.joinDate
                    )
                }

                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
    }

    
    private func fetchFollowerFollowingCount(for userId: String, completion: @escaping (Int, Int) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        var followersCount = 0
        var followingCount = 0

        let group = DispatchGroup()

        group.enter()
        userRef.collection("followers").getDocuments { snapshot, _ in
            followersCount = snapshot?.documents.count ?? 0
            group.leave()
        }

        group.enter()
        userRef.collection("following").getDocuments { snapshot, _ in
            followingCount = snapshot?.documents.count ?? 0
            group.leave()
        }

        group.notify(queue: .main) {
            completion(followersCount, followingCount)
        }
    }

}


//UICollectionViewDelegateFlowLayout cho phép  kiểm soát kích thước và khoảng cách giữa các phần tử trong collectionView.
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return userPosts.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // let model = userPosts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
        let post = userPosts[indexPath.row]
        cell.configure(with: post)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let post = userPosts[indexPath.row]
        let vc = PostViewController(model: post)
        vc.title = post.postType.rawValue
        navigationController?.pushViewController(vc, animated: true)

    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            // footer
            return UICollectionReusableView()
        }
        
        if indexPath.section == 1 {
            // tab header
            let tabControlHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileTabsCollectionReusableView.identifier, for: indexPath) as! ProfileTabsCollectionReusableView
            tabControlHeader.delegate = self
            return tabControlHeader
        }
        
        let profileHeader = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ProfileInfoHeaderCollectionReusableView.identifier,
            for: indexPath
        ) as! ProfileInfoHeaderCollectionReusableView

        if let user = currentUser {
            profileHeader.configure(with: user)
        }
        profileHeader.delegate = self
        return profileHeader

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.width, 
                          height: collectionView.height/3)
        }
        // size of section tabs
        return CGSize(width: collectionView.width,
                      height: 50)
    }
}

extension ProfileViewController: ProfileInfoHeaderCollectionReusableViewDelete {
    func frofileHeaderDidTapPostsButton(_ header: ProfileInfoHeaderCollectionReusableView) {
        guard userPosts.count > 0 else {
            let alert = UIAlertController(title: "Bạn chưa có bài viết nào", message: "Hãy đăng bài đầu tiên nhé!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        collectionView?.scrollToItem(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
    }

    
    func frofileHeaderDidTapFollowersButton(_ header: ProfileInfoHeaderCollectionReusableView) {
        var mockData = [UserRelationship]()
        for x in 0..<10 {
            mockData.append(UserRelationship(name: "An", username: "@An", type: x%2==0 ? .following : .notFollowing))
        }
        let vc = ListViewController(data: mockData)
        vc.title = "Followers"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func frofileHeaderDidTapFollowingButton(_ header: ProfileInfoHeaderCollectionReusableView) {
        var mockData = [UserRelationship]()
        for x in 0..<10 {
            mockData.append(UserRelationship(name: "An", username: "@An", type: x%2==0 ? .following : .notFollowing))
        }
        let vc = ListViewController(data: mockData)
        vc.title = "Following"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func frofileHeaderDidTapEditProfileButton(_ header: ProfileInfoHeaderCollectionReusableView) {
        let vc = EditProfileViewController()
        vc.title = "Edit Profile"
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension ProfileViewController: ProfileTabsCollectionReusableDelegate {
    func didTapGridButtonTab() {
        // reload colelction view with data
        
    }
    
    func didTapTaggedButtonTab() {
        //
    }
    
    
}
