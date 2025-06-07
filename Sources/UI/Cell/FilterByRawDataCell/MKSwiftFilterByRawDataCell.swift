//
//  MKSwiftFilterByRawDataCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/4/10.
//

import UIKit
import SnapKit

public class MKSwiftFilterByRawDataCellModel: NSObject {
    var index: Int = 0
    var msg: String = ""
    var contentColor: UIColor = .white
    var dataType: String = ""
    var minIndex: String = ""
    var maxIndex: String = ""
    var rawData: String = ""
    var rawDataMaxBytes: Int = 29
    var dataTypePlaceHolder: String = ""
    var minTextFieldPlaceHolder: String = ""
    var maxTextFieldPlaceHolder: String = ""
    var rawTextFieldPlaceHolder: String = ""
    
    func validParamsSuccess() -> Bool {
        // Use String.isHexadecimal constant with matchesRegex method
        guard dataType.count == 2, dataType.matchesRegex(String.isHexadecimal) else {
            return false
        }
        
        if minIndex.isEmpty && maxIndex.isEmpty {
            return validRawDatas()
        }
        
        // Use String.isRealNumbers constant with matchesRegex method
        guard !minIndex.isEmpty, minIndex.count <= 2, minIndex.matchesRegex(String.isRealNumbers),
              let minValue = Int(minIndex), minValue >= 0, minValue <= rawDataMaxBytes else {
            return false
        }
        
        if minValue == 0 {
            if (maxIndex.isEmpty || (Int(maxIndex) == 0)) && validRawDatas() {
                return true
            }
            return false
        }
        
        guard !maxIndex.isEmpty, maxIndex.count <= 2, maxIndex.matchesRegex(String.isRealNumbers),
              let maxValue = Int(maxIndex), maxValue >= 0, maxValue <= rawDataMaxBytes,
              maxValue >= minValue else {
            return false
        }
        
        guard Valid.isStringValid(rawData), rawData.count <= rawDataMaxBytes * 2,
              rawData.matchesRegex(String.isHexadecimal) else {
            return false
        }
        
        let totalLen = (maxValue - minValue + 1) * 2
        return rawData.count == totalLen
    }
    
    func validRawDatas() -> Bool {
        guard Valid.isStringValid(rawData), rawData.count <= rawDataMaxBytes * 2,
              rawData.matchesRegex(String.isHexadecimal) else {
            return false
        }
        return rawData.count % 2 == 0
    }
}

public enum MKFilterByRawDataTextType: Int {
    case dataType
    case minIndex
    case maxIndex
    case rawDataType
}

public protocol MKSwiftFilterByRawDataCellDelegate: AnyObject {
    func mk_rawFilterDataChanged(_ textType: MKFilterByRawDataTextType, index: Int, textValue: String)
}

public class MKSwiftFilterByRawDataCell: MKSwiftBaseCell {
    var dataModel: MKSwiftFilterByRawDataCellModel? {
        didSet {
            updateContent()
        }
    }
    
    weak var delegate: MKSwiftFilterByRawDataCellDelegate?
    
    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.defaultText
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var typeTextField: MKSwiftTextField = {
        let textField = MKSwiftTextField(textFieldType: .hexCharOnly)
        textField.maxLength = 2
        textField.textChangedBlock = { [weak self] text in
            self?.textFieldValueChanged(text, textType: .dataType)
        }
        return textField
    }()
    
    private lazy var minTextField: MKSwiftTextField = {
        let textField = MKSwiftTextField(textFieldType: .realNumberOnly)
        textField.maxLength = 2
        textField.textChangedBlock = { [weak self] text in
            self?.textFieldValueChanged(text, textType: .minIndex)
        }
        return textField
    }()
    
    private lazy var maxTextField: MKSwiftTextField = {
        let textField = MKSwiftTextField(textFieldType: .realNumberOnly)
        textField.maxLength = 2
        textField.textChangedBlock = { [weak self] text in
            self?.textFieldValueChanged(text, textType: .maxIndex)
        }
        return textField
    }()
    
