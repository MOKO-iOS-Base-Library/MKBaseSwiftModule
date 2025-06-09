//
//  MKSwiftAlertView.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2024/3/13.
//

import UIKit

public class MKSwiftAlertViewAction {
    let title: String
    let handler: (() -> Void)
    
    init(title: String, handler: @escaping (() -> Void)) {
        self.title = title
        self.handler = handler
    }
}

public class MKSwiftAlertViewTextField {
    let textValue: String
    let placeholder: String
    let textFieldType: MKSwiftTextFieldType
    let maxLength: Int
    let handler: ((String) -> Void)
    
    init(textValue: String,
         placeholder: String,
         textFieldType: MKSwiftTextFieldType,
         maxLength: Int,
         handler: @escaping ((String) -> Void)) {
        self.textValue = textValue
        self.placeholder = placeholder
        self.textFieldType = textFieldType
        self.maxLength = maxLength
        self.handler = handler
    }
}

public class MKSwiftAlertView: UIView {
    
    // MARK: - Constants
    private let centerViewOffsetX: CGFloat = 50.0
    private let msgLabelOffsetX: CGFloat = 10.0
    private let titleLabelOffsetY: CGFloat = 25.0
    private let buttonHeight: CGFloat = 45.0
    private let textFieldHeight: CGFloat = 30.0
    
