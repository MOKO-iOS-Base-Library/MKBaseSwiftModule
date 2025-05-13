//
//  MKNormalSliderCell.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/3/28.
//

import UIKit

class MKNormalSliderCellModel: NSObject {
    var index: Int = 0
    //顶部msg必须用富文本字符串显示
    var msg: NSAttributedString = NSAttributedString(string: "")
    var contentColor: UIColor = .white
    
    //滑竿滑动的时候显示的单位,默认dBm
    var unit: String = "dBm"
    var unitColor: UIColor = RGB(0x353535)
    var unitFont: UIFont = MKFont(withSize: 11)
    
    //滑竿配置
    //是否启用滑竿
    var enable: Bool = true
    //滑竿最小值
    var minValue: Float = -127
    //滑竿最大值
    var maxValue: Float = 0
    //滑竿值
    var value: Float = 0
    
    //底部Note标签配置
    //是否动态改变底部note
    var changed: Bool = false
    
    
    //底部note标签内容.(changed = false)
    var noteMsg: String = ""
    //note标签字体颜色.(changed = false)
    var noteMsgColor: UIColor = RGB(0x353535)
    //note标签字体大小.(changed = false)
    var noteMsgFont: UIFont = MKFont(withSize: 12)
    
    //底部note标签内容是leftNoteMsg + 滑竿值+单位+rightNoteMsg.(changed = YES)
    var leftNoteMsg: String = ""
    //底部note标签内容是leftNoteMsg + 滑竿值+单位+rightNoteMsg.(changed = YES)
    var rightNoteMsg: String = ""
    
    
    func cellHeight() -> CGFloat {
        if msg.length == 0 {
            return 0
        }
        let msgHeight = strHeight(for: msg, viewWidth: screenWidth)
        let heightWithoutNote = msgHeight + 3 * 10 + 5
        if !changed && !ValidStr(noteMsg) {
            return max(heightWithoutNote, 55)
        }
        //存在底部的note
        let tempNoteMsg = (changed ? (leftNoteMsg + " " + "\(maxValue)" + unit + " " + rightNoteMsg) : noteMsg)
        
        let noteSize = stringSize(string: tempNoteMsg, font: noteMsgFont, maxSize: CGSize(width: (screenWidth - 2 * 15), height: CGFloat.greatestFiniteMagnitude))
        return max(heightWithoutNote, 55) + noteSize.height + 15
    }
}

protocol MKNormalSliderCellDelegate: AnyObject {
    
    /// slider值发生改变的回调事件
    /// - Parameters:
    ///   - index: 当前cell所在的index
    ///   - value: 当前slider的值
    func mk_normalSliderValueChanged(index: Int, value:Int)
}

class MKNormalSliderCell: MKBaseCell {
    
    var delegate: MKNormalSliderCellDelegate?
    var dataModel: MKNormalSliderCellModel? {
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
    
    static func initCell(tableView: UITableView) -> MKNormalSliderCell {
        let reuseIdentifier = "MKNormalSliderCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? MKNormalSliderCell {
            return cell
        } else {
            return MKNormalSliderCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(sliderValueLabel)
        contentView.addSubview(sliderView)
        contentView.addSubview(noteLabel)
    }
    
    //MARK: - super method
    override func layoutSubviews() {
        super.layoutSubviews()
        
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(10)
            make.height.equalTo(msgLabelHeight())
        }
        sliderView.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(sliderValueLabel.snp.left).offset(-5)
            make.top.equalTo(msgLabel.snp.bottom).offset(5)
            make.height.equalTo(10)
        }
        sliderValueLabel.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(70)
            make.centerY.equalTo(sliderView.snp.centerY)
            make.height.equalTo(MKFont(withSize: 12).lineHeight)
        }
        let noteSize = noteMsgSize()
        noteLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-10)
            make.height.equalTo(noteSize.height)
        }
    }
    
    //MARK: - event method
    @objc func sliderValueChanged() {
        var value = String(format: "%.f", self.sliderView.value)
        if value == "-0" {
            value = "0"
        }
        let displayMsg = value + dataModel!.unit
        sliderValueLabel.text = displayMsg
        
        if dataModel!.changed {
            noteLabel.text = dataModel!.leftNoteMsg + " " + displayMsg + " " + dataModel!.rightNoteMsg
        }
        
        delegate?.mk_normalSliderValueChanged(index: dataModel!.index, value: (Int(value) ?? 0))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - private method
    private func msgLabelHeight() -> CGFloat {
        return strHeight(for: dataModel?.msg ?? NSAttributedString(string: ""), viewWidth: contentView.frame.size.width - 30)
    }
    
    private func noteMsgSize() -> CGSize {
        if !ValidStr(noteLabel.text) {
            return CGSize(width: 0, height: 0)
        }
        let width = contentView.frame.size.width - 2 * 15
        let noteSize = stringSize(string: dataModel?.noteMsg ?? "", font: dataModel?.noteMsgFont ?? MKFont(withSize: 12), maxSize: CGSize(width: (screenWidth - 2 * 15), height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: width, height: noteSize.height)
    }
    
    private func updateDataModel() {
        contentView.backgroundColor = dataModel!.contentColor
        msgLabel.attributedText = dataModel!.msg
        sliderView.isEnabled = dataModel!.enable
        sliderView.maximumValue = dataModel!.maxValue
        sliderView.minimumValue = dataModel!.minValue
        sliderView.value = dataModel!.value
        sliderValueLabel.text = "\(Int(dataModel!.value))" + dataModel!.unit
        sliderValueLabel.textColor = dataModel!.unitColor
        sliderValueLabel.font = dataModel!.unitFont
        if dataModel!.changed {
            //left+value+unit+right
            noteLabel.text = dataModel!.leftNoteMsg + " " + "\(Int(dataModel!.value))" + dataModel!.unit + " " + dataModel!.rightNoteMsg
        }else {
            noteLabel.text = dataModel!.noteMsg
        }
        
        noteLabel.font = dataModel!.noteMsgFont
        noteLabel.textColor = dataModel!.noteMsgColor
        setNeedsLayout()
    }
    
    private var privateDataModel: MKNormalSliderCellModel?
    
    //MARK: - 懒加载
    private lazy var msgLabel: UILabel = {
        let label = normalTextLabel(text: "")
        label.numberOfLines = 0
        return label
    }()
    private lazy var sliderValueLabel: UILabel = {
        let label = normalTextLabel(text: "")
        label.font = MKFont(withSize: 11)
        return label
    }()
    private lazy var sliderView: MKSlider = {
        let slider = MKSlider()
        slider.maximumValue = 0
        slider.minimumValue = -127
        slider.addTarget(self,
                         action: #selector(sliderValueChanged),
                         for: .valueChanged)
        return slider
    }()
    private lazy var noteLabel: UILabel = {
        let label = normalTextLabel(text: "")
        label.font = MKFont(withSize: 12)
        label.numberOfLines = 0
        return label
    }()
}
