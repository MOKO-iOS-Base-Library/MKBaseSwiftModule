//
//  MKSearchButton.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/3/11.
//

import UIKit

import SnapKit

class MKSearchButtonDataModel: NSObject {
    /// 过滤的RSSI值
    var searchRssi: Int = 0
    /// 过滤的最小RSSI值，当searchRssi == minSearchRssi时，不显示searchRssi搜索条件
    var minSearchRssi: Int = -127
    /// 显示的标题
    var placeholder: String?
    /// 显示的搜索关键字(设备名称、MAC地址的一部分或者全部字段)
    var searchKey: String?
    /// 过滤的RSSI值
}

@objc protocol MKSearchButtonDelegate: AnyObject {
    func mk_scanSearchButtonMethod()
    func mk_scanSearchButtonClearMethod()
}

class MKSearchButton: UIControl {
    var delegate: MKSearchButtonDelegate?
    var dataModel: MKSearchButtonDataModel? {
        get {
            return self.deviceModel
        }
        set {
            self.deviceModel = nil
            self.deviceModel = newValue
            if self.deviceModel == nil {
                return
            }
            self.titleLabel.text = (self.deviceModel!.placeholder ?? "Edit Filter")
            var conditions: [String] = []
            if let searchKey = self.deviceModel!.searchKey {
                conditions.append(searchKey)
            }
            if self.deviceModel!.searchRssi > self.deviceModel!.minSearchRssi {
                let rssiValue = "\(self.deviceModel!.searchRssi)" + "dBm"
                conditions.append(rssiValue)
            }
            if conditions.count == 0 {
                self.titleLabel.isHidden = false
                self.searchIcon.isHidden = false
                self.searchLabel.isHidden = true
                self.clearButton.isHidden = true
                return
            }
            self.titleLabel.isHidden = true
            self.searchIcon.isHidden = true
            self.searchLabel.isHidden = false
            self.clearButton.isHidden = false
            var title = ""
            for value in conditions {
                title = title + ";" + "\(value)"
            }
            self.searchLabel.text = substring(string: title, startIndex: 1, length: title.count - 1)
        }
    }
    
    private var deviceModel: MKSearchButtonDataModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4.0
        self.addSubview(self.searchIcon)
        self.addSubview(self.titleLabel)
        self.addSubview(self.searchLabel)
        self.addSubview(self.clearButton)
        self.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.searchIcon.snp.remakeConstraints { make in
            make.left.equalTo(10.0)
            make.width.equalTo(22.0)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(22.0)
        }
        self.titleLabel.snp.remakeConstraints { make in
            make.left.equalTo(self.searchIcon.snp.right).offset(10.0)
            make.right.equalTo(-10)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(MKFont(withSize: 15).lineHeight)
        }
        self.searchLabel.snp.remakeConstraints { make in
            make.left.equalTo(10.0)
            make.right.equalTo(self.clearButton.snp.left).offset(-10.0)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(MKFont(withSize: 15).lineHeight)
        }
        self.clearButton.snp.remakeConstraints { make in
            make.right.equalTo(0.0)
            make.width.equalTo(45.0)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(self.snp.height)
        }
    }
    
    @objc func clearButtonPressed() {
        self.titleLabel.isHidden = false
        self.searchIcon.isHidden = false
        self.searchLabel.isHidden = true
        self.clearButton.isHidden = true
        self.delegate?.mk_scanSearchButtonClearMethod()
    }
    
    @objc func searchButtonPressed() {
        self.delegate?.mk_scanSearchButtonMethod()
    }
    
    
    
    private lazy var searchIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "mk_searchGrayIcon.png")
        return icon
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = rgbColor(220, 220, 220)
        label.textAlignment = .left
        label.font = MKFont(withSize: 15.0)
        label.text = "Edit Filter"
        return label
    }()
    private lazy var searchLabel: UILabel = {
        let label = UILabel()
        label.textColor = defaultTextColor
        label.textAlignment = .left
        label.font = MKFont(withSize: 15.0)
        return label
    }()
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "mk_clearButtonIcon.png"), for: .normal)
        button.addTarget(self, action: #selector(clearButtonPressed), for: .touchUpInside)
        return button
    }()
}
