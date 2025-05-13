//
//  MKTextFieldCell.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/3/27.
//

import UIKit

import SnapKit

enum MKTextFieldCellType {
    case normal         //圆角带边框
    case topLine        //顶部类似于阴影的输入框
}

class MKTextFieldCellModel {
    var index: Int = 0
    var contentColor: UIColor = .white
    
    //左侧Message Label配置
    var msg: String = ""
    var msgColor: UIColor = RGB(0x353535)
    var msgFont: UIFont = MKFont(withSize: 15)
    
    //右侧单位label配置
    var unit: String = ""
    var unitColor: UIColor = RGB(0x353535)
    var unitFont: UIFont = MKFont(withSize: 13)
    
    //textField配置
    //能否交互，默认为true可以交互
    var enable: Bool = true
    var cellType: MKTextFieldCellType = .normal
    //当前输入框的值
    var text: String = ""
    var placeholder: String = ""
    var textAlignment: NSTextAlignment = .left
    var textColor: UIColor = RGB(0x353535)
    var font: UIFont = MKFont(withSize: 15)
    var textFieldType: MKTextFieldType = .normal
    //输入框最大输入长度，对于textFieldType = .uuidMode无效
    var maxLength: UInt = 0
    //输入框边框颜色，cellType = .topLine时无效
    var borderColor: UIColor = lineColor
    
    //底部Note标签配置
    var noteMsg: String = ""
    var noteMsgColor: UIColor = RGB(0x353535)
    var noteMsgFont: UIFont = MKFont(withSize: 12)
    
