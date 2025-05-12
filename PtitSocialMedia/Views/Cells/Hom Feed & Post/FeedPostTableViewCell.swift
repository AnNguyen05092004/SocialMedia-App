////
////  FeedPostTableViewCell.swift
////  PtitSocialMedia
////
////  Created by An Nguyen on 14/04/2025.
////
//
//import UIKit
//import SDWebImage
//import AVFoundation
//// cell for primary post content
//class FeedPostTableViewCell: UITableViewCell {
//    
//    static let identifier = "FeedPostTableViewCell"
//    
//    private let postImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.backgroundColor = nil
//        imageView.clipsToBounds = true
//        return imageView
//    }()
//    
//    private var player: AVPlayer?
//    private var playerLayer = AVPlayerLayer()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        contentView.layer.addSublayer(playerLayer) //add layer first
//        contentView.addSubview(postImageView)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    public func configure(with post: UserPost) {
//        // configure the cell
//        postImageView.image = UIImage(named: "test")
//        
//        return
//        
////        switch post.postType {
////            case.photo:
////                postImageView.sd_setImage(with: post.postURL, completed: nil)
////            case.video:
////                player = AVPlayer(url: post.postURL)
////                playerLayer.player = player
////                playerLayer.player?.volume = 0
////                playerLayer.player?.play()
////        }
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        playerLayer.frame = contentView.bounds
//        postImageView.frame = contentView.bounds
//        
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        postImageView.image = nil
//    }
//}


import UIKit
import SDWebImage
import AVFoundation

class FeedPostTableViewCell: UITableViewCell {
    
    static let identifier = "FeedPostTableViewCell"
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .secondarySystemBackground
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    
    private var player: AVPlayer?
    private var playerLayer = AVPlayerLayer()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(postImageView)
        contentView.layer.addSublayer(playerLayer) // video layer dưới ảnh
        contentView.addSubview(captionLabel)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    public func configure(with post: UserPost) {
//        // Reset state trước
//        postImageView.isHidden = true
//        playerLayer.isHidden = true
//        player?.pause()
//        player = nil
//        playerLayer.player = nil
//
//        switch post.postType {
//        case .photo:
//            postImageView.isHidden = false
//            postImageView.sd_setImage(with: post.postURL, placeholderImage: UIImage(systemName: "photo"), options: [.continueInBackground], completed: nil)
//
//        case .video:
//            player = AVPlayer(url: post.postURL)
//            playerLayer.player = player
//            playerLayer.isHidden = false
//            player?.volume = 0
//            player?.play()
//        }
//    }
    public func configure(with post: UserPost) {
        postImageView.isHidden = true
        playerLayer.isHidden = true
        player?.pause()
        player = nil
        playerLayer.player = nil
        
        captionLabel.text = post.caption // Gán caption vào label
        
        switch post.postType {
        case .photo:
            postImageView.isHidden = false
            postImageView.sd_setImage(with: post.postURL, placeholderImage: UIImage(systemName: "photo"), options: [.continueInBackground], completed: nil)
            
        case .video:
            player = AVPlayer(url: post.postURL)
            playerLayer.player = player
            playerLayer.isHidden = false
            player?.volume = 0
            player?.play()
        }
    }

    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        postImageView.frame = contentView.bounds
//        playerLayer.frame = contentView.bounds
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        postImageView.image = nil
//        postImageView.isHidden = true
//        playerLayer.player = nil
//        playerLayer.isHidden = true
//    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageHeight = contentView.frame.width
        postImageView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: imageHeight)
        playerLayer.frame = postImageView.frame

        captionLabel.frame = CGRect(
            x: 10,
            y: imageHeight + 8,
            width: contentView.frame.width - 20,
            height: captionLabel.sizeThatFits(CGSize(width: contentView.frame.width - 20, height: .greatestFiniteMagnitude)).height
        )
    }

}
