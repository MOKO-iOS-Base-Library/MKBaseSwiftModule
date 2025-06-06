//
//  MKUIAdaptor.swift
//  YourProject
//
//  Created by YourName on 2024/3/27.
//

import UIKit

@MainActor struct MKSwiftUIAdaptor {
    // MARK: - Fonts
    static func font(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: weight)
    }
    
    // MARK: - Button Factory
    static func createRoundedButton(
        title: String,
        backgroundColor: UIColor = Color.navBar,
        titleColor: UIColor = .white,
        cornerRadius: CGFloat = 10,
        fontSize: CGFloat = 15,
        target: Any? = nil,
        action: Selector? = nil
    ) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = backgroundColor
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = font(size: fontSize)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = cornerRadius
        
        if let target = target, let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        
        return button
    }
    
    // MARK: - Label Factory
    static func createLabel(
        text: String,
        textColor: UIColor = Color.defaultText,
        fontSize: CGFloat = 15,
        alignment: NSTextAlignment = .left
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = textColor
        label.font = font(size: fontSize)
        label.textAlignment = alignment
        label.numberOfLines = 0
        return label
    }
    
    // MARK: - TextField Factory
    static func createTextField(
        text: String = "",
        placeholder: String = "",
        textType: MKSwiftTextFieldType = .normal,
        textColor: UIColor = Color.defaultText,
        fontSize: CGFloat = 15,
        borderColor: UIColor = UIColor(white: 0.635, alpha: 1.0),
        cornerRadius: CGFloat = 6,
        borderWidth: CGFloat = 0.5
    ) -> MKSwiftTextField {
        let textField = MKSwiftTextField(textFieldType: textType)
        textField.text = text
        textField.placeholder = placeholder
        textField.textColor = textColor
        textField.font = font(size: fontSize)
        textField.textAlignment = .left
        
        textField.layer.masksToBounds = true
        textField.layer.borderColor = borderColor.cgColor
        textField.layer.borderWidth = borderWidth
        textField.layer.cornerRadius = cornerRadius
        
        return textField
    }
    
    // MARK: - Attributed String
    static func createAttributedString(
        strings: [String],
        fonts: [UIFont],
        colors: [UIColor]
    ) -> NSAttributedString {
        guard !strings.isEmpty,
              strings.count == fonts.count,
              strings.count == colors.count else {
            return NSAttributedString(string: "")
        }
        
        let combinedString = strings.joined()
        let attributedString = NSMutableAttributedString(string: combinedString)
        
        var position = 0
        for (index, string) in strings.enumerated() {
            let range = NSRange(location: position, length: string.count)
            attributedString.addAttribute(.font, value: fonts[index], range: range)
            attributedString.addAttribute(.foregroundColor, value: colors[index], range: range)
            position += string.count
        }
        
        return attributedString
    }
    
    // MARK: - Text Size Calculation
    static func calculateTextSize(
        attributedString: NSAttributedString,
        maxWidth: CGFloat = .greatestFiniteMagnitude,
        maxHeight: CGFloat = .greatestFiniteMagnitude
    ) -> CGSize {
        guard attributedString.length > 0 else {
            return .zero
        }
        
        let constraintSize = CGSize(width: maxWidth, height: maxHeight)
        let boundingRect = attributedString.boundingRect(
            with: constraintSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        return CGSize(
            width: ceil(boundingRect.width),
            height: ceil(boundingRect.height)
        )
    }
    
    static func strHeight(forAttributedString string: NSAttributedString, viewWidth: CGFloat) -> CGFloat {
        guard string.length > 0 else {
            return 0
        }
        
        let size = string.boundingRect(
            with: CGSize(width: viewWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        
        return ceil(size.height)
    }
}

// MARK: - Usage Examples
/*
// 1. Create a button
let button = MKUIAdaptor.createRoundedButton(
    title: "Submit",
    target: self,
    action: #selector(buttonTapped)
)

// 2. Create a label
let label = MKUIAdaptor.createLabel(
    text: "Hello World",
    textColor: .darkGray,
    fontSize: 16
)

// 3. Create attributed string
let attributedText = MKUIAdaptor.createAttributedString(
    strings: ["Hello", "World"],
    fonts: [MKUIAdaptor.font(size: 14), MKUIAdaptor.font(size: 18, weight: .bold)],
    colors: [.black, .red]
)

// 4. Calculate text size
let textSize = MKUIAdaptor.calculateTextSize(
    attributedString: attributedText,
    maxWidth: 200
)
*/
