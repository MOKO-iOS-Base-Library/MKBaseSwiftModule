//
//  MKFilterByRawDataCell.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/4/10.
//

import UIKit

class MKFilterByRawDataCellModel {
    var index: Int = 0
    var contentColor: UIColor = .white
    
    var msg: String = ""
    //当前过滤的数据类型，参考国际蓝牙组织对不同蓝牙数据类型的定义，1Byte
    var dataType: String = ""
    //开始过滤的Byte索引
    var minIndex: String = ""
    //截止过滤的Byte索引
    var maxIndex: String = ""
    //当前过滤的内容
    var rawData: String = ""
    
    //当前过滤内容(rawData是字符，长度乘以2就是当前输入的字节数)最大字节长度,默认29个字节长度
    var rawDataMaxBytes: Int = 29
    var dataTypePlaceHolder: String = ""
    var minTextFieldPlaceHolder: String = ""
    var maxTextFieldPlaceHolder: String = ""
    var rawTextFieldPlaceHolder: String = ""
    
    //校验当前的参数是否符合业务需求
    func validParamsSuccess() -> Bool {
        if !ValidStr(dataType) || dataType.count != 2 || !regularExpressions(string: dataType, regex: isHexadecimal) {
            return false
        }
        if !ValidStr(minIndex) && !ValidStr(maxIndex) {
            return validRawDatas()
        }
        if !ValidStr(minIndex) || minIndex.count > 2 || !regularExpressions(string: minIndex, regex: isRealNumbers) || Int(minIndex)! < 0 || Int(minIndex)! > rawDataMaxBytes {
            return false
        }
        if Int(minIndex)! == 0 {
            //可以不填写maxIndex或者maxIndex只能写0
            if (!ValidStr(maxIndex) || Int(maxIndex)! == 0) && validRawDatas() {
                return true
            }
            return false
        }
        if !ValidStr(maxIndex) || maxIndex.count > 2 || !regularExpressions(string: maxIndex, regex: isRealNumbers) || Int(maxIndex)! < 0 || Int(maxIndex)! > rawDataMaxBytes {
            return false
        }
        if Int(maxIndex)! < Int(minIndex)! {
            return false
        }
        if !ValidStr(rawData) || rawData.count > (rawDataMaxBytes * 2) || !regularExpressions(string: rawData, regex: isHexadecimal) {
            return false
        }
        let total = (Int(maxIndex)! - Int(minIndex)! + 1) * 2
        if rawData.count != total {
            return false
        }
        return true
    }
    
    private func validRawDatas() -> Bool {
        if !ValidStr(rawData) || rawData.count > (rawDataMaxBytes * 2) || !regularExpressions(string: rawData, regex: isHexadecimal) {
            return false
        }
        if (rawData.count % 2 != 0) {
            return false
        }
        return true
    }
}

enum mk_filterByRawDataTextType {
    case dataType         //过滤类型输入框内容发生改变
    case minIndex        //开始过滤的Byte索引输入框发生改变
    case maxIndex        //截止过滤的Byte索引输入框发生改变
    case rawData        //过滤内容输入框发生改变
}

protocol MKFilterByRawDataCellDelegate: AnyObject {
    
    /// 输入框内容发生改变
    /// - Parameters:
    ///   - index: 当前cell所在的row
    ///   - type: 哪个输入框发生改变了
    ///   - value: 当前textField内容
    func mk_rawFilterDataChanged(index: Int, type: mk_filterByRawDataTextType,value: String)
}

