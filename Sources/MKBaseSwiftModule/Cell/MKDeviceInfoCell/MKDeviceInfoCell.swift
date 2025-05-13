//
//  MKDeviceInfoCell.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/4/10.
//

import UIKit

class MKDeviceInfoCellModel {
    var contentColor: UIColor = .white
    
    var leftMsg: String = ""
    var rightMsg: String = ""
    
    func cellHeight() -> CGFloat {
        let leftMsgSize = stringSize(string: leftMsg, font: MKFont(withSize: 15), maxSize: CGSize(width: screenWidth / 2 - 20, height: CGFloat.greatestFiniteMagnitude))
        let rightMsgSize = stringSize(string: rightMsg, font: MKFont(withSize: 15), maxSize: CGSize(width: screenWidth / 2 - 20, height: CGFloat.greatestFiniteMagnitude))
        let height = max(leftMsgSize.height, rightMsgSize.height)
        return max(44, height + 20)
    }
}

class MKDeviceInfoCell: MKBaseCell {
    var dataModel: MKDeviceInfoCellModel? {
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
    
    static func initCell(tableView: UITableView) -> MKDeviceInfoCell {
        let reuseIdentifier = "MKDeviceInfoCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? MKDeviceInfoCell {
            return cell
        } else {
            return MKDeviceInfoCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(leftMsgLabel)
        contentView.addSubview(rightMsgLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let leftMsgSize = stringSize(string: dataModel!.leftMsg, font: MKFont(withSize: 15), maxSize: CGSize(width: screenWidth / 2 - 20, height: CGFloat.greatestFiniteMagnitude))
        let rightMsgSize = stringSize(string: dataModel!.rightMsg, font: MKFont(withSize: 15), maxSize: CGSize(width: screenWidth / 2 - 20, height: CGFloat.greatestFiniteMagnitude))
        
        leftMsgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(contentView.snp.centerX).offset(-5)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(leftMsgSize.height)
        }
        
        rightMsgLabel.snp.remakeConstraints { make in
            make.left.equalTo(contentView.snp.centerX).offset(5)
            make.right.equalTo(-15)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(rightMsgSize.height)
        }
    }
    
    private func updateDataModel() {
        contentView.backgroundColor = dataModel!.contentColor
        leftMsgLabel.text = SafeStr(dataModel!.leftMsg)
        rightMsgLabel.text = SafeStr(dataModel!.rightMsg)
        setNeedsLayout()
    }
    
    private var privateDataModel: MKDeviceInfoCellModel?
    
    //MARK: - 懒加载
    private lazy var leftMsgLabel: UILabel = {
        let label = normalTextLabel(text: "")
        label.numberOfLines = 0
        return label
    }()
    private lazy var rightMsgLabel: UILabel = {
        let label = normalTextLabel(text: "")
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
}
