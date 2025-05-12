//
//  ExploreViewController.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 28/03/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ExploreViewController: UIViewController {
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .secondarySystemBackground
        searchBar.placeholder = "Search.."
        return searchBar
    }()
    
    private var models = [UserPost]()

    private var collectionView: UICollectionView?
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.isHidden = true
        view.alpha = 0.4
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        let layout = UICollectionViewFlowLayout() //layout mặc định dùng để sắp xếp các item (cell) theo dòng và cột.
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //kcach giữa nội dung và lề
        layout.itemSize = CGSize(width: (view.width-4)/3, height: (view.width-4)/3)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        guard let collectionView = collectionView else {
            return
        }
        view.addSubview(collectionView)
        view.addSubview(dimmedView)
        
        searchBar.delegate = self
        
        fetchExplorePosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
        dimmedView.frame = view.bounds
        
    }
    private func fetchExplorePosts() {
        let db = Firestore.firestore()
        db.collection("posts").order(by: "timestamp", descending: true).getDocuments { [weak self] snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Failed to fetch explore posts: \(error?.localizedDescription ?? "")")
                return
            }

            var newModels: [UserPost] = []
            let group = DispatchGroup()

            for doc in documents {
                let data = doc.data()
                guard let postURLStr = data["post_url"] as? String,
                      let url = URL(string: postURLStr),
                      let username = data["username"] as? String else {
                    continue
                }

                let dummyUser = User(
                    userId: Auth.auth().currentUser?.uid ?? "",
                    username: username,
                    bio: "",
                    name: (""),
                    profilePhoto: nil,
                    birthDate: Date(),
                    gender: .other,
                    counts: UserCount(followers: 0, following: 0, posts: 0),
                    joinDate: Date()
                )

                let postID = doc.documentID
                let postRef = db.collection("posts").document(postID)

                group.enter()

                var likes: [PostLike] = []
                var comments: [PostComment] = []

                // 1. Fetch likes
                postRef.collection("likes").getDocuments { likeSnapshot, _ in
                    likes = likeSnapshot?.documents.compactMap { likeDoc in
                        let data = likeDoc.data()
                        guard let userId = data["userId"] as? String else { return nil }
                        return PostLike(userId: userId, postIdentifier: postID)
                    } ?? []

                    // 2. Fetch comments
                    postRef.collection("comments").getDocuments { commentSnapshot, _ in
                        comments = commentSnapshot?.documents.compactMap { commentDoc in
                            let data = commentDoc.data()
                            guard let username = data["username"] as? String,
                                  let text = data["text"] as? String,
                                  let timestamp = data["created_at"] as? Timestamp else {
                                return nil
                            }
                            return PostComment(
                                identifier: commentDoc.documentID,
                                username: username,
                                text: text,
                                createdDate: timestamp.dateValue(),
                                like: []
                            )
                        } ?? []

                        let post = UserPost(
                            identifier: postID,
                            postType: .photo,
                            thumbnailImage: url,
                            postURL: url,
                            caption: data["caption"] as? String,
                            likeCount: likes,
                            comments: comments,
                            createdData: Date(),
                            taggedUsers: [],
                            owner: dummyUser
                        )

                        newModels.append(post)
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                self?.models = newModels
                self?.collectionView?.reloadData()
            }
        }
    }


}

extension ExploreViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        didTapCancelSearch()
        
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        //query(text)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapCancelSearch))
        dimmedView.isHidden = false
    }
    @objc private func didTapCancelSearch() {
        searchBar.resignFirstResponder()
        navigationItem.rightBarButtonItem = nil
        dimmedView.isHidden = true
    }
}

extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
//            return UICollectionViewCell()
//        }
//        //cell.configure(with:  )
//        cell.configure(debug: "test")
//        return cell
//    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.identifier,
            for: indexPath
        ) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }

        let post = models[indexPath.row]
        cell.configure(with: post.thumbnailImage)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let post = models[indexPath.row]
        let vc = PostViewController(model: post)
        navigationController?.pushViewController(vc, animated: true)
    }


    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
//        //let model = models[indexPath.row]
//        
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
//        
//        let vc = PostViewController(model: post)
//        vc.title = post.postType.rawValue
//        navigationController?.pushViewController(vc, animated: true)
//    }
}
