//
//  MKNormalTextCell.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/4/9.
//

import UIKit

class MKNormalTextCellModel {
    var contentColor: UIColor = .white
    
    //左侧label和icon配置
    var leftIcon: UIImage?
    var leftMsg: String = ""
    var leftMsgTextFont: UIFont = MKFont(withSize: 15)
    var leftMsgTextColor: UIColor = defaultTextColor
    
    //右侧label配置
    var rightMsg: String = ""
    var rightMsgTextFont: UIFont = MKFont(withSize: 13)
    var rightMsgTextColor: UIColor = RGB(0x808080)
    //是否显示右侧的箭头
    var showRightIcon: Bool = true
    
    //底部Note标签配置
    var noteMsg: String = ""
    var noteMsgColor: UIColor = RGB(0x353535)
    var noteMsgFont: UIFont = MKFont(withSize: 12)
    
    func cellHeight() -> CGFloat {
        var maxMsgWidth = screenWidth / 2 - 15 - 3
        if leftIcon != nil  {
            maxMsgWidth = maxMsgWidth - leftIcon!.size.width - 3
        }
        let msgSize = stringSize(string: leftMsg, font: leftMsgTextFont, maxSize: CGSize(width: maxMsgWidth, height: CGFloat.greatestFiniteMagnitude))
                
        if !ValidStr(noteMsg) {
            //底部没有note内容
            return max(msgSize.height + 2 * 15, 50)
        }
        //底部存在note
        let noteSize = stringSize(string: noteMsg, font: noteMsgFont, maxSize: CGSize(width: screenWidth - 2 * 15, height: CGFloat.greatestFiniteMagnitude))
        return (max(msgSize.height + 2 * 15, 50) + noteSize.height + 10)
    }
}

class MKNormalTextCell: MKBaseCell {
    var dataModel: MKNormalTextCellModel? {
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
    
    static func initCell(tableView: UITableView) -> MKNormalTextCell {
        let reuseIdentifier = "MKNormalTextCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? MKNormalTextCell {
            return cell
        } else {
            return MKNormalTextCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(leftMsgLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Super method
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let hasNote = (noteLabel.superview != nil)
        
        let hasLeftIcon = (leftIcon.superview != nil)
        
        if hasLeftIcon {
            leftIcon.snp.remakeConstraints { make in
                make.left.equalTo(15)
                make.width.equalTo((privateDataModel?.leftIcon?.size.width)!)
                if hasNote {
                    make.top.equalTo(15)
                }else {
                    make.centerY.equalTo(contentView.snp.centerY)
                }
                make.height.equalTo((privateDataModel?.leftIcon?.size.height)!)
            }
        }
        
        leftMsgLabel.snp.remakeConstraints { make in
            if hasLeftIcon {
                make.left.equalTo(leftIcon.snp.right).offset(3)
            }else {
                make.left.equalTo(15)
            }
            make.right.equalTo(contentView.snp.centerX).offset(-3)
            if hasNote {
                make.top.equalTo(15)
            }else {
                make.centerY.equalTo(contentView.snp.centerY)
            }
            make.height.equalTo(msgSize().height)
        }
        let showRightIcon = (rightIcon.superview != nil)
        if showRightIcon {
            rightIcon.snp.remakeConstraints { make in
                make.right.equalTo(-15)
                make.width.equalTo(8)
                make.centerY.equalTo(contentView.snp.centerY)
                make.height.equalTo(14)
            }
        }
        let hasRightMsg = (rightMsgLabel.superview != nil)
        if hasRightMsg {
            rightMsgLabel.snp.remakeConstraints { make in
                make.left.equalTo(contentView.snp.centerX).offset(2)
                if showRightIcon {
                    make.right.equalTo(rightIcon.snp.left).offset(-2)
                }else {
                    make.right.equalTo(-15)
                }
                make.centerY.equalTo(leftMsgLabel.snp.centerY)
                make.height.equalTo(privateDataModel!.rightMsgTextFont.lineHeight)
            }
        }
        if noteLabel.superview != nil {
            noteLabel.snp.remakeConstraints { make in
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.bottom.equalTo(-15)
                make.height.equalTo(noteSize().height)
            }
        }
    }
    
    //MARK: - Private method
    private func updateDataModel() {
        contentView.backgroundColor = dataModel!.contentColor
        
        if leftIcon.superview != nil {
            leftIcon.removeFromSuperview()
        }
        if rightIcon.superview != nil {
            rightIcon.removeFromSuperview()
        }
        if rightMsgLabel.superview != nil {
            rightMsgLabel.removeFromSuperview()
        }
        if noteLabel.superview != nil {
            noteLabel.removeFromSuperview()
        }
        
        if dataModel!.leftIcon != nil {
            contentView.addSubview(leftIcon)
            leftIcon.image = dataModel!.leftIcon
        }
        
        leftMsgLabel.text = dataModel!.leftMsg
        leftMsgLabel.textColor = dataModel!.leftMsgTextColor
        leftMsgLabel.font = dataModel!.leftMsgTextFont
        
        if dataModel!.showRightIcon {
            contentView.addSubview(rightIcon)
        }
        
        if ValidStr(dataModel!.rightMsg) {
            contentView.addSubview(rightMsgLabel)
            rightMsgLabel.text = dataModel!.rightMsg
            rightMsgLabel.textColor = dataModel!.rightMsgTextColor
            rightMsgLabel.font = dataModel!.rightMsgTextFont
        }
        
        if ValidStr(dataModel!.noteMsg) {
            contentView.addSubview(noteLabel)
            noteLabel.text = dataModel!.noteMsg
            noteLabel.textColor = dataModel!.noteMsgColor
            noteLabel.font = dataModel!.noteMsgFont
        }
        
        setNeedsLayout()
    }
    
    private var privateDataModel: MKNormalTextCellModel?
    
    //MARK: - 懒加载
    private lazy var leftMsgLabel: UILabel = {
        let label = normalTextLabel(text: "")
        label.numberOfLines = 0
        return label
    }()
    private lazy var leftIcon: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    private lazy var rightMsgLabel: UILabel = {
        let label = UILabel()
        label.textColor = RGB(0x808080)
        label.textAlignment = .right
        label.font = MKFont(withSize: 13)
        return label
    }()
    private lazy var rightIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = LOADIMAGE("mk_goNextButton", "png")
        return imageView
    }()
    private lazy var noteLabel: UILabel = {
        let label = normalTextLabel(text: "")
        label.font = MKFont(withSize: 12)
        label.numberOfLines = 0
        return label
    }()
}

extension MKNormalTextCell {
    private func msgSize() -> CGSize{
        if !ValidStr(self.dataModel?.leftMsg) {
            return CGSize(width: 0, height: 0)
        }
        var maxMsgWidth = contentView.frame.size.width / 2 - 15 - 3
        if leftIcon.superview != nil {
            maxMsgWidth = maxMsgWidth - privateDataModel!.leftIcon!.size.width - 3;
        }
        let msgSize = stringSize(string: self.dataModel!.leftMsg, font: self.dataModel!.leftMsgTextFont, maxSize: CGSize(width: maxMsgWidth, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: maxMsgWidth, height: msgSize.height)
    }
    private func noteSize() -> CGSize{
        if !ValidStr(self.dataModel?.noteMsg) {
            return CGSize(width: 0, height: 0)
        }
        let width = contentView.frame.size.width - 30
        let noteSize = stringSize(string: self.dataModel!.noteMsg, font: self.dataModel!.noteMsgFont, maxSize: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: width, height: noteSize.height)
    }
}
