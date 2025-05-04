//
//  PhotoCollectionViewCell.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 19/04/2025.
//

import UIKit
import SDWebImage

class PhotoCollectionViewCell: UICollectionViewCell { //
    static let identifier = "PhotoCollectionViewCell"
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photoImageView.frame = contentView.bounds //bằng đúng kích thước của contentView (toàn bộ cell).
        
    }
    
    override func prepareForReuse() { // Được gọi khi cell được tái sử dụng.
        super.prepareForReuse()
        photoImageView.image = nil
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(photoImageView)
        contentView.clipsToBounds = true
        accessibilityLabel = "User post image" // Voice over hỗ trợ người bị khiếm thính
        accessibilityHint = " Double-tap to open post"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with model: UserPost) {
        let url = model.thumbnailImage
        photoImageView.sd_setImage(with: url, completed: nil) //SDWebImage Dùng để tải ảnh từ URL và hiển thị vào photoImageView
    }
    
    public func configure(debug imageName: String) {
        photoImageView.image = UIImage(named: imageName)
    }
}
