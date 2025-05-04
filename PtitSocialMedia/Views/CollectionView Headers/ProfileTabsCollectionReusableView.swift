//
//  ProfileTabsCollectionReusableView.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 19/04/2025.
//

import UIKit

protocol ProfileTabsCollectionReusableDelegate: AnyObject {
    func didTapGridButtonTab()
    func didTapTaggedButtonTab()
}

class ProfileTabsCollectionReusableView: UICollectionReusableView { //khác với UICollectionViewCell
    //dùng cho các phần bổ sung như header/footer.
    static let identifier = "ProfileTabsCollectionReusableView"
    
    public weak var delegate: ProfileTabsCollectionReusableDelegate?
        
    private let gridButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.tintColor = .systemBlue
        button.setBackgroundImage(UIImage(systemName: "square.grid.2x2"), for: .normal)
        return button
    }()
    
    private let taggedButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.tintColor = .lightGray
        button.setBackgroundImage(UIImage(systemName: "tag"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(gridButton)
        addSubview(taggedButton)
        
        gridButton.addTarget(self, action: #selector(didTapGridButton), for: .touchUpInside)
        taggedButton.addTarget(self, action: #selector(didTapTaggedButton), for: .touchUpInside)
    }
    
    @objc private func didTapGridButton() {
        gridButton.tintColor = .systemBlue
        taggedButton.tintColor = .systemGray
        delegate?.didTapGridButtonTab()
    }
    @objc private func didTapTaggedButton() {
        gridButton.tintColor = .systemGray
        taggedButton.tintColor = .systemBlue
        delegate?.didTapTaggedButtonTab()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = height - 16
        let gridButtonX = ((width/2) - size)/2
        gridButton.frame = CGRect(x: gridButtonX,
                                  y: 8,
                                  width: size,
                                  height: size)
        taggedButton.frame = CGRect(x: gridButtonX + width/2,
                                    y: 8,
                                    width: size,
                                    height: size)
    }
}
