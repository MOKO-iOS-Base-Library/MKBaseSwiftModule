//
//  MKSettingTextCell.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/3/29.
//

import UIKit

class MKSettingTextCellModel {
    var contentColor: UIColor = .white
    
    //左侧label和icon配置
    var leftIcon: UIImage?
    var leftMsg: String = ""
    var leftMsgTextFont: UIFont = MKFont(withSize: 15)
    var leftMsgTextColor: UIColor = defaultTextColor
}

class MKSettingTextCell: MKBaseCell {
    var dataModel: MKSettingTextCellModel? {
        get {
            return privateDataModel
        }
        set {
            privateDataModel = nil
            privateDataModel = newValue
            
            guard privateDataModel != nil else {
                return
            }
            updateDataModel()
        }
    }

    static func initCell(tableView: UITableView) -> MKSettingTextCell {
        let reuseIdentifier = "MKSettingTextCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? MKSettingTextCell {
            return cell
        } else {
            return MKSettingTextCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(rightIcon)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - super method
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if dataModel?.leftIcon != nil && leftIcon.superview != nil {
            leftIcon.snp.remakeConstraints { make in
                make.left.equalTo(15)
                make.width.equalTo(dataModel!.leftIcon!.size.width)
                make.centerY.equalTo(msgLabel.snp.centerY)
                make.height.equalTo(dataModel!.leftIcon!.size.height)
            }
        }
        
        msgLabel.snp.remakeConstraints { make in
            if dataModel?.leftIcon != nil {
                make.left.equalTo(leftIcon.snp.right).offset(3)
            }else {
                make.left.equalTo(15)
            }
            make.right.equalTo(rightIcon.snp.left).offset(-5)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(dataModel!.leftMsgTextFont.lineHeight)
        }
        
        rightIcon.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(8)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(14)
        }
    }
    
    //MARK: - private method
    private func updateDataModel() {
        contentView.backgroundColor = dataModel!.contentColor
        msgLabel.text = dataModel!.leftMsg
        msgLabel.textColor = dataModel!.leftMsgTextColor
        msgLabel.font = dataModel!.leftMsgTextFont
        
        if leftIcon.superview != nil {
            leftIcon.removeFromSuperview()
        }
        
        if dataModel?.leftIcon != nil {
            leftIcon.image = dataModel!.leftIcon
            
            contentView.addSubview(leftIcon)
        }
        
        setNeedsLayout()
    }
    
    private var privateDataModel: MKSettingTextCellModel?
    
    //MARK: - 懒加载
    private lazy var msgLabel: UILabel = {
        let label = normalTextLabel(text: "")
        label.numberOfLines = 0
        return label
    }()
    private lazy var leftIcon: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    private lazy var rightIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = LOADIMAGE("mk_goNextButton", "png")
        return imageView
    }()
}
