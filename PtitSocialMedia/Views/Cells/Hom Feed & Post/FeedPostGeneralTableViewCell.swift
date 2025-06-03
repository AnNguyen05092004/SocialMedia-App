//
//  FeedPostGeneralTableViewCell.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 14/04/2025.
//
//
// comment


import UIKit

class FeedPostGeneralTableViewCell: UITableViewCell {
    static let identifier = "FeedPostGeneralTableViewCell"

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds.insetBy(dx: 10, dy: 5)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }

    public func configure(with comment: PostComment) {
        label.text = "\(comment.username): \(comment.text)"
    }
}
