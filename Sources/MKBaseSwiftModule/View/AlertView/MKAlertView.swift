//
//  MKAlertView.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/3/13.
//

import UIKit

import SnapKit

class MKAlertViewAction {
    let title: String
    let handler: (() -> Void)?
    
    init(title: String, handler: @escaping () -> Void) {
        self.title = title
        self.handler = handler
    }
}

class MKAlertViewTextField {
    let textValue: String
    let placeholder: String
    let textFieldType: MKTextFieldType
    let maxLength: Int
    let handler: ((String) -> Void)?
    
    init(textValue: String, placeholder: String, textFieldType: MKTextFieldType, maxLength: Int, handler: ((String) -> Void)?) {
        self.textValue = textValue
        self.placeholder = placeholder
        self.textFieldType = textFieldType
        self.maxLength = maxLength
        self.handler = handler
    }
}


class MKAlertView: UIView {
    
    deinit {
        print("MKAlertView销毁")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = appWindow!.bounds
        self.backgroundColor = rgbaColor(0, 0, 0, 0.3)
        self.addSubview(self.centerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - event method
    @objc func buttonPressed0() {
        if actionList.count == 0 {
            return
        }
        let action:MKAlertViewAction = actionList[0]
        if let hander = action.handler {
            hander()
        }
        dismiss()
    }
    
    @objc func buttonPressed1() {
        guard actionList.count > 1 else {
            return
        }
        
        let action = self.actionList[1]
        if let handler = action.handler {
            handler()
        }
        
        dismiss()
    }

    @objc func textFieldValueChanged0() {
        guard self.textFieldList.count > 0 else {
            return
        }
        
        let textField = self.textFieldList[0]
        let textModel = self.textModelList[0]
        
        let inputValue = textField.text ?? ""
        if !ValidStr(inputValue) {
            textField.text = ""
            self.asciiStringList[0] = ""
            
            if let handler = textModel.handler {
                handler("")
            }
            return
        }
        
        let strLen = inputValue.count
        let dataLen = inputValue.data(using: .utf8)?.count ?? 0
        
        var currentStr = self.asciiStringList[0]
        if dataLen == strLen {
            // 当前输入是ASCII字符
            currentStr = inputValue
        }
        
        if textModel.maxLength > 0 && currentStr.count > textModel.maxLength {
            textField.text = String(currentStr.prefix(textModel.maxLength))
            currentStr = String(currentStr.prefix(textModel.maxLength))
            
            if let handler = textModel.handler {
                handler(textField.text!)
            }
        } else {
            textField.text = currentStr
            
            if let handler = textModel.handler {
                handler(textField.text!)
            }
        }
    }

    @objc func textFieldValueChanged1() {
        guard self.textFieldList.count > 1 else {
            return
        }
        
        let textField = self.textFieldList[1]
        let textModel = self.textModelList[1]
        
        let inputValue = textField.text ?? ""
        if !ValidStr(inputValue) {
            textField.text = ""
            self.asciiStringList[1] = ""
            if let handler = textModel.handler {
                handler("")
            }
            return
        }
        
        let strLen = inputValue.count
        let dataLen = inputValue.data(using: .utf8)?.count ?? 0
        
        var currentStr = self.asciiStringList[1]
        if dataLen == strLen {
            // 当前输入是ASCII字符
            currentStr = inputValue
        }
        
        if textModel.maxLength > 0 && currentStr.count > textModel.maxLength {
            textField.text = String(currentStr.prefix(textModel.maxLength))
            currentStr = String(currentStr.prefix(textModel.maxLength))
            
            if let handler = textModel.handler {
                handler(textField.text!)
            }
        } else {
            textField.text = currentStr
            
            if let handler = textModel.handler {
                handler(textField.text!)
            }
        }
    }
    
    // MARK: - Public method
    
    /// 添加底部按钮，目前支持最多两组
    /// - Parameter action: 按钮
    func addAction(_ action:MKAlertViewAction) {
        if actionList.count >= 2 {
            return
        }
        actionList.append(action)
    }
    
    func addTextField(_ textModel: MKAlertViewTextField) {
        if textModelList.count >= 2 {
            return
        }
        textModelList.append(textModel)
    }
    
    /// 弹出窗口
    /// - Parameters:
    ///   - title: 窗口Title
    ///   - message: 窗口Message
    ///   - notify: 注册让弹窗消失的通知
    func showAlert(title: String? = nil,message: String? = nil,notify: String? = nil) {
        if (actionList.count == 0 || actionList.count > 2) {
            return
        }
        appWindow!.addSubview(self)
        if let notifyName = notify {
            NotificationCenter.default.addObserver(self, selector: #selector(dismiss), name: NSNotification.Name(rawValue: notifyName), object: nil)
        }
        
        centerView.removeAllSubViews()
        
        textFieldView.removeAllSubViews()
        
        titleLabel.text = SafeStr(title)
        centerView.addSubview(titleLabel)
        
        messageLabel.text = SafeStr(message)
        centerView.addSubview(messageLabel)
        
        centerView.addSubview(textFieldView)
        centerView.addSubview(horizontalLine)
        
        buttonList.removeAll()
        textFieldList.removeAll()
        asciiStringList.removeAll()
        
        for i in 0..<self.actionList.count {
            let action = self.actionList[i]
            let selectorName = "buttonPressed\(i)"
            let actionButton = loadButtonWithTitle(title: action.title, selector: Selector(selectorName))
            self.centerView.addSubview(actionButton)
            self.buttonList.append(actionButton)
        }

        for i in 0..<self.textModelList.count {
            let textModel = self.textModelList[i]
            let textField = loadTextFieldWithTextValue(textValue: textModel.textValue, placeHolder: textModel.placeholder, textType: textModel.textFieldType)
            textField.maxLength = UInt(textModel.maxLength)
            let selectorName = "textFieldValueChanged\(i)"
            textField.addTarget(self, action: Selector(selectorName), for: .editingChanged)
            self.textFieldView.addSubview(textField)
            self.textFieldList.append(textField)
            self.asciiStringList.append(textModel.textValue)
        }

        setupSubViews()

        if !self.textFieldList.isEmpty {
            let textField = self.textFieldList[0]
            textField.becomeFirstResponder()
        }
    }
    
    @objc func dismiss() {
        if self.superview != nil {
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Getter

    private lazy var centerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8.0
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = defaultTextColor
        label.font = MKFont(withSize: 18.0)
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = defaultTextColor
        label.font = MKFont(withSize: 14.0)
        label.numberOfLines = 0
        return label
    }()

    private lazy var textFieldView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.borderWidth = CUTTING_LINE_HEIGHT
        view.layer.borderColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1).cgColor
        view.layer.cornerRadius = 6.0
        return view
    }()

    private lazy var horizontalLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
        return view
    }()

    private lazy var actionList: [MKAlertViewAction] = {
        return [MKAlertViewAction]()
    }()

    private lazy var buttonList: [UIButton] = {
        return [UIButton]()
    }()

    private lazy var textModelList: [MKAlertViewTextField] = {
        return [MKAlertViewTextField]()
    }()

    private lazy var textFieldList: [MKTextField] = {
        return [MKTextField]()
    }()

    private lazy var asciiStringList: [String] = {
        return [String]()
    }()
}


private extension MKAlertView {
    func loadButtonWithTitle(title: String, selector: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitleColor(defaultTextColor, for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = MKFont(withSize: 18.0)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    func loadTextFieldWithTextValue(textValue: String, placeHolder: String, textType: MKTextFieldType) -> MKTextField {
        let textField = MKTextField(textType: textType)
        textField.textColor = defaultTextColor
        textField.font = MKFont(withSize: 13.0)
        textField.textAlignment = .left
        textField.placeholder = placeHolder
        textField.text = textValue
        return textField
    }
    
    func titleHeight() -> Float {
        if ValidStr(titleLabel.text) {
            return Float((MKFont(withSize: 18.0).lineHeight + 10.0))
        }
        return 0
    }
    
    func textFieldViewHeight() -> Float {
        if textFieldList.count == 0 {
            //没有输入框
            return 0
        }
        return (Float(textFieldList.count) * 30.0)
    }
    
    func messageLabelHeight() -> Float {
        let messageWidth = screenWidth - 2 * (50.0 + 10.0)
        let messageSize = stringSize(string: messageLabel.text!, font: messageLabel.font, maxSize: CGSize(width: messageWidth, height: CGFloat.greatestFiniteMagnitude))
        return Float(messageSize.height)
    }
}

private extension MKAlertView {
    func setupSubViews() {
        let messageHeight: Float = messageLabelHeight()
        let titleHeight: Float = titleHeight()
        let textViewHeight: Float = textFieldViewHeight()
        
        let centerViewHeight: Float = (25.0 + messageHeight + titleHeight + textViewHeight + Float(CUTTING_LINE_HEIGHT) + 45.0 + 20.0)
        
        let offset_centerView = (textFieldList.count > 0 ? -90 : 0)
        
        centerView.snp.remakeConstraints { make in
            make.left.equalTo(50.0)
            make.right.equalTo(-50.0)
            make.centerY.equalTo(self.snp.centerY).offset(offset_centerView)
            make.height.equalTo(centerViewHeight)
        }
        
        titleLabel.snp.remakeConstraints { make in
            make.left.equalTo(5.0)
            make.right.equalTo(-5.0)
            make.top.equalTo(25.0)
            if ValidStr(titleLabel.text){
                //有标题
                make.height.equalTo(MKFont(withSize: 18).lineHeight)
            }else {
                //无标题
                make.height.equalTo(0)
            }
        }
        
        messageLabel.snp.remakeConstraints { make in
            make.left.equalTo(10.0)
            make.right.equalTo(-10.0)
            if ValidStr(titleLabel.text) {
                //有标题
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
            }else {
                //无标题
                make.top.equalTo(25.0)
            }
            make.height.equalTo(messageHeight)
        }
        
        textFieldView.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(messageLabel.snp.bottom).offset(10)
            make.height.equalTo(textViewHeight)
        }
        
        if textFieldList.count == 1 {
            //一个输入框
            let textField: MKTextField = textFieldList[0];
            textField.snp.remakeConstraints { make in
                make.edges.equalTo(textField.superview!)
            }
            horizontalLine.snp.remakeConstraints { make in
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.top.equalTo(textFieldView.snp.bottom).offset(10)
                make.height.equalTo(CUTTING_LINE_HEIGHT)
            }
        }else if textFieldList.count == 2 {
            //两个输入框
            let textField1: MKTextField = textFieldList[0];
            textField1.snp.remakeConstraints { make in
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.top.equalTo(0)
                make.height.equalTo(30)
            }
            let lineView = UIView()
            lineView.backgroundColor = rgbColor(53, 53, 53)
            textFieldView.addSubview(lineView)
            lineView.snp.remakeConstraints { make in
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.top.equalTo(textField1.snp.bottom)
                make.height.equalTo(CUTTING_LINE_HEIGHT)
            }
            let textField2: MKTextField = textFieldList[1];
            textField2.snp.remakeConstraints { make in
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.top.equalTo(lineView.snp.bottom)
                make.height.equalTo(30)
            }
            horizontalLine.snp.remakeConstraints { make in
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.top.equalTo(textFieldView.snp.bottom).offset(10)
                make.height.equalTo(CUTTING_LINE_HEIGHT)
            }
        }else {
            //没有输入框
            horizontalLine.snp.remakeConstraints { make in
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.top.equalTo(messageLabel.snp.bottom).offset(20)
                make.height.equalTo(CUTTING_LINE_HEIGHT)
            }
        }
        
        if buttonList.count == 1 {
            //一个按钮
            let button = buttonList[0];
            button.snp.remakeConstraints { make in
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.top.equalTo(horizontalLine.snp.bottom)
                make.bottom.equalTo(0)
            }
            return
        }
        
        if buttonList.count == 2 {
            //两个按钮
            let verticalLine = UIView()
            verticalLine.backgroundColor = rgbColor(53, 53, 53)
            centerView.addSubview(verticalLine)
            verticalLine.snp.remakeConstraints { make in
                make.centerX.equalTo(centerView.snp.centerX)
                make.width.equalTo(CUTTING_LINE_HEIGHT)
                make.top.equalTo(horizontalLine.snp.bottom)
                make.bottom.equalTo(0)
            }
            let button1 = buttonList[0]
            let button2 = buttonList[1]
            button1.snp.remakeConstraints { make in
                make.left.equalTo(0)
                make.right.equalTo(verticalLine.snp.left)
                make.top.equalTo(horizontalLine.snp.bottom)
                make.bottom.equalTo(0)
            }
            button2.snp.remakeConstraints { make in
                make.left.equalTo(verticalLine.snp.right)
                make.right.equalTo(0)
                make.top.equalTo(horizontalLine.snp.bottom)
                make.bottom.equalTo(0)
            }
        }
    }
}
