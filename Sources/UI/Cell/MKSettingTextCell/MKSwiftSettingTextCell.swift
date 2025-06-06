//
//  MKSwiftSettingTextCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/29.
//

import UIKit
import SnapKit

// MARK: - Cell Model
class MKSwiftSettingTextCellModel {
    var contentColor: UIColor = .white
    
    // Left label and icon
    var leftIcon: UIImage?
    var leftMsgTextFont: UIFont = .systemFont(ofSize: 15)
    var leftMsgTextColor: UIColor = Color.defaultText
    var leftMsg: String = ""
}

// MARK: - Cell Implementation
class MKSwiftSettingTextCell: MKSwiftBaseCell {
    
    // MARK: - UI Components
    private var leftIcon: UIImageView?
    private var leftMsgLabel: UILabel!
    private var rightIcon: UIImageView!
    
    // MARK: - Properties
    var dataModel: MKSwiftSettingTextCellModel? {
        didSet {
            updateUI()
        }
    }
    
    private let offset_X: CGFloat = 15
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Class Methods
    class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftSettingTextCell {
        let identifier = "MKSwiftSettingTextCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftSettingTextCell
        if cell == nil {
            cell = MKSwiftSettingTextCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.backgroundColor = .white
        
        leftMsgLabel = UILabel()
        leftMsgLabel.textColor = Color.defaultText
        leftMsgLabel.textAlignment = .left
        leftMsgLabel.font = .systemFont(ofSize: 15)
        leftMsgLabel.numberOfLines = 0
        contentView.addSubview(leftMsgLabel)
        
        rightIcon = UIImageView()
        rightIcon.image = loadIcon(podLibName: "MKBaseSwiftModule", bundleClassName: "MKSwiftSettingTextCell", imageName: "mk_swift_goNextButton.png")
        contentView.addSubview(rightIcon)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let leftIcon = leftIcon {
            leftIcon.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(offset_X)
                make.width.equalTo(leftIcon.image!.size.width)
                make.centerY.equalTo(leftMsgLabel.snp.centerY)
                make.height.equalTo(leftIcon.image!.size.height)
            }
        }
        
        leftMsgLabel.snp.remakeConstraints { make in
            if let leftIcon = leftIcon {
                make.left.equalTo(leftIcon.snp.right).offset(3)
            } else {
                make.left.equalToSuperview().offset(offset_X)
            }
            make.right.equalTo(rightIcon.snp.left).offset(-5)
            make.centerY.equalToSuperview()
            make.height.equalTo(leftMsgLabel.font.lineHeight)
        }
        
        rightIcon.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(14)
        }
    }
    
    // MARK: - Update UI
    private func updateUI() {
        guard let dataModel = dataModel else { return }
        
        contentView.backgroundColor = dataModel.contentColor
        leftMsgLabel.text = dataModel.leftMsg
        leftMsgLabel.textColor = dataModel.leftMsgTextColor
        leftMsgLabel.font = dataModel.leftMsgTextFont
        
        // Handle left icon
        leftIcon?.removeFromSuperview()
        leftIcon = nil
        
        if let icon = dataModel.leftIcon {
            leftIcon = UIImageView(image: icon)
            contentView.addSubview(leftIcon!)
        }
        
        setNeedsLayout()
    }
}
