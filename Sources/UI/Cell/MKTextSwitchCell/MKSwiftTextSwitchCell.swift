//
//  MKSwiftTextSwitchCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/4/10.
//

import UIKit
import SnapKit

// MARK: - Model

public class MKSwiftTextSwitchCellModel {
    // MARK: Cell Top Configuration
    var index: Int = 0
    var contentColor: UIColor = .white
    
    // MARK: Left Label and Icon Configuration
    var leftIcon: UIImage?
    var msg: String = ""
    var msgColor: UIColor = Color.defaultText
    var msgFont: UIFont = .systemFont(ofSize: 15)
    
    // MARK: Switch Configuration
    var isOn: Bool = false
    var switchEnable: Bool = true
    
    // MARK: Bottom Label Configuration
    var noteMsg: String = ""
    var noteMsgColor: UIColor = Color.defaultText
    var noteMsgFont: UIFont = .systemFont(ofSize: 12)
    
    private let offsetX: CGFloat = 15
    private let switchButtonWidth: CGFloat = 40
    private let switchButtonHeight: CGFloat = 30
    
    func cellHeight(withContentWidth width: CGFloat) -> CGFloat {
        let maxMsgWidth = width - 3 * offsetX - switchButtonWidth - (leftIcon != nil ? (leftIcon!.size.width + 3) : 0)
        let msgSize = msg.size(withFont: msgFont, maxSize: CGSize(width: maxMsgWidth, height: .greatestFiniteMagnitude))
        
        guard !noteMsg.isEmpty else {
            return max(msgSize.height + 2 * offsetX, 50)
        }
        
        let noteSize = noteMsg.size(withFont: noteMsgFont, maxSize: CGSize(width: width - 2 * offsetX, height: .greatestFiniteMagnitude))
        return max(msgSize.height + 2 * offsetX, 50) + noteSize.height + 10
    }
}

// MARK: - Protocol

public protocol MKSwiftTextSwitchCellDelegate: AnyObject {
    func MKSwiftTextSwitchCellStatusChanged(isOn: Bool, index: Int)
}

// MARK: - Cell

public class MKSwiftTextSwitchCell: UITableViewCell {
    
    // MARK: Properties
    static let cellIdentifier = "MKSwiftTextSwitchCellIdentifier"
    
    var dataModel: MKSwiftTextSwitchCellModel? {
        didSet {
            updateUI()
        }
    }
    
    weak var delegate: MKSwiftTextSwitchCellDelegate?
    
    // MARK: UI Components
    private lazy var leftIconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.defaultText
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var switchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(loadIcon(podLibName: "MKBaseSwiftModule", bundleClassName: "MKSwiftTextSwitchCell", imageName: "mk_swift_switchUnselectedIcon.png"), for: .normal)
        button.addTarget(self, action: #selector(switchButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var noteLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.defaultText
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let offsetX: CGFloat = 15
    private let switchButtonWidth: CGFloat = 40
    private let switchButtonHeight: CGFloat = 30
    
    // MARK: Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Methods
    static func dequeueReusableCell(with tableView: UITableView) -> MKSwiftTextSwitchCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MKSwiftTextSwitchCell {
            return cell
        }
        return MKSwiftTextSwitchCell(style: .default, reuseIdentifier: cellIdentifier)
    }
    
    // MARK: Private Methods
    private func setupUI() {
        contentView.addSubview(msgLabel)
        contentView.addSubview(switchButton)
        contentView.addSubview(noteLabel)
    }
    
