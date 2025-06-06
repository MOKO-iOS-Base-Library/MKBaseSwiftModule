//
//  MKSwiftTableSectionHeaderView.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/4/24.
//

import UIKit
import SnapKit

// MARK: - Data Model
public class MKSwiftTableSectionLineHeaderModel {
    public var contentColor: UIColor?
    public var msgTextFont: UIFont = .systemFont(ofSize: 15)
    public var msgTextColor: UIColor = Color.defaultText
    public var text: String?
    
    public init() {}
}

// MARK: - Header View
public class MKSwiftTableSectionLineHeader: UITableViewHeaderFooterView {
    
    // MARK: - UI Components
    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.defaultText
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Properties
    public var headerModel: MKSwiftTableSectionLineHeaderModel? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Initialization
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Class Method
    public static func dequeueHeader(with tableView: UITableView) -> MKSwiftTableSectionLineHeader {
        let identifier = String(describing: self)
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? MKSwiftTableSectionLineHeader {
            return header
        }
        return MKSwiftTableSectionLineHeader(reuseIdentifier: identifier)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        contentView.backgroundColor = Color.rgb(242, 242, 242)
        contentView.addSubview(msgLabel)
        
        msgLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
    }
    
    private func updateUI() {
        guard let headerModel = headerModel else {
            msgLabel.text = nil
            return
        }
        
        contentView.backgroundColor = headerModel.contentColor ?? Color.rgb(242, 242, 242)
        
        if let text = headerModel.text, !text.isEmpty {
            msgLabel.text = text
            msgLabel.textColor = headerModel.msgTextColor
            msgLabel.font = headerModel.msgTextFont
            
            // 计算文本高度并更新约束
            let maxWidth = UIScreen.main.bounds.width - 30
            let size = text.boundingRect(
                with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: headerModel.msgTextFont],
                context: nil
            ).size
            
            msgLabel.snp.updateConstraints { make in
                make.height.equalTo(ceil(size.height))
            }
        } else {
            msgLabel.text = nil
            msgLabel.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        }
    }
}
