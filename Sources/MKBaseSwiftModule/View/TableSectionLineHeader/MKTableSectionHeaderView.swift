//
//  MKTableSectionHeaderView.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/4/24.
//

import UIKit

class MKTableSectionHeaderViewModel {
    var contentColor: UIColor = rgbColor(242, 242, 242)
    
    //左侧Message Label配置
    var msg: String = ""
    var msgColor: UIColor = defaultTextColor
    var msgFont: UIFont = MKFont(withSize: 15)
}

class MKTableSectionHeaderView: UITableViewHeaderFooterView {
    var dataModel: MKTableSectionHeaderViewModel? {
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
    
    private var privateDataModel: MKTableSectionHeaderViewModel?
    
    static func initHeaderView(tableView: UITableView) -> MKTableSectionHeaderView {
        let reuseIdentifier = "MKTableSectionHeaderViewIdenty"
        if let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as? MKTableSectionHeaderView {
            return cell
        } else {
            return MKTableSectionHeaderView(reuseIdentifier: "MKTableSectionHeaderViewIdenty")
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - super method
    override func layoutSubviews() {
        super.layoutSubviews()
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(MKFont(withSize: 15).lineHeight)
        }
    }
    
    //MARK: - private method
    private func updateDataModel() {
        contentView.backgroundColor = dataModel!.contentColor
        msgLabel.text = dataModel!.msg
    }
    
    //MARK: - 懒加载
    private lazy var msgLabel: UILabel = {
        let label = normalTextLabel(text: "")
        return label
    }()
}
