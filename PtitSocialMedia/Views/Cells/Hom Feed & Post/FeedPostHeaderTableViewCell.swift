//
//  FeedPostHeaderTableViewCell.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 14/04/2025.
//

import UIKit
import SDWebImage

protocol FeedPostHeaderTableViewCellDelegate: AnyObject {
    func didTapMoreButton()
}

class FeedPostHeaderTableViewCell: UITableViewCell {

    static let identifier = "FeedPostHeaderTableViewCell"
    
    weak var delegate: FeedPostHeaderTableViewCellDelegate?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(moreButton)
        moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapMoreButton() {
        delegate?.didTapMoreButton()
    }
    
    public func configure(with model: User) {
        // configure the cell
        usernameLabel.text = model.username
        profileImageView.image = UIImage(systemName: "person.circle")
//        profileImageView.sd_setImage(with: model.profilePhoto, completed: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = contentView.height - 4
        profileImageView.frame = CGRect(x: 2, y: 2, width: size, height: size)
        profileImageView.layer.cornerRadius = size/2
        
        moreButton.frame = CGRect(x: contentView.width - size - 2, y: 2, width: size, height: size)
        
        usernameLabel.frame = CGRect(x: profileImageView.right + 10,
                                     y: 2,
                                     width: contentView.width - size*2 - 15,
                                     height: contentView.height-4)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}
