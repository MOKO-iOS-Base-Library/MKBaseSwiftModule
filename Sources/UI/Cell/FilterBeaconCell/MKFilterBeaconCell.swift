//
//  MKFilterBeaconCell.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/4/10.
//

import UIKit

class MKFilterBeaconCellModel {
    var index: Int = 0
    
    var msg: String = ""
    var minValue: String = ""
    var maxValue: String = ""
}

protocol MKFilterBeaconCellDelegate: AnyObject {
    
    /// 最小值发生改变
    /// - Parameters:
    ///   - index: 当前cell所在的index
    ///   - value: 当前的最小值
    func mk_filterBeaconCellMinValueChanged(index: Int, value: String)
    
    /// 最大值发生改变
    /// - Parameters:
    ///   - index: 当前cell所在的index
    ///   - value: 当前的最大值
    func mk_filterBeaconCellMaxValueChanged(index: Int, value: String)
}

class MKFilterBeaconCell: MKBaseCell {
    var delegate: MKFilterBeaconCellDelegate?
    var dataModel: MKFilterBeaconCellModel? {
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
    
    static func initCell(tableView: UITableView) -> MKFilterBeaconCell {
        let reuseIdentifier = "MKFilterBeaconCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? MKFilterBeaconCell {
            return cell
        } else {
            return MKFilterBeaconCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(minLabel)
        contentView.addSubview(minTextField)
        contentView.addSubview(centerLabel)
        contentView.addSubview(maxLabel)
        contentView.addSubview(maxTextField)
        
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
        minLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.width.equalTo(50)
            make.centerY.equalTo(minTextField.snp.centerY)
            make.height.equalTo(MKFont(withSize: 15).lineHeight)
        }
        minTextField.snp.remakeConstraints { make in
            make.left.equalTo(minLabel.snp.right).offset(5)
            make.width.equalTo(80)
            make.top.equalTo(msgLabel.snp.bottom).offset(5)
            make.height.equalTo(30)
        }
        centerLabel.snp.remakeConstraints { make in
            make.left.equalTo(minTextField.snp.right).offset(10)
            make.width.equalTo(30)
            make.centerY.equalTo(minTextField.snp.centerY)
            make.height.equalTo(MKFont(withSize: 15).lineHeight)
        }
        maxLabel.snp.remakeConstraints { make in
            make.left.equalTo(centerLabel.snp.right).offset(10)
            make.width.equalTo(50)
            make.centerY.equalTo(minTextField.snp.centerY)
            make.height.equalTo(MKFont(withSize: 15).lineHeight)
        }
        maxTextField.snp.remakeConstraints { make in
            make.left.equalTo(maxLabel.snp.right).offset(5)
            make.width.equalTo(80)
            make.centerY.equalTo(minTextField.snp.centerY)
            make.height.equalTo(30)
        }
    }
    
    //MARK: - note
    @objc func needHiddenKeyboard() {
        minTextField.resignFirstResponder()
        maxTextField.resignFirstResponder()
    }
    
    //MARK: - private method
    private func updateDataModel() {
        msgLabel.text = dataModel!.msg
        minTextField.text = dataModel!.minValue
        maxTextField.text = dataModel!.maxValue
    }
    
    private var privateDataModel: MKFilterBeaconCellModel?
    
    //MARK: - 懒加
    private lazy var msgLabel: UILabel = {
        let label = normalTextLabel(text: "")
        return label
    }()
    private lazy var minLabel: UILabel = {
        let label = normalTextLabel(text: "Min")
        return label
    }()
    private lazy var minTextField: MKTextField = {
        let textField = normalTextField(text: "", placeHolder: "0~65535", textType: .realNumberOnly)
        textField.maxLength = 5
        textField.textChangedBlock = { [weak self] text in
            self?.delegate?.mk_filterBeaconCellMinValueChanged(index: self?.dataModel?.index ?? 0, value: text)
        }
        return textField
    }()
    private lazy var centerLabel: UILabel = {
        let label = normalTextLabel(text: "~")
        return label
    }()
    private lazy var maxLabel: UILabel = {
        let label = normalTextLabel(text: "Max")
        return label
    }()
    private lazy var maxTextField: MKTextField = {
        let textField = normalTextField(text: "", placeHolder: "0~65535", textType: .realNumberOnly)
        textField.maxLength = 5
        textField.textChangedBlock = { [weak self] text in
            self?.delegate?.mk_filterBeaconCellMaxValueChanged(index: self?.dataModel?.index ?? 0, value: text)
        }
        return textField
    }()
}
