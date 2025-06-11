//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/5/30.
//

import UIKit

public extension UIButton {
    /// Time interval between button taps to prevent multiple rapid taps
    var acceptEventInterval: TimeInterval {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.acceptEventInterval) as? TimeInterval ?? 0
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.acceptEventInterval,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    /// Starts a countdown timer on the button
    /// - Parameter seconds: The duration of the countdown in seconds
    func startCountdown(_ seconds: Int) {
        let originalTitle = title(for: .normal)
        let originalImage = backgroundImage(for: .normal)
        let titleColor = titleColor(for: .normal)
        
        var timeout = seconds
        
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.schedule(deadline: .now(), repeating: 1.0)
        timer.setEventHandler { [weak self] in
            guard let self = self else {
                timer.cancel()
                return
            }
            
            if timeout <= 0 {
                timer.cancel()
                DispatchQueue.main.async {
                    self.isUserInteractionEnabled = true
                    self.setTitle(originalTitle, for: .normal)
                    self.setBackgroundImage(originalImage, for: .normal)
                    self.backgroundColor = .clear
                    self.setTitleColor(titleColor, for: .normal)
                }
            } else {
                DispatchQueue.main.async {
                    self.isUserInteractionEnabled = false
                    self.titleLabel?.lineBreakMode = .byWordWrapping
                    self.contentHorizontalAlignment = .center
                    self.setTitle("\(timeout)秒", for: .normal)
                    self.setTitleColor(Color.rgb(51, 61, 81), for: .normal)
                    self.setBackgroundImage(nil, for: .normal)
                    self.backgroundColor = Color.rgb(239, 239, 246)
                }
                timeout -= 1
            }
        }
        timer.resume()
    }
    
    /// Enables the button tap interval functionality
    @objc public static func enableButtonTapInterval() {
        swizzleSendAction()
    }
}

// MARK: - Private Implementation
private extension UIButton {
    private enum AssociatedKeys {
        @MainActor static var acceptEventInterval: UInt8 = 0
        @MainActor static var acceptEventTime: UInt8 = 0
    }
    
    private var acceptEventTime: TimeInterval {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.acceptEventTime) as? TimeInterval ?? 0
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.acceptEventTime,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    private static func swizzleSendAction() {
        let originalSelector = #selector(UIButton.sendAction(_:to:for:))
        let swizzledSelector = #selector(UIButton.mk_sendAction(_:to:for:))
        
        guard let originalMethod = class_getInstanceMethod(self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else {
            return
        }
        
        let didAddMethod = class_addMethod(
            self,
            originalSelector,
            method_getImplementation(swizzledMethod),
            method_getTypeEncoding(swizzledMethod)
        )
        
        if didAddMethod {
            class_replaceMethod(
                self,
                swizzledSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod)
            )
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    @objc private func mk_sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        guard String(describing: type(of: self)) == "UIButton" else {
            mk_sendAction(action, to: target, for: event)
            return
        }
        
        let interval = acceptEventInterval > 0 ? acceptEventInterval : 0.001
        let currentTime = Date().timeIntervalSince1970
        
        var spaceTime = currentTime - acceptEventTime
        if spaceTime < 0 {
            spaceTime = acceptEventTime - currentTime
        }
        
        if spaceTime < interval {
            return
        }
        
        if acceptEventInterval > 0 {
            acceptEventTime = currentTime
        }
        
        mk_sendAction(action, to: target, for: event)
    }
}
