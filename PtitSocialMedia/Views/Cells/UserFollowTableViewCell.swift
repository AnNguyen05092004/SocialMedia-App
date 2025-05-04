//
//  UserFollowTableViewCell.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 25/04/2025.
//

import UIKit

protocol UserFollowTableViewCellDelete: AnyObject {
    func didTapFollowUnfollowButton(model: UserRelationship)
}

enum FollowState {
    case following   //the current user is following the other
    case notFollowing
}

struct UserRelationship {
    let name: String
    let username: String
    let type: FollowState
}

class UserFollowTableViewCell: UITableViewCell {
    static let identifier = "UserFollowTableViewCell"
    
    weak var delegate: UserFollowTableViewCellDelete?
    private var model: UserRelationship?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.text = "An"
        return label
    }()
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.text = "@An"
        label.textColor = .secondaryLabel
        return label
    }()
    private let followButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.text = "Follow"
        button.backgroundColor = .link
        return button
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(followButton)
        
        followButton.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
        
    }
    @objc private func didTapFollowButton() {
        guard let model = model else {
            return
        }
        delegate?.didTapFollowUnfollowButton(model: model)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with model: UserRelationship) {
        self.model = model
        nameLabel.text = model.name
        usernameLabel.text = model.username
        switch model.type {
            case .following:
                followButton.setTitle("Unfollow", for: .normal)
                followButton.setTitleColor(.label, for: .normal)
                followButton.backgroundColor = .systemBackground
                followButton.layer.borderWidth = 1
                followButton.layer.borderColor = UIColor.label.cgColor
            case .notFollowing:
                followButton.setTitle("Follow", for: .normal)
                followButton.setTitleColor(.white, for: .normal)
                followButton.backgroundColor = .link
                followButton.layer.borderWidth = 0
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        nameLabel.text = nil
        usernameLabel.text = nil
        followButton.setTitle(nil, for: .normal)
        followButton.layer.borderWidth = 0
        followButton.backgroundColor = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.frame = CGRect(x: 3,
                                        y: 3,
                                        width: contentView.height-6,
                                        height: contentView.height-6)
        profileImageView.layer.cornerRadius = profileImageView.height/2.0
        
        let buttonwidth = contentView.width/3
        followButton.frame = CGRect(x: contentView.width-6-buttonwidth,
                                    y: 15,
                                    width: buttonwidth,
                                    height: contentView.height - 30)
        
        let labelHeight = contentView.height/2
        nameLabel.frame = CGRect(x: profileImageView.right+10,
                                 y: 0,
                                 width: contentView.width-(3+3+10)-profileImageView.width-buttonwidth,
                                 height: labelHeight)
        usernameLabel.frame = CGRect(x: profileImageView.right+10,
                                     y: nameLabel.bottom,
                                     width: contentView.width-(3+3+10)-profileImageView.width-buttonwidth,
                                     height: labelHeight)
    }
}
