//
//  MKSwiftDeviceInfoDfuCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/27.
//

import UIKit
import SnapKit

// MARK: - Cell Model
public class MKSwiftDeviceInfoDfuCellModel {
    var index: Int = 0
    var leftMsg: String = ""
    var rightMsg: String = ""
    var rightButtonTitle: String = ""
}

// MARK: - Cell Delegate
public protocol MKSwiftDeviceInfoDfuCellDelegate: AnyObject {
    func mk_textButtonCell_buttonAction(_ index: Int)
}

// MARK: - Cell Implementation
public class MKSwiftDeviceInfoDfuCell: MKSwiftBaseCell {
    
    // MARK: - UI Components
    private var msgLabel: UILabel!
    private var rightMsgLabel: UILabel!
    private var rightButton: UIButton!
    
    // MARK: - Properties
    var dataModel: MKSwiftDeviceInfoDfuCellModel? {
        didSet {
            updateUI()
        }
    }
    
    weak var delegate: MKSwiftDeviceInfoDfuCellDelegate?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Class Methods
    class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftDeviceInfoDfuCell {
        let identifier = "MKSwiftDeviceInfoDfuCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftDeviceInfoDfuCell
        if cell == nil {
            cell = MKSwiftDeviceInfoDfuCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.backgroundColor = .white
        
        msgLabel = UILabel()
        msgLabel.textColor = Color.defaultText
        msgLabel.font = .systemFont(ofSize: 15)
        msgLabel.textAlignment = .left
        contentView.addSubview(msgLabel)
        
        rightMsgLabel = UILabel()
        rightMsgLabel.textColor = Color.fromHex(0x808080)
        rightMsgLabel.font = .systemFont(ofSize: 13)
        rightMsgLabel.textAlignment = .right
        contentView.addSubview(rightMsgLabel)
        
        rightButton = UIButton(type: .custom)
        rightButton.titleLabel?.font = .systemFont(ofSize: 12)
        rightButton.setTitleColor(Color.defaultText, for: .normal)
        rightButton.addTarget(self, action: #selector(rightButtonPressed), for: .touchUpInside)
        rightButton.layer.borderColor = UIColor.lightGray.cgColor
        rightButton.layer.borderWidth = 0.5
        rightButton.layer.cornerRadius = 4
        contentView.addSubview(rightButton)
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        msgLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(contentView.snp.centerX).offset(-5)
            make.centerY.equalToSuperview()
            make.height.equalTo(msgLabel.font.lineHeight)
        }
        
        rightButton.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(50)
            make.centerY.equalToSuperview()
            make.height.equalTo(35)
        }
        
        rightMsgLabel.snp.remakeConstraints { make in
            make.left.equalTo(contentView.snp.centerX).offset(10)
            make.right.equalTo(rightButton.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(rightMsgLabel.font.lineHeight)
        }
    }
    
    // MARK: - Actions
    @objc private func rightButtonPressed() {
        delegate?.mk_textButtonCell_buttonAction(dataModel?.index ?? 0)
    }
    
    // MARK: - Update UI
    private func updateUI() {
        guard let dataModel = dataModel else { return }
        
        msgLabel.text = dataModel.leftMsg
        rightMsgLabel.text = dataModel.rightMsg
        rightButton.setTitle(dataModel.rightButtonTitle, for: .normal)
        
        setNeedsLayout()
    }
}
