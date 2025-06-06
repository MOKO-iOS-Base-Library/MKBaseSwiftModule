//
//  MKSwiftNormalSliderCell.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/28.
//

import UIKit
import SnapKit

// MARK: - Cell Model
class MKSwiftNormalSliderCellModel {
    // Cell top configuration
    var index: Int = 0
    var msg: NSAttributedString = NSAttributedString()
    var contentColor: UIColor = .white
    
    // Right unit label configuration
    var unit: String = "dBm"
    var unitColor: UIColor = Color.defaultText
    var unitFont: UIFont = .systemFont(ofSize: 11)
    
    // Slider configuration
    var sliderEnable: Bool = true
    var sliderMinValue: Int = -127
    var sliderMaxValue: Int = 0
    var sliderValue: Int = 0
    
    // Bottom label configuration
    var changed: Bool = false
    var noteMsg: String = ""
    var leftNoteMsg: String = ""
    var rightNoteMsg: String = ""
    var noteMsgColor: UIColor = Color.defaultText
    var noteMsgFont: UIFont = .systemFont(ofSize: 12)
    
    func cellHeightWithContentWidth(_ width: CGFloat) -> CGFloat {
        let msgHeight: CGFloat
        if !msg.string.isEmpty {
            msgHeight = String.size(with: msg.string,
                                  font: .systemFont(ofSize: 15),
                                  maxSize: CGSize(width: width, height: .greatestFiniteMagnitude)).height
        } else {
            msgHeight = 0
        }
        
        let heightWithoutNote = msgHeight + 3 * 10 + 5 // offset_Y = 10
        guard changed || !noteMsg.isEmpty else {
            return max(heightWithoutNote, 55)
        }
        
        let tempNoteMsg = changed ?
            "\(leftNoteMsg) \(sliderValue)\(unit) \(rightNoteMsg)" :
            noteMsg
        
        let noteSize = tempNoteMsg.size(withFont: noteMsgFont, maxSize: CGSize(width: (width - 2 * 15), height: .greatestFiniteMagnitude))
        
        return max(heightWithoutNote, 55) + noteSize.height + 15
    }
}

// MARK: - Cell Delegate
protocol MKSwiftNormalSliderCellDelegate: AnyObject {
    func mk_normalSliderValueChanged(_ value: Int, index: Int)
}

// MARK: - Cell Implementation
class MKSwiftNormalSliderCell: MKSwiftBaseCell {
    
    // MARK: - UI Components
    private var msgLabel: UILabel!
    private var sliderValueLabel: UILabel!
    private var sliderView: MKSwiftSlider!
    private var noteLabel: UILabel!
    
    // MARK: - Properties
    var dataModel: MKSwiftNormalSliderCellModel? {
        didSet {
            updateUI()
        }
    }
    
    weak var delegate: MKSwiftNormalSliderCellDelegate?
    
    // MARK: - Constants
    private let offset_X: CGFloat = 15
    private let offset_Y: CGFloat = 10
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Class Methods
    class func initCellWithTableView(_ tableView: UITableView) -> MKSwiftNormalSliderCell {
        let identifier = "MKSwiftNormalSliderCellIdenty"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MKSwiftNormalSliderCell
        if cell == nil {
            cell = MKSwiftNormalSliderCell(style: .default, reuseIdentifier: identifier)
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
        
        sliderValueLabel = UILabel()
        sliderValueLabel.textColor = Color.defaultText
        sliderValueLabel.textAlignment = .left
        sliderValueLabel.font = .systemFont(ofSize: 11)
        contentView.addSubview(sliderValueLabel)
        
        sliderView = MKSwiftSlider()
        sliderView.maximumValue = 0
        sliderView.minimumValue = -127
        sliderView.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        contentView.addSubview(sliderView)
        
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
        
        msgLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(offset_X)
            make.right.equalToSuperview().offset(-offset_X)
            make.top.equalToSuperview().offset(offset_Y)
            make.height.equalTo(msgLabelHeight())
        }
        
        sliderView.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(offset_X)
            make.right.equalTo(sliderValueLabel.snp.left).offset(-5)
            make.top.equalTo(msgLabel.snp.bottom).offset(5)
            make.height.equalTo(offset_Y)
        }
        
        sliderValueLabel.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-offset_X)
            make.width.equalTo(70)
            make.centerY.equalTo(sliderView.snp.centerY)
            make.height.equalTo(sliderValueLabel.font.lineHeight)
        }
        
        noteLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(offset_X)
            make.right.equalToSuperview().offset(-offset_X)
            make.bottom.equalToSuperview().offset(-offset_Y)
            make.height.equalTo(noteMsgSize().height)
        }
    }
    
    // MARK: - Actions
    @objc private func sliderValueChanged() {
        let value = Int(round(sliderView.value))
        sliderValueLabel.text = "\(value)\(dataModel?.unit ?? "")"
        
        if let model = dataModel, model.changed {
            noteLabel.text = "\(model.leftNoteMsg) \(value)\(model.unit) \(model.rightNoteMsg)"
        }
        
        delegate?.mk_normalSliderValueChanged(value, index: dataModel?.index ?? 0)
    }
    
    // MARK: - Helper Methods
    private func msgLabelHeight() -> CGFloat {
        guard let text = msgLabel.attributedText else { return 0 }
        return MKSwiftUIAdaptor.strHeight(forAttributedString: text, viewWidth: (contentView.frame.width - 30))
    }
    
    private func noteMsgSize() -> CGSize {
        guard let text = noteLabel.text, !text.isEmpty else {
            return .zero
        }
        
        let width = contentView.frame.width - 2 * offset_X
        return text.size(
            withFont: noteLabel.font,
            maxSize: CGSize(width: width, height: .greatestFiniteMagnitude)  // Changed offset_X to offsetX
        )
    }
    
    private func updateUI() {
        guard let dataModel = dataModel else { return }
        
        contentView.backgroundColor = dataModel.contentColor
        msgLabel.attributedText = dataModel.msg
        sliderView.isEnabled = dataModel.sliderEnable
        sliderView.maximumValue = Float(dataModel.sliderMaxValue)
        sliderView.minimumValue = Float(dataModel.sliderMinValue)
        sliderView.value = Float(dataModel.sliderValue)
        sliderValueLabel.text = "\(dataModel.sliderValue)\(dataModel.unit)"
        sliderValueLabel.textColor = dataModel.unitColor
        sliderValueLabel.font = dataModel.unitFont
        
        if dataModel.changed {
            noteLabel.text = "\(dataModel.leftNoteMsg) \(dataModel.sliderValue)\(dataModel.unit) \(dataModel.rightNoteMsg)"
        } else {
            noteLabel.text = dataModel.noteMsg
        }
        
        noteLabel.font = dataModel.noteMsgFont
        noteLabel.textColor = dataModel.noteMsgColor
        
        setNeedsLayout()
    }
}