    // MARK: - UI Components
    private lazy var centerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.rgb(234, 234, 234)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8.0
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Color.defaultText
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Color.defaultText
        label.font = Font.MKFont(14)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var textFieldView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = Color.defaultText.cgColor
        view.layer.cornerRadius = 6.0
        return view
    }()
    
    private lazy var horizontalLine: UIView = {
        let view = UIView()
        view.backgroundColor = Color.defaultText
        return view
    }()
    
    // MARK: - Data Stores
    private var actionList: [MKSwiftAlertViewAction] = []
    private var buttonList: [UIButton] = []
    private var textModelList: [MKSwiftAlertViewTextField] = []
    private var textFieldList: [MKSwiftTextField] = []
    private var asciiStringList: [String] = []
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        addSubview(centerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("MKSwiftAlertView销毁")
    }
    
    // MARK: - Public Methods
    func addAction(_ action: MKSwiftAlertViewAction) {
        guard actionList.count < 2 else { return }
        actionList.append(action)
    }
    
    func addTextField(_ textModel: MKSwiftAlertViewTextField) {
        guard textModelList.count < 2 else { return }
        textModelList.append(textModel)
    }
    
    func showAlert(withTitle title: String, message: String, notificationName: String? = nil) {
        guard actionList.count > 0, actionList.count <= 2 else { return }
        
        App.window?.addSubview(self)
        
        if let notificationName = notificationName {
            NotificationCenter.default.addObserver(self,
                                                 selector: #selector(dismiss),
                                                 name: NSNotification.Name(notificationName),
                                                 object: nil)
        }
        
        centerView.subviews.forEach { $0.removeFromSuperview() }
        textFieldView.subviews.forEach { $0.removeFromSuperview() }
        
        titleLabel.text = title
        centerView.addSubview(titleLabel)
        
        messageLabel.text = message
        centerView.addSubview(messageLabel)
        
        centerView.addSubview(textFieldView)
        centerView.addSubview(horizontalLine)
        
        buttonList.removeAll()
        textFieldList.removeAll()
        asciiStringList.removeAll()
        
        for (index, action) in actionList.enumerated() {
            let selector = index == 0 ? #selector(buttonPressed0) : #selector(buttonPressed1)
            let actionButton = loadButton(withTitle: action.title, selector: selector)
            centerView.addSubview(actionButton)
            buttonList.append(actionButton)
        }
        
        for (index, textModel) in textModelList.enumerated() {
            let textField = loadTextField(withTextValue: textModel.textValue,
                                         placeHolder: textModel.placeholder,
                                         textType: textModel.textFieldType)
            textField.prohibitedMethodsList = ["cut", "copy", "select", "selectAll", "paste"]
            textField.maxLength = textModel.maxLength
            
            let selector = index == 0 ? #selector(textFieldValueChanged0) : #selector(textFieldValueChanged1)
            textField.addTarget(self, action: selector, for: .editingChanged)
            
            textFieldView.addSubview(textField)
            textFieldList.append(textField)
            asciiStringList.append(textModel.textValue)
        }
        
        setupSubviews()
        
        if let firstTextField = textFieldList.first {
            firstTextField.becomeFirstResponder()
        }
    }
    
    @objc func dismiss() {
        removeFromSuperview()
    }
    
    // MARK: - Button Actions
    @objc private func buttonPressed0() {
        guard actionList.count > 0 else { return }
        actionList[0].handler()
        dismiss()
    }
    
    @objc private func buttonPressed1() {
        guard actionList.count > 1 else { return }
        actionList[1].handler()
        dismiss()
    }
    
    // MARK: - TextField Actions
    @objc private func textFieldValueChanged0() {
        handleTextFieldChange(at: 0)
    }
    
    @objc private func textFieldValueChanged1() {
        handleTextFieldChange(at: 1)
    }
    
    private func handleTextFieldChange(at index: Int) {
        guard textFieldList.count > index else { return }
        
        let textField = textFieldList[index]
        let textModel = textModelList[index]
        
        guard let inputValue = textField.text else {
            textField.text = ""
            asciiStringList[index] = ""
            textModel.handler("")
            return
        }
        
        if inputValue.isEmpty {
            textField.text = ""
            asciiStringList[index] = ""
            textModel.handler("")
            return
        }
        
        let strLen = inputValue.count
        let dataLen = inputValue.data(using: .utf8)?.count ?? 0
        
        var currentStr = asciiStringList[index]
        if dataLen == strLen {
            // Current input is ASCII characters
            currentStr = inputValue
        }
        
        if textModel.maxLength > 0 && currentStr.count > textModel.maxLength {
            let limitedStr = String(currentStr.prefix(textModel.maxLength))
            textField.text = limitedStr
            currentStr = limitedStr
            textModel.handler(limitedStr)
        } else {
            textField.text = currentStr
            textModel.handler(currentStr)
        }
        
        asciiStringList[index] = currentStr
    }
    
    // MARK: - UI Setup
    private func loadButton(withTitle title: String, selector: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitleColor(.blue, for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    private func loadTextField(withTextValue textValue: String,
                              placeHolder: String,
                              textType: MKSwiftTextFieldType) -> MKSwiftTextField {
        let textField = MKSwiftTextField(textFieldType: textType)
        textField.textColor = Color.defaultText
        textField.font = Font.MKFont(13)
        textField.textAlignment = .left
        textField.placeholder = placeHolder
        textField.text = textValue
        return textField
    }
    
    private func setupSubviews() {
        let messageHeight = calculateMessageLabelHeight()
        let titleHeight = calculateTitleHeight()
        let textViewHeight = calculateTextFieldViewHeight()
        
        let centerViewHeight = titleLabelOffsetY + messageHeight + titleHeight + textViewHeight + 0.5 + buttonHeight + 20.0
        
        centerView.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(centerViewOffsetX)
            make.right.equalToSuperview().offset(-centerViewOffsetX)
            
            if textFieldList.count > 0 {
                make.centerY.equalToSuperview().offset(-90.0)
            } else {
                make.centerY.equalToSuperview()
            }
            
            make.height.equalTo(centerViewHeight)
        }
        
        if let titleText = titleLabel.text, !titleText.isEmpty {
            // Has title
            titleLabel.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(5.0)
                make.right.equalToSuperview().offset(-5.0)
                make.top.equalToSuperview().offset(titleLabelOffsetY)
                make.height.equalTo(UIFont.boldSystemFont(ofSize: 18.0).lineHeight)
            }
            
            messageLabel.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(msgLabelOffsetX)
                make.right.equalToSuperview().offset(-msgLabelOffsetX)
                make.top.equalTo(titleLabel.snp.bottom).offset(10.0)
                make.height.equalTo(messageHeight)
            }
        } else {
            // No title
            titleLabel.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(5.0)
                make.right.equalToSuperview().offset(-5.0)
                make.top.equalToSuperview().offset(titleLabelOffsetY)
                make.height.equalTo(0)
            }
            
            messageLabel.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(msgLabelOffsetX)
                make.right.equalToSuperview().offset(-msgLabelOffsetX)
                make.top.equalToSuperview().offset(titleLabelOffsetY)
                make.height.equalTo(messageHeight)
            }
        }
        
        textFieldView.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(15.0)
            make.right.equalToSuperview().offset(-15.0)
            make.top.equalTo(messageLabel.snp.bottom).offset(10.0)
            make.height.equalTo(textViewHeight)
        }
        
        switch textFieldList.count {
        case 1:
            // One text field
            let textField = textFieldList[0]
            textField.snp.remakeConstraints { make in
                make.left.right.top.bottom.equalToSuperview()
            }
            
            horizontalLine.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(textFieldView.snp.bottom).offset(10.0)
                make.height.equalTo(0.5)
            }
            
        case 2:
            // Two text fields
            let textField1 = textFieldList[0]
            textField1.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview()
                make.height.equalTo(textFieldHeight)
            }
            
            let lineView = UIView()
            lineView.backgroundColor = Color.defaultText
            textFieldView.addSubview(lineView)
            
            lineView.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(textField1.snp.bottom)
                make.height.equalTo(0.5)
            }
            
            let textField2 = textFieldList[1]
            textField2.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(lineView.snp.bottom)
                make.height.equalTo(textFieldHeight)
            }
            
            horizontalLine.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(textFieldView.snp.bottom).offset(10.0)
                make.height.equalTo(0.5)
            }
            
        default:
            // No text fields
            horizontalLine.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(messageLabel.snp.bottom).offset(20.0)
                make.height.equalTo(0.5)
            }
        }
        
        switch buttonList.count {
        case 1:
            // One button
            let button = buttonList[0]
            button.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(horizontalLine.snp.bottom)
                make.bottom.equalToSuperview()
            }
            
        case 2:
            // Two buttons
            let verticalLine = UIView()
            verticalLine.backgroundColor = Color.defaultText
            centerView.addSubview(verticalLine)
            
            verticalLine.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.width.equalTo(0.5)
                make.top.equalTo(horizontalLine.snp.bottom)
                make.bottom.equalToSuperview()
            }
            
            let button1 = buttonList[0]
            let button2 = buttonList[1]
            
            button1.snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.right.equalTo(verticalLine.snp.left)
                make.top.equalTo(horizontalLine.snp.bottom)
                make.bottom.equalToSuperview()
            }
            
            button2.snp.remakeConstraints { make in
                make.left.equalTo(verticalLine.snp.right)
                make.right.equalToSuperview()
                make.top.equalTo(horizontalLine.snp.bottom)
                make.bottom.equalToSuperview()
            }
            
        default:
            break
        }
    }
    
    // MARK: - Helper Methods
    private func calculateTitleHeight() -> CGFloat {
        guard let titleText = titleLabel.text, !titleText.isEmpty else {
            return 0
        }
        return UIFont.boldSystemFont(ofSize: 18.0).lineHeight + 10.0
    }
    
    private func calculateTextFieldViewHeight() -> CGFloat {
        return CGFloat(textFieldList.count) * textFieldHeight
    }
    
    private func calculateMessageLabelHeight() -> CGFloat {
        guard let text = messageLabel.text else { return 0 }
        
        let maxWidth = UIScreen.main.bounds.width - 2 * (centerViewOffsetX + msgLabelOffsetX)
        let size = NSString(string: text).boundingRect(
            with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: messageLabel.font!],
            context: nil
        ).size
        
        return size.height
    }
}
