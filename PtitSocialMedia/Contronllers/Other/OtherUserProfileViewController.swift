//
//  OtherUserProfileViewController.swift
//  PtitSocialMedia
//
//  Created by Assistant on 25/02/2026.
//

import UIKit
import FirebaseAuth
import SDWebImage

class OtherUserProfileViewController: UIViewController {
    
    private let userId: String
    private var user: User?
    private var userPosts = [UserPost]()
    private var isFollowing = false
    
    private var collectionView: UICollectionView?
    
    // MARK: - Header Views
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.image = UIImage(systemName: "person.circle")
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let postsCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.text = "0\nPosts"
        label.numberOfLines = 2
        return label
    }()
    
    private let followersCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.text = "0\nFollowers"
        label.numberOfLines = 2
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let followingCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.text = "0\nFollowing"
        label.numberOfLines = 2
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Follow", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        return button
    }()
    
    // MARK: - Init
    init(userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        followButton.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
        
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(didTapFollowers))
        followersCountLabel.addGestureRecognizer(followersTap)
        
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(didTapFollowing))
        followingCountLabel.addGestureRecognizer(followingTap)
        
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        let size = (view.width - 4) / 3
        layout.itemSize = CGSize(width: size, height: size)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(PhotoCollectionViewCell.self,
                                 forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView?.register(UICollectionReusableView.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                 withReuseIdentifier: "ProfileHeader")
        
        guard let collectionView = collectionView else { return }
        view.addSubview(collectionView)
    }
    
    // MARK: - Data Loading
    private func loadData() {
        // Fetch user info
        DatabaseManager.shared.fetchUser(uid: userId) { [weak self] user in
            guard let self = self else { return }
            self.user = user
            self.title = user.username
            
            // Fetch follower/following count
            DatabaseManager.shared.fetchFollowerFollowingCount(uid: self.userId) { followers, following in
                self.followersCountLabel.text = "\(followers)\nFollowers"
                self.followingCountLabel.text = "\(following)\nFollowing"
            }
            
            // Fetch posts
            DatabaseManager.shared.fetchUserPosts(uid: self.userId, currentUser: user) { posts in
                self.userPosts = posts
                self.postsCountLabel.text = "\(posts.count)\nPosts"
                self.collectionView?.reloadData()
            }
            
            // Check follow status
            DatabaseManager.shared.checkFollowStatus(targetUID: self.userId) { isFollowing in
                self.isFollowing = isFollowing
                self.updateFollowButton()
            }
            
            // Update header
            self.nameLabel.text = user.name
            self.bioLabel.text = user.bio
            if let url = user.profilePhoto {
                self.profileImageView.sd_setImage(with: url, completed: nil)
            }
            self.collectionView?.reloadData()
        }
    }
    
    private func updateFollowButton() {
        DispatchQueue.main.async {
            if self.isFollowing {
                self.followButton.setTitle("Unfollow", for: .normal)
                self.followButton.backgroundColor = .systemGray5
                self.followButton.setTitleColor(.label, for: .normal)
                self.followButton.layer.borderWidth = 1
                self.followButton.layer.borderColor = UIColor.systemGray3.cgColor
            } else {
                self.followButton.setTitle("Follow", for: .normal)
                self.followButton.backgroundColor = .systemBlue
                self.followButton.setTitleColor(.white, for: .normal)
                self.followButton.layer.borderWidth = 0
            }
        }
    }
    
    // MARK: - Actions
    @objc private func didTapFollowButton() {
        if isFollowing {
            DatabaseManager.shared.unfollowUser(targetUID: userId) { [weak self] success in
                guard success else { return }
                self?.isFollowing = false
                self?.updateFollowButton()
                // Update follower count
                if let text = self?.followersCountLabel.text,
                   let countStr = text.components(separatedBy: "\n").first,
                   let count = Int(countStr) {
                    self?.followersCountLabel.text = "\(max(0, count - 1))\nFollowers"
                }
            }
        } else {
            DatabaseManager.shared.followUser(targetUID: userId) { [weak self] success in
                guard success else { return }
                self?.isFollowing = true
                self?.updateFollowButton()
                // Update follower count
                if let text = self?.followersCountLabel.text,
                   let countStr = text.components(separatedBy: "\n").first,
                   let count = Int(countStr) {
                    self?.followersCountLabel.text = "\(count + 1)\nFollowers"
                }
            }
        }
    }
    
    @objc private func didTapFollowers() {
        DatabaseManager.shared.fetchFollowersList(uid: userId) { [weak self] data in
            let vc = ListViewController(data: data)
            vc.title = "Followers"
            vc.navigationItem.largeTitleDisplayMode = .never
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func didTapFollowing() {
        DatabaseManager.shared.fetchFollowingList(uid: userId) { [weak self] data in
            let vc = ListViewController(data: data)
            vc.title = "Following"
            vc.navigationItem.largeTitleDisplayMode = .never
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - CollectionView
extension OtherUserProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    // Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "ProfileHeader",
            for: indexPath
        )
        
        // Remove old subviews
        header.subviews.forEach { $0.removeFromSuperview() }
        
        let width = header.frame.width
        let photoSize: CGFloat = width / 4
        
        // Profile photo
        profileImageView.frame = CGRect(x: 10, y: 10, width: photoSize, height: photoSize)
        profileImageView.layer.cornerRadius = photoSize / 2
        header.addSubview(profileImageView)
        
        // Counts
        let countWidth = (width - photoSize - 30) / 3
        let countY: CGFloat = 10
        let countHeight: CGFloat = photoSize / 2
        
        postsCountLabel.frame = CGRect(x: photoSize + 20, y: countY, width: countWidth, height: countHeight)
        followersCountLabel.frame = CGRect(x: postsCountLabel.frame.maxX, y: countY, width: countWidth, height: countHeight)
        followingCountLabel.frame = CGRect(x: followersCountLabel.frame.maxX, y: countY, width: countWidth, height: countHeight)
        
        header.addSubview(postsCountLabel)
        header.addSubview(followersCountLabel)
        header.addSubview(followingCountLabel)
        
        // Follow button
        followButton.frame = CGRect(x: photoSize + 20,
                                     y: countHeight + 15,
                                     width: countWidth * 3,
                                     height: 35)
        header.addSubview(followButton)
        
        // Name label
        nameLabel.frame = CGRect(x: 10,
                                  y: photoSize + 20,
                                  width: width - 20,
                                  height: 22)
        header.addSubview(nameLabel)
        
        // Bio label
        let bioHeight = bioLabel.sizeThatFits(CGSize(width: width - 20, height: .greatestFiniteMagnitude)).height
        bioLabel.frame = CGRect(x: 10,
                                 y: nameLabel.frame.maxY + 4,
                                 width: width - 20,
                                 height: max(bioHeight, 20))
        header.addSubview(bioLabel)
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let photoSize = collectionView.width / 4
        let bioHeight = bioLabel.sizeThatFits(CGSize(width: collectionView.width - 20, height: .greatestFiniteMagnitude)).height
        return CGSize(width: collectionView.width, height: photoSize + 60 + bioHeight)
    }
}
