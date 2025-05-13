//
//  MKDeviceInfoDfuCell.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/3/27.
//

import UIKit

import SnapKit

class MKDeviceInfoDfuCellModel {
    var index: Int = 0
    var leftMsg: String?
    var rightMsg: String?
    var rightButtonTitle: String?
}

protocol MKDeviceInfoDfuCellDelegate: AnyObject {
    
    /// 用户点击了右侧按钮
    /// - Parameter index: cell所在序列号
    func mk_deviceInfoDfuButtonAction(_ index: Int)
}

class MKDeviceInfoDfuCell: MKBaseCell {
    var delegate: MKDeviceInfoDfuCellDelegate?
    
    var dataModel: MKDeviceInfoDfuCellModel? {
        get {
            return privateDataModel
        }
        set {
            privateDataModel = nil
            privateDataModel = newValue
            
            guard let dataModel = privateDataModel else {
                return
            }
            msgLabel.text = dataModel.leftMsg
            rightMsgLabel.text = dataModel.rightMsg
            rightButton.setTitle(dataModel.rightButtonTitle, for: .normal)
        }
    }

    static func initCell(tableView: UITableView) -> MKDeviceInfoDfuCell {
        let reuseIdentifier = "MKDeviceInfoDfuCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? MKDeviceInfoDfuCell {
            return cell
        } else {
            return MKDeviceInfoDfuCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(rightMsgLabel)
        contentView.addSubview(rightButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(contentView.snp.centerX).offset(-5)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(MKFont(withSize: 15).lineHeight)
        }
        rightButton.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(50)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(35)
        }
        rightMsgLabel.snp.remakeConstraints { make in
            make.left.equalTo(contentView.snp.centerX).offset(10)
            make.right.equalTo(rightButton.snp.left).offset(-10)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(MKFont(withSize: 13).lineHeight)
        }
    }

    @objc private func rightButtonPressed() {
        if let index = dataModel?.index {
            delegate?.mk_deviceInfoDfuButtonAction(index)
        }
    }
    
    private var privateDataModel: MKDeviceInfoDfuCellModel?
    
    //MARK: - 懒加载
    private let msgLabel: UILabel = {
        return normalTextLabel(text: "")
    }()

    private let rightMsgLabel: UILabel = {
        let label = UILabel()
        label.textColor = RGB(0x808080)
        label.font = MKFont(withSize: 13)
        label.textAlignment = .right
        return label
    }()

    private lazy var rightButton: UIButton = {
        let button = cornerRadiusButton(title: "OK", target: self, action: #selector(rightButtonPressed))
        button.titleLabel?.font = MKFont(withSize: 12)
        return button
    }()
}