    private let characterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Color.defaultText
        label.font = .systemFont(ofSize: 20)
        label.text = "~"
        return label
    }()
    
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = Color.defaultText
        label.font = .systemFont(ofSize: 13)
        label.text = "Byte"
        return label
    }()
    
    private lazy var rawDataField: MKSwiftTextField = {
        let textField = MKSwiftTextField(textFieldType: .hexCharOnly)
        textField.textChangedBlock = { [weak self] text in
            self?.textFieldValueChanged(text, textType: .rawDataType)
        }
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        contentView.addSubview(msgLabel)
        contentView.addSubview(typeTextField)
        contentView.addSubview(minTextField)
        contentView.addSubview(maxTextField)
        contentView.addSubview(characterLabel)
        contentView.addSubview(unitLabel)
        contentView.addSubview(rawDataField)
        
        msgLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(UIFont.systemFont(ofSize: 15).lineHeight)
        }
        
        typeTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(70)
            make.top.equalTo(msgLabel.snp.bottom).offset(5)
            make.height.equalTo(30)
        }
        
        minTextField.snp.makeConstraints { make in
            make.left.equalTo(typeTextField.snp.right).offset(20)
            make.width.equalTo(40)
            make.centerY.equalTo(typeTextField)
            make.height.equalTo(typeTextField)
        }
        
        characterLabel.snp.makeConstraints { make in
            make.left.equalTo(minTextField.snp.right).offset(5)
            make.width.equalTo(20)
            make.centerY.equalTo(typeTextField)
            make.height.equalTo(typeTextField)
        }
        
        maxTextField.snp.makeConstraints { make in
            make.left.equalTo(characterLabel.snp.right).offset(5)
            make.width.equalTo(40)
            make.centerY.equalTo(typeTextField)
            make.height.equalTo(typeTextField)
        }
        
        unitLabel.snp.makeConstraints { make in
            make.left.equalTo(maxTextField.snp.right).offset(3)
            make.width.equalTo(40)
            make.centerY.equalTo(typeTextField)
            make.height.equalTo(typeTextField)
        }
        
        rawDataField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(typeTextField.snp.bottom).offset(15)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        // Configure text fields appearance
        [typeTextField, minTextField, maxTextField, rawDataField].forEach {
            $0.backgroundColor = .white
            $0.font = .systemFont(ofSize: 13)
            $0.textColor = Color.defaultText
            $0.textAlignment = .left
            $0.layer.masksToBounds = true
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = Color.rgb(162, 162, 162).cgColor
            $0.layer.cornerRadius = 6
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textFieldHiddenKeyboard),
            name: Notification.Name("MKTextFieldNeedHiddenKeyboard"),
            object: nil
        )
    }
    
    @objc private func textFieldHiddenKeyboard() {
        [typeTextField, minTextField, maxTextField, rawDataField].forEach {
            $0.resignFirstResponder()
        }
    }
    
    private func textFieldValueChanged(_ text: String, textType: MKFilterByRawDataTextType) {
        guard let dataModel = dataModel else { return }
        delegate?.mk_rawFilterDataChanged(textType, index: dataModel.index, textValue: text)
    }
    
    private func updateContent() {
        guard let dataModel = dataModel else { return }
        msgLabel.text = dataModel.msg
        contentView.backgroundColor = dataModel.contentColor
        typeTextField.text = dataModel.dataType
        typeTextField.placeholder = dataModel.dataTypePlaceHolder
        minTextField.text = dataModel.minIndex
        minTextField.placeholder = dataModel.minTextFieldPlaceHolder
        maxTextField.text = dataModel.maxIndex
        maxTextField.placeholder = dataModel.maxTextFieldPlaceHolder
        rawDataField.text = dataModel.rawData
        rawDataField.placeholder = dataModel.rawTextFieldPlaceHolder
        rawDataField.maxLength = dataModel.rawDataMaxBytes * 2
    }
    
    static func initCellWithTableView(_ tableView: UITableView) -> MKSwiftFilterByRawDataCell {
        let identifier = "MKSwiftFilterByRawDataCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftFilterByRawDataCell
        if cell == nil {
            cell = MKSwiftFilterByRawDataCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
}
