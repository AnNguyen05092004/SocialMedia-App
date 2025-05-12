//
//  FeedPostActionsTableViewCell.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 14/04/2025.
//
//
//import UIKit
//
////protocol FeedPostActionsTableViewCellDelegate: AnyObject {
////    func didTapLikeButton()
////    func didTapComnentButton()
////    func didTapSendButton()
////}
//
//protocol FeedPostActionsTableViewCellDelegate: AnyObject {
//    func didTapLikeButton(postID: String)
//    func didTapComnentButton(postID: String)
//    func didTapSendButton()
//}
//
//
//class FeedPostActionsTableViewCell: UITableViewCell {
//    public var postID: String?
//
//
//    static let identifier = "FeedPostActionsTableViewCell"
//    
//    weak var delegate: FeedPostActionsTableViewCellDelegate?
//
//    private let likeButton: UIButton = {
//        let button = UIButton()
//        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
//        let image  = UIImage(systemName: "heart", withConfiguration: config)
//        button.setImage(image, for: .normal)
//        button.tintColor = .label
//        return button
//    }()
//    private let commentButton: UIButton = {
//        let button = UIButton()
//        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
//        let image  = UIImage(systemName: "message", withConfiguration: config)
//        button.setImage(image, for: .normal)
//        button.tintColor = .label
//        return button
//    }()
//    private let sendButton: UIButton = {
//        let button = UIButton()
//        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
//        let image  = UIImage(systemName: "paperplane", withConfiguration: config)
//        button.setImage(image, for: .normal)
//        button.tintColor = .label
//        return button
//    }()
//    
//    
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        contentView.addSubview(likeButton)
//        contentView.addSubview(commentButton)
//        contentView.addSubview(sendButton)
//        
//        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
//        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
//        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
////    @objc private func didTapLikeButton() {
////        delegate?.didTapLikeButton()
////    }
//    @objc private func didTapLikeButton() {
//        if let id = postID {
//            delegate?.didTapLikeButton(postID: id)
//        }
//    }
//
////    @objc private func didTapCommentButton() {
////        delegate?.didTapComnentButton()
////    }
//    @objc private func didTapCommentButton() {
//        if let id = postID {
//            delegate?.didTapComnentButton(postID: id)
//        }
//    }
//
//    
//    @objc private func didTapSendButton() {
//        delegate?.didTapSendButton()
//    }
//    
//    public func configure(with post: UserPost) {
//        // configure the cell
//        
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        // like, comment, send
//        let buttonSize = contentView.height - 10
//        let buttons = [likeButton, commentButton, sendButton]
//        for x in 0..<buttons.count {
//            let button = buttons[x]
//            button.frame = CGRect(x: (CGFloat(x)*buttonSize) + (10*CGFloat(x+1)), y: 5, width: buttonSize, height: buttonSize)
//        }
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        
//    }
//}

// FeedPostActionsTableViewCell.swift

import UIKit

protocol FeedPostActionsTableViewCellDelegate: AnyObject {
    func didTapLikeButton(postID: String)
    func didTapComnentButton(postID: String)
    func didTapSendButton()
}

class FeedPostActionsTableViewCell: UITableViewCell {

    static let identifier = "FeedPostActionsTableViewCell"

    weak var delegate: FeedPostActionsTableViewCellDelegate?
    public var postID: String?

    public var isLiked: Bool = false {
        didSet {
            let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
            let imageName = isLiked ? "heart.fill" : "heart"
            likeButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
            likeButton.tintColor = isLiked ? .systemRed : .label
        }
    }

    private let likeButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let image  = UIImage(systemName: "heart", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()

    private let commentButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let image  = UIImage(systemName: "message", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()

    private let sendButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let image  = UIImage(systemName: "paperplane", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()

    private let likesCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()
    private let commentCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(sendButton)
        contentView.addSubview(likesCountLabel)
        contentView.addSubview(commentCountLabel)
        
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTapLikeButton() {
        if let id = postID {
            delegate?.didTapLikeButton(postID: id)
        }
    }

    @objc private func didTapCommentButton() {
        if let id = postID {
            delegate?.didTapComnentButton(postID: id)
        }
    }

    @objc private func didTapSendButton() {
        delegate?.didTapSendButton()
    }


    public func configure(with post: UserPost, isLikedByUser: Bool, likeCount: Int, commentCount: Int) {
        self.isLiked = isLikedByUser
        likesCountLabel.text = "\(likeCount) lượt thích"
        commentCountLabel.text = "\(commentCount) bình luận"
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let buttonSize: CGFloat = 40
        let padding: CGFloat = 10

        let buttons = [likeButton, commentButton, sendButton]
        for (index, button) in buttons.enumerated() {
            button.frame = CGRect(
                x: CGFloat(index) * (buttonSize + padding) + padding,
                y: padding,
                width: buttonSize,
                height: buttonSize
            )
        }

        // Label dưới buttons
        let labelY = likeButton.frame.maxY + 8
        likesCountLabel.frame = CGRect(x: padding, y: labelY, width: contentView.width - 2 * padding, height: 18)
        
        // Đẩy commentCountLabel xuống sâu hơn để tránh đè
        commentCountLabel.frame = CGRect(x: padding, y: labelY + 24, width: contentView.width - 2 * padding, height: 18)
    }


    override func prepareForReuse() {
        super.prepareForReuse()
        isLiked = false
        postID = nil
        likesCountLabel.text = nil
    }
}
