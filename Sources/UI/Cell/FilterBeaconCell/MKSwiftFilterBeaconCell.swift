//
//  MKSwiftFilterBeaconCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/4/10.
//

import UIKit
import SnapKit

public class MKSwiftFilterBeaconCellModel: NSObject {
    var index: Int = 0
    var msg: String = ""
    var minValue: String = ""
    var maxValue: String = ""
}

public protocol MKSwiftFilterBeaconCellDelegate: AnyObject {
    func mk_beaconMinValueChanged(_ value: String, index: Int)
    func mk_beaconMaxValueChanged(_ value: String, index: Int)
}

public class MKSwiftFilterBeaconCell: MKSwiftBaseCell {
    var dataModel: MKSwiftFilterBeaconCellModel? {
        didSet {
            updateContent()
        }
    }
    
    weak var delegate: MKSwiftFilterBeaconCellDelegate?
    
    private let msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.defaultText
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private let minLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.defaultText
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        label.text = "Min"
        return label
    }()
    
    private lazy var minTextField: MKSwiftTextField = {
        let textField = MKSwiftTextField(textFieldType: .realNumberOnly)
        textField.maxLength = 5
        textField.placeholder = "0~65535"
        textField.textChangedBlock = { [weak self] text in
            guard let self = self, let dataModel = self.dataModel else { return }
            self.delegate?.mk_beaconMinValueChanged(text, index: dataModel.index)
        }
        return textField
    }()
    
    private let centerLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.defaultText
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        label.text = "~"
        return label
    }()
    
    private let maxLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.defaultText
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        label.text = "Max"
        return label
    }()
    
    private lazy var maxTextField: MKSwiftTextField = {
        let textField = MKSwiftTextField(textFieldType: .realNumberOnly)
        textField.maxLength = 5
        textField.placeholder = "0~65535"
        textField.textChangedBlock = { [weak self] text in
            guard let self = self, let dataModel = self.dataModel else { return }
            self.delegate?.mk_beaconMaxValueChanged(text, index: dataModel.index)
        }
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(msgLabel)
        contentView.addSubview(minLabel)
        contentView.addSubview(minTextField)
        contentView.addSubview(centerLabel)
        contentView.addSubview(maxLabel)
        contentView.addSubview(maxTextField)
        
        msgLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(UIFont.systemFont(ofSize: 15).lineHeight)
        }
        
        minLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(50)
            make.centerY.equalTo(minTextField)
            make.height.equalTo(UIFont.systemFont(ofSize: 15).lineHeight)
        }
        
        minTextField.snp.makeConstraints { make in
            make.left.equalTo(minLabel.snp.right).offset(5)
            make.width.equalTo(80)
            make.top.equalTo(msgLabel.snp.bottom).offset(5)
            make.height.equalTo(30)
        }
        
        centerLabel.snp.makeConstraints { make in
            make.left.equalTo(minTextField.snp.right).offset(10)
            make.width.equalTo(30)
            make.centerY.equalTo(minTextField)
            make.height.equalTo(UIFont.systemFont(ofSize: 15).lineHeight)
        }
        
        maxLabel.snp.makeConstraints { make in
            make.left.equalTo(centerLabel.snp.right).offset(10)
            make.width.equalTo(50)
            make.centerY.equalTo(minTextField)
            make.height.equalTo(UIFont.systemFont(ofSize: 15).lineHeight)
        }
        
        maxTextField.snp.makeConstraints { make in
            make.left.equalTo(maxLabel.snp.right).offset(5)
            make.width.equalTo(80)
            make.centerY.equalTo(minTextField)
            make.height.equalTo(30)
        }
    }
    
    private func updateContent() {
        guard let dataModel = dataModel else { return }
        msgLabel.text = dataModel.msg
        minTextField.text = dataModel.minValue
        maxTextField.text = dataModel.maxValue
    }
    
    static func initCellWithTableView(_ tableView: UITableView) -> MKSwiftFilterBeaconCell {
        let identifier = "MKSwiftFilterBeaconCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftFilterBeaconCell
        if cell == nil {
            cell = MKSwiftFilterBeaconCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
}
