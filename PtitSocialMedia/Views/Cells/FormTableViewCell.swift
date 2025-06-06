//
//  FormTableViewCell.swift
//  PtitSocialMedia
//
//  Created by An Nguyen on 17/04/2025.
//

import UIKit

protocol FormTableViewCellDelete: AnyObject {
//    func formTableViewCell(_ cell: FormTableViewCell, didUpdatedField value: String?)
    func formTableViewCell(_ cell: FormTableViewCell, didUpdatedField updatedModel: EditProfileFormModel)
}

class FormTableViewCell: UITableViewCell {
    static let identifier = "FormTableViewCell"
    
    public weak var delegate: FormTableViewCellDelete?
    
    private let formLabel: UILabel = {
       let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let field: UITextField = {
        let field = UITextField()
        field.returnKeyType = .done
        return field
    }()

    //Hàm khởi tạo cell. Thêm label và textfield vào cell, gán delegate, và đăng ký lắng nghe sự kiện editingChanged.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.addSubview(formLabel)
        contentView.addSubview(field)
        field.delegate = self
        selectionStyle = .none
        
        field.addTarget(self, action: #selector(didChangeTextField), for: .editingChanged)

    }
    
    private var model: EditProfileFormModel?
    @objc private func didChangeTextField(_ textField: UITextField) {
        model?.value = textField.text
        if let model = model {
            delegate?.formTableViewCell(self, didUpdatedField: model)
        }
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // truyền dữ liệu từ model vào cell
    public func configure(with model: EditProfileFormModel) {
        self.model = model
        formLabel.text = model.label
        field.placeholder = model.placeholder
        field.text = model.value
    }
    
    
    // Khi cell được tái sử dụng (reuse), sẽ xoá dữ liệu cũ
    override func prepareForReuse() {
        super.prepareForReuse()
        formLabel.text = nil  // avoid using pre val for the next one
        field.placeholder = nil
        field.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Assign Frames
        formLabel.frame = CGRect(x: 5,
                                 y: 0,
                                 width: contentView.width/3,
                                 height: contentView.height)
        field.frame = CGRect(x: formLabel.right + 5,
                             y: 0,
                             width: contentView.width - 10 - formLabel.width,
                             height: contentView.height)
    }
}

// Khi người dùng nhấn nút "Done" trên bàn phím: Gửi dữ liệu về delegate (controller)
extension FormTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //delegate?.formTableViewCell(self, didUpdatedField: textField.text)
        model?.value = textField.text
        guard let model = model else {
            return true
        }
        delegate?.formTableViewCell(self, didUpdatedField: model)

        textField.resignFirstResponder()
        return true
    }
}
