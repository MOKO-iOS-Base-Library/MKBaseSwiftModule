//
//  MKFilterEditSectionHeaderView.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/4/11.
//

import UIKit

class MKFilterEditSectionHeaderViewModel {
    var index: Int = 0
    var contentColor: UIColor = rgbColor(242, 242, 242)
    
    //左侧Message Label配置
    var msg: String = ""
}

protocol MKFilterEditSectionHeaderViewDelegate: AnyObject {
    
    /// +号点击事件
    /// - Parameter index: 所在index
    func mk_filterEditSectionHeaderViewAddButtonPressed(index:Int)
    
    /// -号点击事件
    /// - Parameter index: 所在index
    func mk_filterEditSectionHeaderViewSubButtonPressed(index:Int)
}

class MKFilterEditSectionHeaderView: UITableViewHeaderFooterView {
    var delegate: MKFilterEditSectionHeaderViewDelegate?
    var dataModel: MKFilterEditSectionHeaderViewModel? {
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
    
    private var privateDataModel: MKFilterEditSectionHeaderViewModel?
    
    static func initHeaderView(tableView: UITableView) -> MKFilterEditSectionHeaderView {
        let reuseIdentifier = "MKFilterEditSectionHeaderViewIdenty"
        if let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as? MKFilterEditSectionHeaderView {
            return cell
        } else {
            return MKFilterEditSectionHeaderView(reuseIdentifier: "MKFilterEditSectionHeaderViewIdenty")
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(addButton)
        contentView.addSubview(subButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - super method
    override func layoutSubviews() {
        super.layoutSubviews()
        subButton.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(30)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(30)
        }
        addButton.snp.remakeConstraints { make in
            make.right.equalTo(subButton.snp.left).offset(-15)
            make.width.equalTo(30)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(30)
        }
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(addButton.snp.left).offset(-15)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(MKFont(withSize: 15).lineHeight)
        }
    }
    
    //MARK: - event method
    @objc func addButtonPressed() {
        self.delegate?.mk_filterEditSectionHeaderViewAddButtonPressed(index: dataModel!.index)
    }
    
    @objc func subButtonPressed() {
        self.delegate?.mk_filterEditSectionHeaderViewSubButtonPressed(index: dataModel!.index)
    }
    
    //MARK: - private method
    private func updateDataModel() {
        contentView.backgroundColor = dataModel!.contentColor
        msgLabel.text = dataModel!.msg
    }
    
    //MARK: - 懒加载
    private lazy var msgLabel: UILabel = {
        let label = normalTextLabel(text: "")
        label.numberOfLines = 0
        return label
    }()
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(LOADIMAGE("mk_addIcon", "png"), for: .normal)
        button.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        return button
    }()
    private lazy var subButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(LOADIMAGE("mk_subIcon", "png"), for: .normal)
        button.addTarget(self, action: #selector(subButtonPressed), for: .touchUpInside)
        return button
    }()
}
