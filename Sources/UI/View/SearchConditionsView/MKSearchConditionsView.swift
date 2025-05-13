//
//  MKSearchConditionsView.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/3/11.
//

import UIKit

import SnapKit

class MKSearchConditionsView: UIView {
    
    private let offset_X: CGFloat = 10.0
    private let backViewHeight: CGFloat = 200.0
    private let signalIconWidth: CGFloat = 17.0
    private let signalIconHeight: CGFloat = 15.0
    
    private var searchBlock: ((String, Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = UIScreen.main.bounds
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        
        addSubview(backView)
        backView.addSubview(textField)
        backView.addSubview(signalIcon)
        backView.addSubview(rssiLabel)
        backView.addSubview(slider)
        backView.addSubview(rssiValueLabel)
        backView.addSubview(doneButton)
        
        addTapAction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTapAction() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        singleTap.numberOfTouchesRequired = 1
        singleTap.numberOfTapsRequired = 1
        singleTap.delegate = self
        addGestureRecognizer(singleTap)
    }
    
    @objc func dismiss() {
        textField.resignFirstResponder()
        UIView.animate(withDuration: 0.25) {
            self.backView.transform = CGAffineTransform(translationX: 0, y: -self.backViewHeight)
        } completion: { finished in
            if self.superview != nil {
                self.removeFromSuperview()
            }
        }
    }
    
    @objc func doneButtonPressed() {
        textField.resignFirstResponder()
        UIView.animate(withDuration: 0.25) {
            self.backView.transform = CGAffineTransform(translationX: 0, y: -self.backViewHeight)
        } completion: { finished in
            let value = String(format: "%.f", self.slider.value)
            self.searchBlock?(self.textField.text ?? "", Int(value) ?? 0)
            if self.superview != nil {
                self.removeFromSuperview()
            }
        }
    }
    
    @objc func rssiValueChanged() {
        rssiValueLabel.text = String(format: "%.fdBm", slider.value)
    }
    
    static func showSearchKey(_ searchKey: String?, rssi: Int, minRssi: Int, searchBlock: @escaping (String, Int) -> Void) {
        let view = MKSearchConditionsView(frame: .zero)
        view.showViewWithText(searchKey, rssiValue: rssi, minSearchRssi: minRssi, searchBlock: searchBlock)
    }
    
    func showViewWithText(_ searchKey: String?, rssiValue: Int, minSearchRssi: Int, searchBlock: @escaping (String, Int) -> Void) {
        appWindow?.addSubview(self)
        self.searchBlock = searchBlock
        if let searchKey = searchKey {
            textField.text = searchKey
        }
        slider.minimumValue = Float(minSearchRssi)
        slider.value = Float(rssiValue)
        rssiValueLabel.text = "\(rssiValue)dBm"
        UIView.animate(withDuration: 0.25) {
            self.backView.transform = CGAffineTransform(translationX: 0, y: self.backViewHeight + topBarHeight)
        } completion: { finished in
            self.textField.becomeFirstResponder()
        }
    }
    
    // MARK: getter
    
    private lazy var backView: UIView = {
        let view = UIView(frame: CGRect(x: offset_X, y: -backViewHeight, width: screenWidth - 2 * offset_X, height: backViewHeight))
        view.backgroundColor = .white
        return view
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField(frame: CGRect(x: offset_X, y: offset_X, width: screenWidth - 4 * offset_X, height: 30))
        textField.borderStyle = .none
        textField.font = MKFont(withSize: 13.0)
        textField.textColor = defaultTextColor
        textField.placeholder = "Device name or mac address"
        textField.clearButtonMode = .whileEditing
        textField.layer.masksToBounds = true
        textField.layer.borderColor = navbarColor.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 4
        return textField
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: offset_X, y: backViewHeight - 45.0 - offset_X, width: screenWidth - 4 * offset_X, height: 45.0)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = MKFont(withSize: 16.0)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = navbarColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var signalIcon: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: offset_X, y: offset_X * 3 + 30.0, width: signalIconWidth, height: signalIconHeight))
        imageView.image = UIImage(named: "mk_wifisignalIcon.png")
        return imageView
    }()
    
    lazy var rssiLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: offset_X + signalIconWidth + 5, y: offset_X * 3 + 30, width: 35, height: signalIconHeight))
        label.text = "RSSI"
        label.font = MKFont(withSize: 12.0)
        label.textColor = defaultTextColor
        label.textAlignment = .left
        return label
    }()
    
    lazy var slider: UISlider = {
        let slider = UISlider(frame: CGRect(x: offset_X + signalIconWidth + 10 + 35, y: offset_X * 3 + 30, width: screenWidth - (offset_X + signalIconWidth + 10 + 35) - 3 * offset_X - 5 - 55, height: signalIconHeight))
        slider.minimumValue = -100
        slider.maximumValue = -0
        slider.value = -100
        slider.addTarget(self, action: #selector(rssiValueChanged), for: .valueChanged)
        return slider
    }()
    
    lazy var rssiValueLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: screenWidth - 2 * offset_X - 55, y: offset_X * 3 + 30, width: 55, height: signalIconHeight))
        label.font = MKFont(withSize: 12.0)
        label.textColor = defaultTextColor
        label.textAlignment = .left
        label.text = "-100dBm"
        return label
    }()
}

extension MKSearchConditionsView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: backView) == true {
            return false
        }
        return true
    }
}
