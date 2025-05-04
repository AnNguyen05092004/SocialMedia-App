//
//  NotificationFollowEventTableViewCell.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 27/04/2025.
//

import UIKit

protocol NotificationFollowEventTableViewCellDelegate: AnyObject {
    func didTapFollowUnfollowButton(model: UserNotification)
}

class NotificationFollowEventTableViewCell: UITableViewCell {
    static let identifier = "NotificationFollowEventTableViewCell"
    
    weak var delegate: NotificationFollowEventTableViewCellDelegate?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .tertiarySystemBackground
        return imageView
    }()
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "@Thank started following you"
        return label
    }()
    private let followButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(profileImageView)
        contentView.addSubview(label)
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
    
    private var model: UserNotification?
    public func configure(with model: UserNotification){
        self.model = model
        switch model.type {
            case .like(_):
                break
            case .follow(let state):
                // configure button
                switch state {
                    case.following:
                        //Show unfollow button
                        followButton.setTitle("Unfollow", for: .normal)
                        followButton.setTitleColor(.label, for: .normal)
                        followButton.layer.borderWidth = 1
                        followButton.layer.borderColor = UIColor.secondaryLabel.cgColor
                        followButton.backgroundColor = .clear

                    case.notFollowing:
                        // show follow button
                        followButton.setTitle("Follow", for: .normal)
                        followButton.setTitleColor(.label, for: .normal)
                        followButton.backgroundColor = .link
                }
                
                break
        }
        label.text = model.text
        profileImageView.sd_setImage(with: model.user.profilePhoto, completed: nil)
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        followButton.setTitle(nil, for: .normal)
//        followButton.backgroundColor = nil
//        followButton.layer.borderWidth = 0
//        label.text = nil
//        profileImageView.image = nil
//    }
    override func prepareForReuse() {
        super.prepareForReuse()
        followButton.setTitle(nil, for: .normal)
        followButton.setTitleColor(nil, for: .normal)
        followButton.backgroundColor = nil
        followButton.layer.borderWidth = 0
        followButton.layer.borderColor = nil
        label.text = nil
        profileImageView.image = nil
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // photo, text, post button
        profileImageView.frame = CGRect(x: 3,
                                        y: 3,
                                        width: contentView.height-6,
                                        height: contentView.height-6)
        profileImageView.layer.cornerRadius = profileImageView.height/2
        
        let size: CGFloat = 100
        followButton.frame = CGRect(x: contentView.width-size-5,
                                    y: (contentView.height-40)/2,
                                  width: size,
                                  height: 40)
        label.frame = CGRect(x: profileImageView.right+5,
                             y: 0,
                             width: contentView.width-size-profileImageView.width-(6+5+5),
                             height: contentView.height)
    }
}
