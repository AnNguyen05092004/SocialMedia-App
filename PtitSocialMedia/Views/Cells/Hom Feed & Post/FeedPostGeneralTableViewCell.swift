//
//  FeedPostGeneralTableViewCell.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 14/04/2025.
//

import UIKit

// Comment
class FeedPostGeneralTableViewCell: UITableViewCell {

    static let identifier = "FeedPostGeneralTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemOrange
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure() {
        // configure the cell
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
