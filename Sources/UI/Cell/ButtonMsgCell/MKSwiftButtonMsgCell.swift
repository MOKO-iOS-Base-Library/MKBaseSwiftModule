//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/6/4.
//

import UIKit
import SnapKit

// MARK: - Cell Model
class MKSwiftButtonMsgCellModel {
    // Cell top configuration
    var index: Int = 0
    var contentColor: UIColor = .white
    
    // Left label configuration
    var msg: String = ""
    var msgColor: UIColor = Color.defaultText
    var msgFont: UIFont = .systemFont(ofSize: 15)
    
    // Right button configuration
    var buttonEnable: Bool = true
    var buttonTitle: String = ""
    var buttonBackColor: UIColor = Color.navBar
    var buttonTitleColor: UIColor = .white
    var buttonLabelFont: UIFont = .systemFont(ofSize: 15)
    
    // Bottom label configuration
    var noteMsg: String = ""
    var noteMsgColor: UIColor = Color.defaultText
    var noteMsgFont: UIFont = .systemFont(ofSize: 12)
    
    func cellHeightWithContentWidth(_ width: CGFloat) -> CGFloat {
        let maxMsgWidth = width - 3 * 15 - 130 // offset_X = 15, selectButtonWidth = 130
        let msgSize = msg.size(withFont: msgFont, maxSize: CGSize(width: maxMsgWidth, height: .greatestFiniteMagnitude))
        
        guard !noteMsg.isEmpty else {
            return max(msgSize.height + 2 * 15, 50) // No note content
        }
        
        let noteSize = noteMsg.size(withFont: noteMsgFont, maxSize: CGSize(width: (width - 2 * 15), height: .greatestFiniteMagnitude))
        
        return max(msgSize.height + 2 * 15, 50) + noteSize.height + 10
    }
}

// MARK: - Cell Delegate
protocol MKSwiftButtonMsgCellDelegate: AnyObject {
    func mk_buttonMsgCellButtonPressed(_ index: Int)
}

// MARK: - Cell Implementation
class MKSwiftButtonMsgCell: MKSwiftBaseCell {
    
    // MARK: - UI Components
    private var msgLabel: UILabel!
    private var selectedButton: UIButton!
    private var noteLabel: UILabel!
    
    // MARK: - Properties
    var dataModel: MKSwiftButtonMsgCellModel? {
        didSet {
            updateUI()
        }
    }
    
    weak var delegate: MKSwiftButtonMsgCellDelegate?
    
    // MARK: - Constants
    private let offset_X: CGFloat = 15
    private let selectButtonWidth: CGFloat = 130
    private let selectButtonHeight: CGFloat = 30
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Class Methods
    class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftButtonMsgCell {
        let identifier = "MKSwiftButtonMsgCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftButtonMsgCell
        if cell == nil {
            cell = MKSwiftButtonMsgCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.backgroundColor = .white
        
        msgLabel = UILabel()
        msgLabel.textColor = Color.defaultText
        msgLabel.textAlignment = .left
        msgLabel.font = .systemFont(ofSize: 15)
        msgLabel.numberOfLines = 0
        contentView.addSubview(msgLabel)
        
        selectedButton = UIButton(type: .custom)
        selectedButton.setTitleColor(.white, for: .normal)
        selectedButton.backgroundColor = Color.navBar
        selectedButton.layer.masksToBounds = true
        selectedButton.layer.cornerRadius = 6
        selectedButton.addTarget(self, action: #selector(selectedButtonPressed), for: .touchUpInside)
        contentView.addSubview(selectedButton)
        
        noteLabel = UILabel()
        noteLabel.textColor = Color.defaultText
        noteLabel.font = .systemFont(ofSize: 12)
        noteLabel.textAlignment = .left
        noteLabel.numberOfLines = 0
        contentView.addSubview(noteLabel)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let hasNote = !(noteLabel.text?.isEmpty ?? true)
        let msgSize = self.msgSize()
        
        msgLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(offset_X)
            make.width.equalTo(msgSize.width)
            
            if hasNote {
                make.top.equalToSuperview().offset(offset_X)
            } else {
                make.centerY.equalToSuperview()
            }
            
            make.height.equalTo(msgSize.height)
        }
        
        selectedButton.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-offset_X)
            make.width.equalTo(selectButtonWidth)
            make.centerY.equalTo(msgLabel.snp.centerY)
            make.height.equalTo(selectButtonHeight)
        }
        
        let noteSize = self.noteSize()
        noteLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(offset_X)
            make.right.equalToSuperview().offset(-offset_X)
            make.bottom.equalToSuperview().offset(-offset_X)
            make.height.equalTo(noteSize.height)
        }
    }
    
    // MARK: - Actions
    @objc private func selectedButtonPressed() {
        delegate?.mk_buttonMsgCellButtonPressed(dataModel?.index ?? 0)
    }
    
    // MARK: - Helper Methods
    private func msgSize() -> CGSize {
        guard let text = msgLabel.text, !text.isEmpty else {
            return .zero
        }
        
        let maxMsgWidth = contentView.frame.width - 3 * offset_X - selectButtonWidth
        let size = text.size(withFont: msgLabel.font, maxSize: CGSize(width: maxMsgWidth, height: .greatestFiniteMagnitude))
        
        return CGSize(width: maxMsgWidth, height: size.height)
    }
    
    private func noteSize() -> CGSize {
        guard let text = noteLabel.text, !text.isEmpty else {
            return .zero
        }
        
        let width = contentView.frame.width - 2 * offset_X
        let size = text.size(withFont: noteLabel.font, maxSize: CGSize(width: width, height: .greatestFiniteMagnitude))
        
        return CGSize(width: width, height: size.height)
    }
    
    private func updateUI() {
        guard let dataModel = dataModel else { return }
        
        contentView.backgroundColor = dataModel.contentColor
        msgLabel.text = dataModel.msg
        msgLabel.font = dataModel.msgFont
        msgLabel.textColor = dataModel.msgColor
        
        selectedButton.isEnabled = dataModel.buttonEnable
        selectedButton.setTitle(dataModel.buttonTitle, for: .normal)
        selectedButton.titleLabel?.font = dataModel.buttonLabelFont
        selectedButton.backgroundColor = dataModel.buttonBackColor
        selectedButton.setTitleColor(dataModel.buttonTitleColor, for: .normal)
        
        noteLabel.text = dataModel.noteMsg
        noteLabel.font = dataModel.noteMsgFont
        noteLabel.textColor = dataModel.noteMsgColor
        
        setNeedsLayout()
    }
}
