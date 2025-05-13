//
//  MKPickerView.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/3/11.
//

import UIKit

class MKPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    typealias RowPickBlock = (Int) -> Void
    
    private let animationDuration: TimeInterval = 0.3
    private let kDatePickerH: CGFloat = 270
    private let pickViewRowHeight: CGFloat = 30
    
    private var rowPickBlock: RowPickBlock?
    private var currentRow: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = UIScreen.main.bounds
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        addSubview(bottomView)
        bottomView.addSubview(pickView)
        addTapAction()
        NotificationCenter.default.addObserver(self, selector: #selector(dismiss), name: NSNotification.Name("mk_dismissPickView"), object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("MKDeviceSettingPickView销毁")
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickViewRowHeight
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSMutableAttributedString(string: dataList[row])
        attributedString.addAttribute(.foregroundColor, value: defaultTextColor, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.font, value: MKFont(withSize: 15.0), range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentRow = row
    }
    
    // MARK: - Event Methods
    
    @objc private func cancelButtonPressed() {
        dismiss()
    }
    
    @objc private func confirmButtonPressed() {
        if let rowPickBlock = rowPickBlock {
            rowPickBlock(currentRow)
        }
        dismiss()
    }
    
    @objc private func dismiss() {
        if superview != nil {
            removeFromSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    func showPickView(withDataList dataList: [String], selectedRow: Int, block: @escaping RowPickBlock) {
        if !dataList.isEmpty, selectedRow < dataList.count {
            appWindow?.addSubview(self)
            self.dataList = dataList
            rowPickBlock = block
            currentRow = selectedRow
            pickView.reloadAllComponents()
            pickView.selectRow(currentRow, inComponent: 0, animated: false)
            UIView.animate(withDuration: animationDuration) {
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: -self.kDatePickerH)
            }
        } else {
            print("显示pickView错误")
        }
    }
    
    // MARK: - Private Methods
    
    private func addTapAction() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        tapGestureRecognizer.numberOfTapsRequired = 1
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    // getter
    private lazy var dataList: [String] = {
        let array: [String] = []
        return array
    }()
    
    private lazy var bottomView: UIView = {
        let bottomView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: kDatePickerH))
        bottomView.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        topView.backgroundColor = .white
        bottomView.addSubview(topView)
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.frame = CGRect(x: 10, y: 10, width: 70, height: 30)
        cancelButton.backgroundColor = .clear
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        topView.addSubview(cancelButton)
        
        let confirmButton = UIButton(type: .custom)
        confirmButton.frame = CGRect(x: UIScreen.main.bounds.size.width - 80, y: 10, width: 70, height: 30)
        confirmButton.backgroundColor = .clear
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.setTitleColor(.black, for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
        topView.addSubview(confirmButton)
        return bottomView
    }()
    
    private lazy var pickView: UIPickerView = {
        let pickView = UIPickerView(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.size.width, height: kDatePickerH - 50))
        pickView.backgroundColor = .white
        pickView.delegate = self
        pickView.dataSource = self
        return pickView
    }()
}
