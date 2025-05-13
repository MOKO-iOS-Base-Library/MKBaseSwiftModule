//
//  MKTextPickListCell.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/4/9.
//

import UIKit

class MKTextPickListCellModel {
    var index: Int = 0
    var contentColor: UIColor = .white
    
    //左侧Message Label配置
    var msg: String = ""
    var msgColor: UIColor = RGB(0x353535)
    var msgFont: UIFont = MKFont(withSize: 15)
    
    //右侧按钮和数据源配置
    var buttonEnable: Bool = true
    var dataList: [String] = []
    var dataListIndex:Int = 0
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

protocol MKTextPickListCellDelegate: AnyObject {
    
    /// 右侧按钮点击之后出现的pickView，选中某行的回调事件
    /// - Parameters:
    ///   - index: 当前cell所在的index
    ///   - dataListIndex: 点击按钮选中的dataList里面的index
    func mk_textPickListCellSelected(index: Int, dataListIndex: Int)
}

class MKTextPickListCell: MKBaseCell {
    var delegate: MKTextPickListCellDelegate?
    var dataModel: MKTextPickListCellModel? {
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
    
    static func initCell(tableView: UITableView) -> MKTextPickListCell {
        let reuseIdentifier = "MKTextPickListCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? MKTextPickListCell {
            return cell
        } else {
            return MKTextPickListCell(style: .default, reuseIdentifier: reuseIdentifier)
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: "MKTextFieldNeedHiddenKeyboard"), object: nil)
        var row = 0
        for i in 0..<dataModel!.dataList.count {
            if selectedButton.titleLabel?.text == dataModel!.dataList[i] {
                row = i
                break
            }
        }
        let pickView = MKPickerView()
        pickView.showPickView(withDataList: dataModel!.dataList, selectedRow: row) { selectedRow in
            self.selectedButton.setTitle(self.dataModel!.dataList[selectedRow], for: .normal)
            self.delegate?.mk_textPickListCellSelected(index: self.dataModel!.index, dataListIndex: selectedRow)
        }
    }
    
    //MARK: - private method
    private func updateDataModel() {
        
        if dataModel!.dataListIndex >= dataModel!.dataList.count {
            return
        }
        
        contentView.backgroundColor = dataModel!.contentColor
        if noteLabel.superview != nil {
            noteLabel.removeFromSuperview()
        }
        msgLabel.text = dataModel!.msg
        msgLabel.font = dataModel!.msgFont
        msgLabel.textColor = dataModel!.msgColor
        
        selectedButton.isEnabled = dataModel!.buttonEnable
        selectedButton.setTitle(dataModel!.dataList[dataModel!.dataListIndex], for: .normal)
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
    
    private var privateDataModel: MKTextPickListCellModel?
    
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

extension MKTextPickListCell {
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