class MKFilterByRawDataCell: MKBaseCell {
    var delegate: MKFilterByRawDataCellDelegate?
    var dataModel: MKFilterByRawDataCellModel? {
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
    
    static func initCell(tableView: UITableView) -> MKFilterByRawDataCell {
        let reuseIdentifier = "MKFilterByRawDataCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? MKFilterByRawDataCell {
            return cell
        } else {
            return MKFilterByRawDataCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(typeTextField)
        contentView.addSubview(minTextField)
        contentView.addSubview(maxTextField)
        contentView.addSubview(characterLabel)
        contentView.addSubview(unitLabel)
        contentView.addSubview(rawDataField)
        
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
        typeTextField.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.width.equalTo(70)
            make.top.equalTo(msgLabel.snp.bottom).offset(5)
            make.height.equalTo(30)
        }
        minTextField.snp.remakeConstraints { make in
            make.left.equalTo(typeTextField.snp.right).offset(20)
            make.width.equalTo(40)
            make.centerY.equalTo(typeTextField.snp.centerY)
            make.height.equalTo(typeTextField.snp.height)
        }
        characterLabel.snp.remakeConstraints { make in
            make.left.equalTo(minTextField.snp.right).offset(5)
            make.width.equalTo(20)
            make.centerY.equalTo(typeTextField.snp.centerY)
            make.height.equalTo(typeTextField.snp.height)
        }
        maxTextField.snp.remakeConstraints { make in
            make.left.equalTo(characterLabel.snp.right).offset(5)
            make.width.equalTo(40)
            make.centerY.equalTo(typeTextField.snp.centerY)
            make.height.equalTo(typeTextField.snp.height)
        }
        unitLabel.snp.remakeConstraints { make in
            make.left.equalTo(maxTextField.snp.right).offset(3)
            make.width.equalTo(40)
            make.centerY.equalTo(typeTextField.snp.centerY)
            make.height.equalTo(typeTextField.snp.height)
        }
        rawDataField.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(typeTextField.snp.bottom).offset(15)
            make.bottom.equalTo(-5)
        }
    }
    
    //MARK: - note
    @objc func needHiddenKeyboard() {
        typeTextField.resignFirstResponder()
        minTextField.resignFirstResponder()
        maxTextField.resignFirstResponder()
        rawDataField.resignFirstResponder()
    }
    
    //MARK: - private method
    private func updateDataModel() {
        contentView.backgroundColor = dataModel!.contentColor
        msgLabel.text = dataModel!.msg
        
        typeTextField.text = SafeStr(dataModel!.dataType)
        typeTextField.placeholder = SafeStr(dataModel!.dataTypePlaceHolder)
        
        minTextField.text = SafeStr(dataModel!.minIndex)
        minTextField.placeholder = SafeStr(dataModel!.minTextFieldPlaceHolder)
        
        maxTextField.text = SafeStr(dataModel!.maxIndex)
        maxTextField.placeholder = SafeStr(dataModel!.maxTextFieldPlaceHolder)
        
        rawDataField.text = SafeStr(dataModel!.rawData)
        rawDataField.placeholder = SafeStr(dataModel!.rawTextFieldPlaceHolder)
        rawDataField.maxLength = UInt(dataModel!.rawDataMaxBytes * 2)
    }
    
    private var privateDataModel: MKFilterByRawDataCellModel?
    
    //MARK: - 懒加载
    private lazy var msgLabel: UILabel = {
        let label = normalTextLabel(text: "")
        return label
    }()
    private lazy var typeTextField: MKTextField = {
        let textField = normalTextField(text: "", placeHolder: "", textType: .hexCharOnly)
        textField.font = MKFont(withSize: 13)
        textField.maxLength = 2
        textField.textChangedBlock = { [weak self] text in
            self?.delegate?.mk_rawFilterDataChanged(index: self?.dataModel?.index ?? 0, type: .dataType, value: text)
        }
        return textField
    }()
    private lazy var minTextField: MKTextField = {
        let textField = normalTextField(text: "", placeHolder: "", textType: .realNumberOnly)
        textField.font = MKFont(withSize: 13)
        textField.maxLength = 2
        textField.textChangedBlock = { [weak self] text in
            self?.delegate?.mk_rawFilterDataChanged(index: self?.dataModel?.index ?? 0, type: .minIndex, value: text)
        }
        return textField
    }()
    private lazy var maxTextField: MKTextField = {
        let textField = normalTextField(text: "", placeHolder: "", textType: .realNumberOnly)
        textField.font = MKFont(withSize: 13)
        textField.maxLength = 2
        textField.textChangedBlock = { [weak self] text in
            self?.delegate?.mk_rawFilterDataChanged(index: self?.dataModel?.index ?? 0, type: .maxIndex, value: text)
        }
        return textField
    }()
    private lazy var characterLabel: UILabel = {
        let label = normalTextLabel(text: "~")
        label.textAlignment = .center
        label.font = MKFont(withSize: 20)
        return label
    }()
    private lazy var unitLabel: UILabel = {
        let label = normalTextLabel(text: "Byte")
        label.font = MKFont(withSize: 13)
        return label
    }()
    private lazy var rawDataField: MKTextField = {
        let textField = normalTextField(text: "", placeHolder: "", textType: .realNumberOnly)
        textField.font = MKFont(withSize: 13)
        textField.textChangedBlock = { [weak self] text in
            self?.delegate?.mk_rawFilterDataChanged(index: self?.dataModel?.index ?? 0, type: .rawData, value: text)
        }
        return textField
    }()
}
