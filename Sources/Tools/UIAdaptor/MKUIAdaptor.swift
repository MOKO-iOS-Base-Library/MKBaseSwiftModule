//
//  MKUIAdaptor.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/3/27.
//

import UIKit


/// 圆角、背景颜色为通用导航栏颜色、白色字体的Button
/// - Parameters:
///   - title: 按钮标题
///   - target: target
///   - action: 点击事件
/// - Returns: UIButton
func cornerRadiusButton(title:String?, target: Any?, action: Selector) -> UIButton {
    let button = UIButton(type: .custom)
    button.backgroundColor = navbarColor
    button.setTitle(title, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = MKFont(withSize: 15)
    button.layer.masksToBounds = true
    button.layer.cornerRadius = 10
    button.addTarget(target, action: action, for: .touchUpInside)
    return button
}

/// 通用的居左、字体大小为15、默认黑色的Label
/// - Parameter text: Label显示的内容
/// - Returns: UILabel
func normalTextLabel(text:String) -> UILabel {
    let label = UILabel()
    label.textAlignment = .left
    label.textColor = defaultTextColor
    label.font = MKFont(withSize: 15)
    label.text = text
    return label;
}

/// 带圆角边框的输入框
/// - Parameters:
///   - text: 输入框显示的文本内容
///   - placeHolder: 占位符
///   - textType: 输入框输入内容的类型
/// - Returns: MKTextField
func normalTextField(text:String,placeHolder:String,textType:MKTextFieldType) -> MKTextField {
    let textField = MKTextField(textType: textType)
    textField.textColor = defaultTextColor
    textField.font = MKFont(withSize: 15)
    textField.textAlignment = .left
    textField.placeholder = placeHolder
    textField.text = text
    
    textField.layer.masksToBounds = true
    textField.layer.borderWidth = 0.5
    textField.layer.borderColor = rgbColor(162, 162, 162).cgColor
    textField.layer.cornerRadius = 6
    
    return textField
}


/// 富文本
/// - Parameters:
///   - strings: 富文本显示内容
///   - fonts: 显示内容的字体大小
///   - colors: 显示内容的文本颜色
/// - Returns: NSMutableAttributedString
func attributedString(strings: [String], fonts: [UIFont], colors: [UIColor]) -> NSMutableAttributedString {
    if strings.isEmpty || fonts.isEmpty || colors.isEmpty {
        return NSMutableAttributedString(string: "")
    }
    if strings.count != fonts.count || strings.count != colors.count || fonts.count != colors.count {
        return NSMutableAttributedString(string: "")
    }
    var sourceString = ""
    for str in strings {
        sourceString += str
    }
    if sourceString.isEmpty {
        return NSMutableAttributedString(string: "")
    }
    let resultString = NSMutableAttributedString(string: sourceString)
    var originPostion: CGFloat = 0
    for i in 0..<strings.count {
        let tempString = strings[i]
        resultString.addAttribute(NSAttributedString.Key.foregroundColor, value: colors[i], range: NSRange(location: Int(originPostion), length: tempString.count))
        resultString.addAttribute(NSAttributedString.Key.font, value: fonts[i], range: NSRange(location: Int(originPostion), length: tempString.count))
        originPostion += CGFloat(tempString.count)
    }
    return resultString
}

func strHeight(for string: NSAttributedString, viewWidth: CGFloat) -> CGFloat {
    if string.length == 0 {
        return 0
    }
    
    let size = string.boundingRect(with: CGSize(width: viewWidth, height: CGFloat.greatestFiniteMagnitude),
                                   options: [.usesLineFragmentOrigin, .usesFontLeading],
                                   context: nil).size
    return ceil(size.height)
}

func strWidth(for string: NSAttributedString, viewHeight: CGFloat) -> CGFloat {
    if string.length == 0 {
        return 0
    }
    
    let size = string.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: viewHeight),
                                   options: [.usesLineFragmentOrigin, .usesFontLeading],
                                   context: nil).size
    return ceil(size.width)
}