    func cellHeight() -> CGFloat {
        let msgWidth = (screenWidth - 3 * 15) / 2
        let msgSize = stringSize(string: msg, font: msgFont, maxSize: CGSize(width: msgWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let withoutNoteHeight = max(msgSize.height + 2 * 15, 50)
        
        if !ValidStr(noteMsg) {
            //底部没有note内容
            return withoutNoteHeight
        }
        
        let noteSize = stringSize(string: noteMsg, font: noteMsgFont, maxSize: CGSize(width: screenWidth - 2 * 15, height: CGFloat.greatestFiniteMagnitude))
        return withoutNoteHeight + noteSize.height + 10
    }
}

protocol MKTextFieldCellDelegate: AnyObject {
    
    /// textField内容发送改变时的回调事件
    /// - Parameters:
    ///   - index: 当前cell所在的index
    ///   - textValue: 当前textField的值
    func mk_textFieldCellValueChanged(index: Int, textValue:String)
}

class MKTextFieldCell: MKBaseCell {
    var delegate: MKTextFieldCellDelegate?
    var dataModel: MKTextFieldCellModel? {
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
    
    private var textField: MKTextField?
    private var textBorderView: UIView?
    private var privateDataModel: MKTextFieldCellModel?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    static func initCell(tableView: UITableView) -> MKTextFieldCell {
        let reuseIdentifier = "MKTextFieldCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? MKTextFieldCell {
            return cell
        } else {
            return MKTextFieldCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(unitLabel)
        contentView.addSubview(noteLabel)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(needHiddenKeyboard),
                                               name: NSNotification.Name(rawValue: "MKTextFieldNeedHiddenKeyboard"),
                                               object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let hasNote = ValidStr(privateDataModel!.noteMsg)
        let msgSize = msgSize()
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.width.equalTo(msgSize.width)
            if hasNote {
                //底部有note标签
                make.top.equalTo(15)
            }else {
                //底部没有note标签，上下居中
                make.centerY.equalTo(contentView.snp.centerY)
            }
            make.height.equalTo(msgSize.height)
        }
        if textField != nil && textField?.superview != nil {
            textField?.snp.remakeConstraints({ make in
                make.left.equalTo(5)
                make.right.equalTo(-5)
                make.top.equalTo(2)
                make.bottom.equalTo(0)
            })
        }
        unitLabel.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(70)
            make.centerY.equalTo(msgLabel.snp.centerY)
            make.height.equalTo(contentView.snp.height)
        }
        let noteSize = noteSize()
        noteLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-15)
            make.height.equalTo(noteSize.height)
        }
        if textBorderView?.superview != nil {
            textBorderView?.snp.remakeConstraints { make in
                make.left.equalTo(msgLabel.snp.right).offset(15)
                if ValidStr(dataModel?.unit) {
                    make.right.equalTo(unitLabel.snp.left).offset(-5)
                }else {
                    make.right.equalTo(-15)
                }
                make.centerY.equalTo(msgLabel.snp.centerY)
                make.height.equalTo(35)
            }
        }
    }
    
    private func updateDataModel() {
        contentView.backgroundColor = privateDataModel!.contentColor
        unitLabel.text = privateDataModel!.unit
        unitLabel.font = privateDataModel!.unitFont
        unitLabel.textColor = privateDataModel!.unitColor
        unitLabel.isHidden = !ValidStr(privateDataModel!.unit)
        
        msgLabel.text = privateDataModel!.msg
        msgLabel.font = privateDataModel!.font
        msgLabel.textColor = privateDataModel!.msgColor
        
        noteLabel.text = privateDataModel!.noteMsg
        noteLabel.font = privateDataModel!.noteMsgFont
        noteLabel.textColor = privateDataModel!.noteMsgColor
        
        if textField != nil && textField?.superview != nil {
            textField?.resignFirstResponder()
            textField = nil
        }
        
        if textBorderView?.superview != nil {
            textBorderView?.removeFromSuperview()
            textBorderView = nil
        }
        
        textField = MKTextField(textType: privateDataModel!.textFieldType)
        textField?.placeholder = privateDataModel!.placeholder
        textField?.text = privateDataModel!.text
        textField?.maxLength = privateDataModel!.maxLength
        textField?.textAlignment = privateDataModel!.textAlignment
        textField?.font = privateDataModel!.font
        textField?.textColor = privateDataModel!.textColor
        textField?.textChangedBlock = { [weak self] text in
            self?.delegate?.mk_textFieldCellValueChanged(index: self?.privateDataModel?.index ?? 0, textValue: text)
        }
        textField?.isEnabled = privateDataModel!.enable
        
        textBorderView = UIView()
        textBorderView!.backgroundColor = .white
        textBorderView!.layer.masksToBounds = true
        textBorderView!.layer.borderWidth = CUTTING_LINE_HEIGHT
        textBorderView!.layer.borderColor = privateDataModel!.borderColor.cgColor
        
        if privateDataModel!.cellType == .normal {
            textBorderView!.layer.cornerRadius = 6
        }else {
            let topLine = UIView()
            topLine.backgroundColor = lineColor
            textBorderView!.addSubview(topLine)
            topLine.snp.remakeConstraints { make in
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.top.equalTo(0)
                make.height.equalTo(2)
            }
        }
        
        contentView.addSubview(textBorderView!)
        textBorderView!.addSubview(textField!)
        setNeedsLayout()
    }
    
    //MARK: - note
    @objc func needHiddenKeyboard() {
        textField?.resignFirstResponder()
    }
    
    //MARK: - 懒加载
    private lazy var msgLabel: UILabel = {
        let label = normalTextLabel(text: "")
        label.numberOfLines = 0
        return label
    }()
    private lazy var unitLabel: UILabel = {
        let label = normalTextLabel(text: "")
        label.font = MKFont(withSize: 13)
        return label
    }()
    private lazy var noteLabel: UILabel = {
        let label = normalTextLabel(text: "")
        label.font = MKFont(withSize: 12)
        label.numberOfLines = 0
        return label
    }()
}

extension MKTextFieldCell {
    private func msgSize() -> CGSize{
        if !ValidStr(self.dataModel?.msg) {
            return CGSize(width: 0, height: 0)
        }
        let maxMsgWidth = (contentView.frame.size.width - 3 * 15) / 2
        let msgSize = stringSize(string: self.dataModel!.msg, font: self.dataModel!.font, maxSize: CGSize(width: maxMsgWidth, height: CGFloat.greatestFiniteMagnitude))
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
