//
//  MKBaseCell.swift
//  MKPS101SwiftProject_Example
//
//  Created by aa on 2024/2/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SnapKit
import UIKit

class MKBaseCell: UITableViewCell {
    var indexPath:IndexPath?;
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none;
        contentView.backgroundColor = .white;
        contentView.addSubview(lineView);
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        lineView.snp.makeConstraints { make in
            make.left.equalTo(15);
            make.right.equalTo(-15);
            make.bottom.equalToSuperview();
            make.height.equalTo(CUTTING_LINE_HEIGHT)
        }
    }
    
    private lazy var lineView:UIView = {
        let lineView = UIView();
        lineView.backgroundColor = lineColor;
        return lineView;
    }()
}
