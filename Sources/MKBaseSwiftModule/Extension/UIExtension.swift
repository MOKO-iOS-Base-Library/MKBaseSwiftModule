//
//  UIExtension.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/3/10.
//

import UIKit

import ObjectiveC

import SnapKit

import Toast

// MARK: - 常规UI操作
extension UIView {
    func removeAllSubViews() {
        while (self.subviews.count > 0) {
            self.subviews.last?.removeFromSuperview()
        }
    }
}

// MARK: - 封装的Loading框和Toast
extension UIView {
    func showToast(message: String) {
        ToastManager.shared.duration = 0.8
        ToastManager.shared.position = .center
        self.makeToast(message)
    }
    
    /// 展示loading框(主线程中刷新UI)
    func showLoading(_ message: String = "") {
        // 若当前视图已加载CCLoadingView,则先移除后,再添加;
        if let lastView = subviews.last as? CCLoadingView { lastView.removeFromSuperview() }
        
        let loadingView = CCLoadingView(toast: message)
        addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    /// 隐藏loading框(主线程中刷新UI)
    func hideLoading() {
        for item in subviews {
            if item.isKind(of: CCLoadingView.self) {
                item.removeFromSuperview()
            }
        }
    }
}

// MARK: - 给View添加单击手势
extension UIView {
    func addTapAction(target: Any, selector: Selector) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: target, action: selector)
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer)
    }
}

// MARK: - TextField
extension UITextField {
    static func swizzleMethods() {
        let originalSelectors: [Selector] = [
            #selector(cut(_:)),
            #selector(copy(_:)),
            #selector(select(_:)),
            #selector(selectAll(_:)),
            #selector(paste(_:)),
            #selector(delete(_:)),
        ]
        
        for selector in originalSelectors {
            guard let originalMethod = class_getInstanceMethod(self, selector),
                  let swizzledMethod = class_getInstanceMethod(self, #selector(mk_disabled(_:))) else {
                continue
            }
            
            let didAddMethod = class_addMethod(self, selector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, #selector(mk_disabled(_:)), method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }
    
    @objc private func mk_disabled(_ sender: Any?) {
        // 禁止操作的实现
    }
}

// MARK: -

final class CCLoadingView: UIView {
    /// 懒加载,提示label
    private lazy var messageLabel: UILabel = {
        let l = UILabel()
        l.textColor = defaultTextColor
        l.font = MKFont(withSize: 17.0)
        l.textAlignment = .center
       return l
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 反初始化器
    deinit { print("CCLoadingView deinit~") }
    
    // MARK: - 初始化器
    init(toast: String) {
        super.init(frame: .zero)
        
        let contentView = UIView()
        contentView.layer.cornerRadius = 5
        contentView.backgroundColor = rgbaColor(0, 0, 0, 0.1)
        addSubview(contentView)
        
        let activity = UIActivityIndicatorView(style: .large)
        contentView.addSubview(activity)
        
        if !toast.isEmpty {
            // 中间内容视图
            contentView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 120, height: 100))
            }
            
            // 加载转圈视图
            activity.snp.makeConstraints { (make) in
                make.top.equalTo(16)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 38, height: 38))
            }
            
            // 文字提示视图
            messageLabel.text = toast
            addSubview(messageLabel)
            messageLabel.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(contentView.snp.bottom).offset(-10.0)
                make.size.equalTo(CGSize(width: 120, height: 36))
            }
        }else {
            // 中间内容视图
            contentView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 100, height: 100))
            }
            
            // 加载转圈视图
            activity.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
        }
        activity.startAnimating()
    }
}
