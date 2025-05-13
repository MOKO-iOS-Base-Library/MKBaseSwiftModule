//
//  MKFilterNormalTextFieldCell.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/4/11.
//

import UIKit

class MKFilterNormalTextFieldCellModel {
    var index: Int = 0
    var contentColor: UIColor = .white
    
    var msg: String = ""
    
    var value: String = ""
    var placeholder: String = ""
    var textFieldType: MKTextFieldType = .normal
    //textField的最大输入长度,对于textFieldType == mk_uuidMode无效
    var maxLength: UInt = 0
}

protocol MKFilterNormalTextFieldCellDelegate: AnyObject {
    
    /// 输入框的值发生改变
    /// - Parameters:
    ///   - index: 当前cell所在的row
    ///   - text: 当前textField内容
    func mk_filterNormalTextFieldCellValueChanged(index: Int, text: String)
}

class MKFilterNormalTextFieldCell: MKBaseCell {
    var delegate: MKFilterNormalTextFieldCellDelegate?
    var dataModel: MKFilterNormalTextFieldCellModel? {
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
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    static func initCell(tableView: UITableView) -> MKFilterNormalTextFieldCell {
        let reuseIdentifier = "MKFilterNormalTextFieldCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? MKFilterNormalTextFieldCell {
            return cell
        } else {
            return MKFilterNormalTextFieldCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(textField)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(needHiddenKeyboard),
                                               name: NSNotification.Name(rawValue: "MKTextFieldNeedHiddenKeyboard"),
                                               object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - super method
    override func layoutSubviews() {
        super.layoutSubviews()
        
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(5)
            make.height.equalTo(MKFont(withSize: 15).lineHeight)
        }
        textField.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(msgLabel.snp.bottom).offset(5)
            make.height.equalTo(30)
        }
    }
    
    //MARK: - note
    @objc func needHiddenKeyboard() {
        textField.resignFirstResponder()
    }
    
    //MARK: - private method
    private func updateDataModel() {
        msgLabel.text = dataModel!.msg
        textField.text = dataModel!.value
        textField.placeholder = dataModel!.placeholder
        textField.maxLength = dataModel!.maxLength
        textField.textType = dataModel!.textFieldType
    }
    
    private var privateDataModel: MKFilterNormalTextFieldCellModel?
    
    //MARK: - 懒加
    private lazy var msgLabel: UILabel = {
        let label = normalTextLabel(text: "")
        return label
    }()
    private lazy var textField: MKTextField = {
        let textField = normalTextField(text: "", placeHolder: "", textType: .normal)
        textField.textChangedBlock = { [weak self] text in
            self?.delegate?.mk_filterNormalTextFieldCellValueChanged(index: self?.dataModel?.index ?? 0, text: text)
        }
        return textField
    }()
}
