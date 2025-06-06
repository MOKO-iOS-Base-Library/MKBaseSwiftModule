//
//  MKSwiftTextButtonCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/4/10.
//

import UIKit
import SnapKit

// MARK: - Model

private let offsetX: CGFloat = 15
private let selectButtonWidth: CGFloat = 130
private let selectButtonHeight: CGFloat = 30

class MKSwiftTextButtonCellModel {
    // MARK: Cell Top Configuration
    var index: Int = 0
    var contentColor: UIColor = .white
    
    // MARK: Left Label Configuration
    var msg: String = ""
    var msgColor: UIColor = Color.defaultText
    var msgFont: UIFont = .systemFont(ofSize: 15)
    
    // MARK: Right Button Configuration
    var buttonEnable: Bool = true
    var dataList: [String] = []
    var dataListIndex: Int = 0
    var buttonBackColor: UIColor = Color.fromHex(0x2F84D0)
    var buttonTitleColor: UIColor = .white
    var buttonLabelFont: UIFont = .systemFont(ofSize: 15)
    
    // MARK: Bottom Label Configuration
    var noteMsg: String = ""
    var noteMsgColor: UIColor = Color.defaultText
    var noteMsgFont: UIFont = .systemFont(ofSize: 12)
    
    func cellHeight(withContentWidth width: CGFloat) -> CGFloat {
        let msgFont = self.msgFont
        let msgWidth = width - 3 * offsetX - selectButtonWidth  // Changed offset_X to offsetX
        let msgSize = msg.size(
            withFont: msgFont,
            maxSize: CGSize(width: msgWidth, height: .greatestFiniteMagnitude)
        )
        
        if noteMsg.isEmpty {  // Changed the optional check since noteMsg is non-optional
            // No bottom note content
            return max(msgSize.height + 2 * offsetX, 50.0)  // Changed offset_X to offsetX
        }
        
        // Has bottom note
        let noteFont = self.noteMsgFont
        let noteSize = noteMsg.size(
            withFont: noteFont,
            maxSize: CGSize(width: width - 2 * offsetX, height: .greatestFiniteMagnitude)  // Changed offset_X to offsetX
        )
        
        return max(msgSize.height + 2 * offsetX, 50.0) + noteSize.height + 10.0  // Changed offset_X to offsetX
    }
}

// MARK: - Protocol

protocol MKSwiftTextButtonCellDelegate: AnyObject {
    func MKSwiftTextButtonCellSelected(index: Int, dataListIndex: Int, value: String)
}

// MARK: - Cell

class MKSwiftTextButtonCell: UITableViewCell {
    
    // MARK: Properties
    static let cellIdentifier = "MKSwiftTextButtonCellIdentifier"
    
    var dataModel: MKSwiftTextButtonCellModel? {
        didSet {
            updateUI()
        }
    }
    
    weak var delegate: MKSwiftTextButtonCellDelegate?
    
    // MARK: UI Components
    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.defaultText
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var selectedButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Color.fromHex(0x2F84D0)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(selectedButtonPressed), for: .touchUpInside)
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
    private let selectButtonWidth: CGFloat = 130
    private let selectButtonHeight: CGFloat = 30
    
    // MARK: Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Methods
    static func dequeueReusableCell(with tableView: UITableView) -> MKSwiftTextButtonCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MKSwiftTextButtonCell {
            return cell
        }
        return MKSwiftTextButtonCell(style: .default, reuseIdentifier: cellIdentifier)
    }
    
    // MARK: Private Methods
    private func setupUI() {
        contentView.addSubview(msgLabel)
        contentView.addSubview(selectedButton)
        contentView.addSubview(noteLabel)
    }
    
    private func updateUI() {
        guard let dataModel = dataModel else { return }
        
        contentView.backgroundColor = dataModel.contentColor
        msgLabel.text = dataModel.msg
        msgLabel.font = dataModel.msgFont
        msgLabel.textColor = dataModel.msgColor
        selectedButton.isEnabled = dataModel.buttonEnable
        
        if dataModel.dataList.indices.contains(dataModel.dataListIndex) {
            selectedButton.setTitle(dataModel.dataList[dataModel.dataListIndex], for: .normal)
        }
        
        selectedButton.titleLabel?.font = dataModel.buttonLabelFont
        selectedButton.backgroundColor = dataModel.buttonBackColor
        selectedButton.setTitleColor(dataModel.buttonTitleColor, for: .normal)
        
        noteLabel.text = dataModel.noteMsg
        noteLabel.font = dataModel.noteMsgFont
        noteLabel.textColor = dataModel.noteMsgColor
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateConstraints()
    }
    
    internal override func updateConstraints() {
        guard let dataModel = dataModel else { return }
        
        let hasNote = !dataModel.noteMsg.isEmpty
        let msgSize = msgSize()
        
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(offsetX)
            make.width.equalTo(msgSize.width)
            if hasNote {
                make.top.equalTo(offsetX)
            } else {
                make.centerY.equalToSuperview()
            }
            make.height.equalTo(msgSize.height)
        }
        
        selectedButton.snp.remakeConstraints { make in
            make.right.equalTo(-offsetX)
            make.width.equalTo(selectButtonWidth)
            make.centerY.equalTo(msgLabel)
            make.height.equalTo(selectButtonHeight)
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
        
        let maxMsgWidth = contentView.frame.width - 3 * offsetX - selectButtonWidth
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
    @objc private func selectedButtonPressed() {
        NotificationCenter.default.post(name: Notification.Name("MKTextFieldNeedHiddenKeyboard"), object: nil)
        
        guard let dataModel = dataModel, !dataModel.dataList.isEmpty else { return }
        
        var selectedRow = 0
        if let currentTitle = selectedButton.titleLabel?.text,
           let index = dataModel.dataList.firstIndex(of: currentTitle) {
            selectedRow = index
        }
        
        let pickerView = MKSwiftPickerView()
        pickerView.showPickView(
            with: dataModel.dataList,
            selectedRow: selectedRow
        ) { [weak self] currentRow in
            guard let self = self else { return }
            self.selectedButton.setTitle(dataModel.dataList[currentRow], for: .normal)
            self.delegate?.MKSwiftTextButtonCellSelected(
                index: dataModel.index,
                dataListIndex: currentRow,
                value: dataModel.dataList[currentRow]
            )
        }
    }
}
