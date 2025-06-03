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
        loadUserData()
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

    private func loadUserData() {
        DatabaseManager.shared.fetchCurrentUser { [weak self] user in
            guard let self = self, var user = user else { return }

            DatabaseManager.shared.fetchFollowerFollowingCount(uid: user.userId) { followers, following in
                user.counts = UserCount(followers: followers, following: following, posts: 0)

                self.currentUser = user

                DatabaseManager.shared.fetchUserPosts(uid: user.userId, currentUser: user) { posts in
                    self.userPosts = posts
                    self.currentUser?.counts.posts = posts.count

                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            }
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
            let alert = UIAlertController(title: "You dont have any post", message: "Let post!", preferredStyle: .alert)
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
