//
//  MKSwiftDeviceInfoCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/4/10.
//

import UIKit
import SnapKit

// MARK: - Cell Model
class MKSwiftDeviceInfoCellModel {
    var leftMsg: String = ""
    var rightMsg: String = ""
    
    func cellHeightWithContentWidth(_ width: CGFloat) -> CGFloat {
        let leftSize = leftMsg.size(withFont: .systemFont(ofSize: 15), maxSize: CGSize(width: (width / 2 - 15 - 5), height: .greatestFiniteMagnitude))
        
        let rightSize = rightMsg.size(withFont: .systemFont(ofSize: 15), maxSize: CGSize(width: (width / 2 - 15 - 5), height: .greatestFiniteMagnitude))
        
        let height = max(leftSize.height, rightSize.height)
        return max(44, height + 20)
    }
}

// MARK: - Cell Implementation
class MKSwiftDeviceInfoCell: MKSwiftBaseCell {
    
    // MARK: - UI Components
    private var msgLabel: UILabel!
    private var rightMsgLabel: UILabel!
    
    // MARK: - Properties
    var dataModel: MKSwiftDeviceInfoCellModel? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Class Methods
    class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftDeviceInfoCell {
        let identifier = "MKSwiftDeviceInfoCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftDeviceInfoCell
        if cell == nil {
            cell = MKSwiftDeviceInfoCell(style: .default, reuseIdentifier: identifier)
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
        msgLabel.numberOfLines = 0
        contentView.addSubview(msgLabel)
        
        rightMsgLabel = UILabel()
        rightMsgLabel.textColor = Color.defaultText
        rightMsgLabel.textAlignment = .right
        rightMsgLabel.font = .systemFont(ofSize: 13)
        rightMsgLabel.numberOfLines = 0
        contentView.addSubview(rightMsgLabel)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let leftSize = msgLabel.text?.size(withFont: msgLabel.font, maxSize: CGSize(width: (contentView.frame.width / 2 - 15 - 5), height: .greatestFiniteMagnitude))
        
        msgLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(contentView.snp.centerX).offset(-5)
            make.centerY.equalToSuperview()
            make.height.equalTo(leftSize?.height ?? UIFont.systemFont(ofSize: 15).lineHeight)
        }
        
        let rightSize = rightMsgLabel.text?.size(withFont: msgLabel.font, maxSize: CGSize(width: (contentView.frame.width / 2 - 15 - 5), height: .greatestFiniteMagnitude))
        
        rightMsgLabel.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.left.equalTo(contentView.snp.centerX).offset(5)
            make.centerY.equalToSuperview()
            make.height.equalTo(rightSize?.height ?? UIFont.systemFont(ofSize: 15).lineHeight)
        }
    }
    
    // MARK: - Update UI
    private func updateUI() {
        guard let dataModel = dataModel else { return }
        
        msgLabel.text = dataModel.leftMsg
        rightMsgLabel.text = dataModel.rightMsg
        
        setNeedsLayout()
    }
}
