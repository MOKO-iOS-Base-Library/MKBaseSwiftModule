//
//  MKTextButtonCell.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/4/10.
//

import UIKit

class MKTextButtonCellModel {
    var index: Int = 0
    var contentColor: UIColor = .white
    
    //左侧Message Label配置
    var msg: String = ""
    var msgColor: UIColor = RGB(0x353535)
    var msgFont: UIFont = MKFont(withSize: 15)
    
    //右侧按钮和数据源配置
    var buttonEnable: Bool = true
    var buttonTitle:String = ""
    var buttonBackColor: UIColor = navbarColor
    var buttonTitleColor: UIColor = .white
    var buttonLabelFont: UIFont = MKFont(withSize: 15)
    
    //底部Note标签配置
    var noteMsg: String = ""
    var noteMsgColor: UIColor = RGB(0x353535)
    var noteMsgFont: UIFont = MKFont(withSize: 12)
    
    func cellHeight() -> CGFloat {
        let msgWidth = screenWidth - 3 * 15 - 130
        let msgSize = stringSize(string: msg, font: msgFont, maxSize: CGSize(width: msgWidth, height: CGFloat.greatestFiniteMagnitude))
        
        if !ValidStr(noteMsg) {
            //底部没有note内容
            return max(msgSize.height + 2 * 15, 50)
        }
        //底部存在note
        let noteSize = stringSize(string: noteMsg, font: noteMsgFont, maxSize: CGSize(width: screenWidth - 2 * 15, height: CGFloat.greatestFiniteMagnitude))
        return (max(msgSize.height + 2 * 15, 50) + noteSize.height + 10)
    }
}

protocol MKTextButtonCellDelegate: AnyObject {
    
    /// 右侧按钮点击事件
    /// - Parameters:
    ///   - index: 当前cell所在的index
    func mk_textButtonCellButtonPressed(index: Int)
}

class MKTextButtonCell: MKBaseCell {
    var delegate: MKTextButtonCellDelegate?
    var dataModel: MKTextButtonCellModel? {
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
    
    static func initCell(tableView: UITableView) -> MKTextButtonCell {
        let reuseIdentifier = "MKTextButtonCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? MKTextButtonCell {
            return cell
        } else {
            return MKTextButtonCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(selectedButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - super method
    override func layoutSubviews() {
        super.layoutSubviews()
        let hasNote = (noteLabel.superview != nil)
        let msgSize = msgSize()
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.width.equalTo(msgSize.width)
            if hasNote {
                make.top.equalTo(15)
            }else {
                make.centerY.equalTo(contentView.snp.centerY)
            }
            make.height.equalTo(msgSize.height)
        }
        selectedButton.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(130)
            make.centerY.equalTo(msgLabel.snp.centerY)
            make.height.equalTo(30)
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
    
    //MARK: - event method
    @objc func selectedButtonPressed() {
        self.delegate?.mk_textButtonCellButtonPressed(index: dataModel!.index)
    }
    
    //MARK: - private method
    private func updateDataModel() {
        
        contentView.backgroundColor = dataModel!.contentColor
        if noteLabel.superview != nil {
            noteLabel.removeFromSuperview()
        }
        msgLabel.text = dataModel!.msg
        msgLabel.font = dataModel!.msgFont
        msgLabel.textColor = dataModel!.msgColor
        
        selectedButton.isEnabled = dataModel!.buttonEnable
        selectedButton.setTitle(dataModel!.buttonTitle, for: .normal)
        selectedButton.titleLabel?.font = dataModel!.buttonLabelFont
        selectedButton.backgroundColor = dataModel!.buttonBackColor
        selectedButton.setTitleColor(dataModel!.buttonTitleColor, for: .normal)
        
        if ValidStr(dataModel!.noteMsg) {
            contentView.addSubview(noteLabel)
            noteLabel.text = dataModel!.noteMsg
            noteLabel.textColor = dataModel!.noteMsgColor
            noteLabel.font = dataModel!.noteMsgFont
        }
        
        setNeedsLayout()
    }
    
    private var privateDataModel: MKTextButtonCellModel?
    
    //MARK: - 懒加载
    private lazy var msgLabel: UILabel = {
        let label = normalTextLabel(text: "")
        label.numberOfLines = 0
        return label
    }()
    private lazy var selectedButton: UIButton = {
        let button = cornerRadiusButton(title: "", target: self, action: #selector(selectedButtonPressed))
        return button
    }()
    private lazy var noteLabel: UILabel = {
        let label = normalTextLabel(text: "")
        label.font = MKFont(withSize: 12)
        label.numberOfLines = 0
        return label
    }()
}

extension MKTextButtonCell {
    private func msgSize() -> CGSize{
        if !ValidStr(self.dataModel?.msg) {
            return CGSize(width: 0, height: 0)
        }
        let maxMsgWidth = (contentView.frame.size.width - 3 * 15 - 130)
        let msgSize = stringSize(string: self.dataModel!.msg, font: self.dataModel!.msgFont, maxSize: CGSize(width: maxMsgWidth, height: CGFloat.greatestFiniteMagnitude))
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