    private func updateUI() {
        guard let dataModel = dataModel else { return }
        
        contentView.backgroundColor = dataModel.contentColor
        msgLabel.text = dataModel.msg
        msgLabel.font = dataModel.msgFont
        msgLabel.textColor = dataModel.msgColor
        switchButton.isEnabled = dataModel.switchEnable
        switchButton.isSelected = dataModel.isOn
        switchButton.setImage(
            dataModel.isOn ? loadIcon(podLibName: "MKBaseSwiftModule", bundleClassName: "MKSwiftTextSwitchCell", imageName: "mk_swift_switchSelectedIcon.png") : loadIcon(podLibName: "MKBaseSwiftModule", bundleClassName: "MKSwiftTextSwitchCell", imageName: "mk_swift_switchUnselectedIcon.png"),
            for: .normal
        )
        
        if let leftIcon = dataModel.leftIcon {
            leftIconView.image = leftIcon
            contentView.addSubview(leftIconView)
        } else {
            leftIconView.removeFromSuperview()
        }
        
        noteLabel.text = dataModel.noteMsg
        noteLabel.font = dataModel.noteMsgFont
        noteLabel.textColor = dataModel.noteMsgColor
        
        setNeedsLayout()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateConstraints()
    }
    
    public override func updateConstraints() {
        guard let dataModel = dataModel else { return }
        
        let hasNote = !dataModel.noteMsg.isEmpty
        let msgSize = msgSize()
        
        if dataModel.leftIcon != nil {
            leftIconView.snp.remakeConstraints { make in
                make.left.equalTo(offsetX)
                make.width.equalTo(dataModel.leftIcon!.size.width)
                make.centerY.equalTo(msgLabel)
                make.height.equalTo(dataModel.leftIcon!.size.height)
            }
            
            msgLabel.snp.remakeConstraints { make in
                make.left.equalTo(leftIconView.snp.right).offset(3)
                make.right.equalTo(switchButton.snp.left).offset(-offsetX)
                if hasNote {
                    make.top.equalTo(offsetX)
                } else {
                    make.centerY.equalToSuperview()
                }
                make.height.equalTo(msgSize.height)
            }
        } else {
            msgLabel.snp.remakeConstraints { make in
                make.left.equalTo(offsetX)
                make.right.equalTo(switchButton.snp.left).offset(-offsetX)
                if hasNote {
                    make.top.equalTo(offsetX)
                } else {
                    make.centerY.equalToSuperview()
                }
                make.height.equalTo(msgSize.height)
            }
        }
        
        switchButton.snp.remakeConstraints { make in
            make.right.equalTo(-offsetX)
            make.width.equalTo(switchButtonWidth)
            make.centerY.equalTo(msgLabel)
            make.height.equalTo(switchButtonHeight)
        }
        
        let noteSize = noteSize()
        noteLabel.snp.remakeConstraints { make in
            make.left.equalTo(offsetX)
            make.right.equalTo(-offsetX)
            make.bottom.equalTo(-offsetX)
            make.height.equalTo(noteSize.height)
        }
    }
    
    private func msgSize() -> CGSize {
        guard let dataModel = dataModel, !dataModel.msg.isEmpty else {
            return .zero
        }
        
        var maxMsgWidth = contentView.frame.width - 3 * offsetX - switchButtonWidth
        if let leftIcon = dataModel.leftIcon {
            maxMsgWidth -= leftIcon.size.width + 3
        }
        
        return dataModel.msg.size(withFont: dataModel.msgFont, maxSize: CGSize(width: maxMsgWidth, height: .greatestFiniteMagnitude))
    }
    
    private func noteSize() -> CGSize {
        guard let dataModel = dataModel, !dataModel.noteMsg.isEmpty else {
            return .zero
        }
        
        let width = contentView.frame.width - 2 * offsetX
        return dataModel.noteMsg.size(withFont: dataModel.noteMsgFont, maxSize: CGSize(width: width, height: .greatestFiniteMagnitude))
    }
    
    // MARK: Actions
    @objc private func switchButtonPressed() {
        switchButton.isSelected = !switchButton.isSelected
        switchButton.setImage(switchButton.isSelected ? loadIcon(podLibName: "MKBaseSwiftModule", bundleClassName: "MKSwiftTextSwitchCell", imageName: "mk_swift_switchSelectedIcon.png") : loadIcon(podLibName: "MKBaseSwiftModule", bundleClassName: "MKSwiftTextSwitchCell", imageName: "mk_swift_switchUnselectedIcon.png"), for: .normal)
        delegate?.MKSwiftTextSwitchCellStatusChanged(isOn: switchButton.isSelected, index: dataModel?.index ?? 0)
    }
}

