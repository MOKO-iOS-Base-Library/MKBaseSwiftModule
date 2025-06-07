//
//  MKSwiftFilterNormalTextFieldCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/4/11.
//

import UIKit
import SnapKit

// MARK: - Cell Model
public class MKSwiftFilterNormalTextFieldCellModel {
    var index: Int = 0
    var msg: String = ""
    var textFieldValue: String = ""
    var textPlaceholder: String = ""
    var textFieldType: MKSwiftTextFieldType = .normal
    var maxLength: Int = 0
}

// MARK: - Cell Delegate
public protocol MKSwiftFilterNormalTextFieldCellDelegate: AnyObject {
    func mk_filterNormalTextFieldValueChanged(_ text: String, index: Int)
}

// MARK: - Cell Implementation
public class MKSwiftFilterNormalTextFieldCell: MKSwiftBaseCell {
    
    // MARK: - UI Components
    private var msgLabel: UILabel!
    private var textField: MKSwiftTextField!
    
    // MARK: - Properties
    var dataModel: MKSwiftFilterNormalTextFieldCellModel? {
        didSet {
            updateUI()
        }
    }
    
    weak var delegate: MKSwiftFilterNormalTextFieldCellDelegate?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Class Methods
    class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftFilterNormalTextFieldCell {
        let identifier = "MKSwiftFilterNormalTextFieldCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftFilterNormalTextFieldCell
        if cell == nil {
            cell = MKSwiftFilterNormalTextFieldCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        msgLabel = UILabel()
        msgLabel.textColor = Color.defaultText
        msgLabel.textAlignment = .left
        msgLabel.font = .systemFont(ofSize: 15)
        contentView.addSubview(msgLabel)
        
        textField = MKSwiftTextField(textFieldType: .normal)
        textField.textColor = Color.defaultText
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 4
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 30))
        textField.leftViewMode = .always
        
        textField.textChangedBlock = { [weak self] text in
            guard let self = self else { return }
            self.delegate?.mk_filterNormalTextFieldValueChanged(text, index: self.dataModel?.index ?? 0)
        }
        
        contentView.addSubview(textField)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        msgLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(msgLabel.font.lineHeight)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(msgLabel.snp.bottom).offset(5)
            make.height.equalTo(30)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
    // MARK: - Update UI
    private func updateUI() {
        guard let dataModel = dataModel else { return }
        
        msgLabel.text = dataModel.msg
        textField.textType = dataModel.textFieldType
        textField.placeholder = dataModel.textPlaceholder
        textField.text = dataModel.textFieldValue
        textField.maxLength = dataModel.maxLength
    }
}
