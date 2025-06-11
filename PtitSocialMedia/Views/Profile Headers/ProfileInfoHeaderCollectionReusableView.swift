//
//  ProfileInfoHeaderCollectionReusableView.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 19/04/2025.
//

import UIKit
import SDWebImage

protocol ProfileInfoHeaderCollectionReusableViewDelete: AnyObject {
    func frofileHeaderDidTapPostsButton(_ header: ProfileInfoHeaderCollectionReusableView)
    func frofileHeaderDidTapFollowersButton(_ header: ProfileInfoHeaderCollectionReusableView)
    func frofileHeaderDidTapFollowingButton(_ header: ProfileInfoHeaderCollectionReusableView)
    func frofileHeaderDidTapEditProfileButton(_ header: ProfileInfoHeaderCollectionReusableView)
}

class ProfileInfoHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "ProfileInfoHeaderCollectionReusableView"
    
    public weak var delegate: ProfileInfoHeaderCollectionReusableViewDelete?
    
    private let profilePhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let postsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Posts", for: .normal)
        button.setTitleColor(.label, for: .normal) //tự động thích ứng với chế độ sáng/tối
        button.backgroundColor = .secondarySystemBackground
        return button
    }()
    
    private let followingButton: UIButton = {
        let button = UIButton()
        button.setTitle("Following", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .secondarySystemBackground
        return button
    }()
    
    private let followersButton: UIButton = {
        let button = UIButton()
        button.setTitle("Followers", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .secondarySystemBackground
        return button
    }()
    
    private let editProfileButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit your profile", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .secondarySystemBackground
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Nguyen Van An"
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.text = "I am a student in PTIT"
        label.textColor = .label
        label.numberOfLines = 0 // tự động xuống dòng
        return label
    }()
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        clipsToBounds = true
        addSubview()
        addButtonActions()
    }
    private func addSubview() {
        addSubview(profilePhotoImageView)
        addSubview(followingButton)
        addSubview(followersButton)
        addSubview(postsButton)
        addSubview(nameLabel)
        addSubview(bioLabel)
        addSubview(editProfileButton)
    }
    private func addButtonActions() {
        followersButton.addTarget(self, action: #selector(didTapFollowersButton), for: .touchUpInside)
        followingButton.addTarget(self, action: #selector(didTapFollowingButton), for: .touchUpInside)
        postsButton.addTarget(self, action: #selector(didTapPostsButton), for: .touchUpInside)
        editProfileButton.addTarget(self, action: #selector(didTapEditProfileButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with user: User) {
        nameLabel.text = user.name
        bioLabel.text = user.bio

        // Ảnh đại diện
        if let url = user.profilePhoto {
            profilePhotoImageView.sd_setImage(with: url, completed: nil)
        } else {
            profilePhotoImageView.image = UIImage(systemName: "person.circle")
        }

        // Số liệu
        postsButton.setTitle("\(user.counts.posts)\nPosts", for: .normal)
        followersButton.setTitle("\(user.counts.followers)\nFollowers", for: .normal)
        followingButton.setTitle("\(user.counts.following)\nFollowing", for: .normal)

        // Cho phép nhiều dòng (xuống dòng) cho nút
        postsButton.titleLabel?.numberOfLines = 0
        followersButton.titleLabel?.numberOfLines = 0
        followingButton.titleLabel?.numberOfLines = 0

        postsButton.titleLabel?.textAlignment = .center
        followersButton.titleLabel?.textAlignment = .center
        followingButton.titleLabel?.textAlignment = .center
    }


    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let profilePhotoSize = width/4
        profilePhotoImageView.layer.cornerRadius = profilePhotoSize/2.0
        profilePhotoImageView.frame = CGRect(x: 5,
                                             y: 5,
                                             width: profilePhotoSize,
                                             height: profilePhotoSize).integral
        
        let buttonHeight = profilePhotoSize/2
        let countButtonWidth = (width - 10 - profilePhotoSize)/3
        
        postsButton.frame = CGRect(x: profilePhotoImageView.right,
                                   y: 5,
                                   width: countButtonWidth,
                                   height: buttonHeight).integral
        
        followersButton.frame = CGRect(x: postsButton.right,
                                   y: 5,
                                   width: countButtonWidth,
                                   height: buttonHeight).integral
        followingButton.frame = CGRect(x: followersButton.right,
                                   y: 5,
                                   width: countButtonWidth,
                                   height: buttonHeight).integral
        
        editProfileButton.frame = CGRect(x: profilePhotoImageView.right,
                                   y: 5 + buttonHeight,
                                   width: countButtonWidth*3,
                                   height: buttonHeight).integral
        
        nameLabel.frame = CGRect(x: 5,
                                 y: 5 + profilePhotoImageView.bottom,
                                 width: width - 10,
                                 height: 50).integral
        
        //Tính kích thước vừa đủ để hiển thị toàn bộ nội dung của bioLabel, dựa trên kích thước khung hiện tại
        let bioLabelSize = bioLabel.sizeThatFits(frame.size)
        bioLabel.frame = CGRect(x: 5,
                                 y: 5 + nameLabel.bottom,
                                 width: width - 10,
                                height: bioLabelSize.height).integral
    }
    
    //MARK: - Action  button
    @objc private func didTapFollowersButton() {
        delegate?.frofileHeaderDidTapFollowersButton(self)
    }
    
    @objc private func didTapFollowingButton() {
        delegate?.frofileHeaderDidTapFollowingButton(self)
    }
    
    @objc private func didTapPostsButton() {
        delegate?.frofileHeaderDidTapPostsButton(self)
    }
    
    @objc private func didTapEditProfileButton() {
        delegate?.frofileHeaderDidTapEditProfileButton(self)
    }
}
