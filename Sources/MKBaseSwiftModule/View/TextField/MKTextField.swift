import UIKit

enum MKTextFieldType {
    case normal
    case realNumberOnly
    case letterOnly
    case realNumberOrLetter
    case hexCharOnly
    case uuidMode
}

class MKTextField: UITextField {
    var maxLength: UInt = 0
    var textType: MKTextFieldType {
        get {
            return currentTextType
        }
        set {
            currentTextType = newValue
            keyboardType = getKeyboardType()
//            text = ""
        }
    }
    var textChangedBlock: ((String) -> Void)?

    private var currentTextType: MKTextFieldType = .normal
    private var inputLen: UInt = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    convenience init(textType: MKTextFieldType) {
        self.init(frame: .zero)
        self.textType = textType
        self.currentTextType = textType
        self.keyboardType = getKeyboardType()
    }

    private func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditingNotification(_:)), name: UITextField.textDidBeginEditingNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldChanged(_:)), name: UITextField.textDidChangeNotification, object: self)
        autocorrectionType = .no
        autocapitalizationType = .none
        textColor = .black
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.cut(_:)) || action == #selector(UIResponderStandardEditActions.select(_:)) || action == #selector(UIResponderStandardEditActions.selectAll(_:)) {
            return true
        }
        return false
    }

    override func deleteBackward() {
        super.deleteBackward()
        // Implement this method if needed
    }

    override func drawPlaceholder(in rect: CGRect) {
        guard let placeholder = self.placeholder else { return }
        let placeholderSize = placeholder.size(withAttributes: [NSAttributedString.Key.font: self.font as Any])
        let drawRect = CGRect(x: 0, y: (rect.size.height - placeholderSize.height)/2, width: rect.size.width, height: rect.size.height)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1), .font: self.font as Any]
        placeholder.draw(in: drawRect, withAttributes: attributes)
    }

    @objc private func textFieldDidBeginEditingNotification(_ notification: Notification) {
        // Implement this method if needed
    }

    @objc private func textFieldChanged(_ notification: Notification) {
        let tempString = self.text

        if !ValidStr(tempString) {
            self.text = ""
            textChangedBlock?("")
            return
        }

        if maxLength > 0 && tempString!.count > Int(maxLength) && currentTextType != .uuidMode {
            self.text = tempString![0..<Int(maxLength)]
            textChangedBlock?(self.text!)
            return
        }

        let inputString = tempString![tempString!.count - 1]
        let legal = validation(inputString)
        self.text = legal ? tempString : tempString![0..<(tempString!.count - 1)]

        if currentTextType != .uuidMode {
            textChangedBlock?(self.text!)
            return
        }

        self.text = self.text!.uppercased()

        if self.text!.count > inputLen {
            if self.text!.count == 9 || self.text!.count == 14
                || self.text!.count == 19 || self.text!.count == 24 {
                //输入
                if var str = self.text {
                    str.insert("-", at: str.index(str.endIndex, offsetBy: -1))
                    self.text = str
                    textChangedBlock?(self.text!)
                }
            }

            if self.text!.count >= 36 {
                //输入完成
                self.text = String(self.text!.prefix(36))
                textChangedBlock?(self.text!)
            }

            inputLen = UInt(self.text!.count)
            textChangedBlock?(self.text!)
        } else if self.text!.count < inputLen {
            if self.text!.count == 9 || self.text!.count == 14
                || self.text!.count == 19 || self.text!.count == 24 {
                self.text = String(self.text!.dropLast())
                textChangedBlock?(self.text!)
            }
            
            inputLen = UInt(self.text!.count)
            textChangedBlock?(self.text!)
        }
    }

    private func getKeyboardType() -> UIKeyboardType {
        switch textType {
        case .normal, .uuidMode:
            return .default
        case .realNumberOnly:
            return .decimalPad
        case .letterOnly, .realNumberOrLetter, .hexCharOnly:
            return .asciiCapable
        }
    }

    private func validation(_ input: String) -> Bool {
        if !ValidStr(input) {
            return false
        }
        switch textType {
        case .normal:
            return true
        case .realNumberOnly:
            return regularExpressions(string: input, regex: isRealNumbers)
        case .letterOnly:
            return regularExpressions(string: input, regex: isLetter)
        case .realNumberOrLetter:
            return regularExpressions(string: input, regex: isLetterOrRealNumbers)
        case .hexCharOnly:
            return regularExpressions(string: input, regex: isHexadecimal)
        case .uuidMode:
            return regularExpressions(string: input, regex: isHexadecimal)
        }
    }
}
