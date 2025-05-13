//
//  MKBaseViewController.swift
//  MKPS101SwiftProject_Example
//
//  Created by aa on 2024/2/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

import UIKit

class MKBaseViewController: UIViewController {
    // 标题label
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 60.0, y: 7.0, width: UIScreen.main.bounds.size.width - 120.0, height: 30.0))
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        label.tintColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        titleLabel = label
        return label
    }()
    // 左按钮
    private(set) lazy var leftButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 10.0, y: 7.0, width: 30.0, height: 30.0)
        button.addTarget(self, action: #selector(leftButtonMethod), for: .touchUpInside)
        button.contentMode = .center
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "mk_back_button_white.png"), for: .normal)
        return button
    }()
    // 右按钮
    private(set) lazy var rightButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: UIScreen.main.bounds.size.width - 40.0, y: 7.0, width: 30.0, height: 30.0)
        button.addTarget(self, action: #selector(rightButtonMethod), for: .touchUpInside)
        button.contentMode = .center
        button.imageView?.contentMode = .scaleAspectFit
        rightButton = button
        return button
    }()
        
    // controlle是否是 经过 presentViewController:animated:completion: 推出来，默认为NO
    var isPrensent: Bool = false
    
    var custom_naviBarColor: UIColor? {
        get {
            
            return navigationBarColor();
        }
        set {
            setupNavigationBarColor(newValue ?? navbarColor)
        }
    }
    
    func defaultTitle(_ title:String) {
        titleLabel.text = self.title ?? title
    }
    
    // 设置导航栏背景颜色
    func setNavigationBarImage(_ image: UIImage) {
        self.edgesForExtendedLayout = []
        if let navigationBar = self.navigationController?.navigationBar {
            let image1 = image.resizableImage(withCapInsets: UIEdgeInsets(top: 2, left: 1, bottom: 2, right: 1))
            navigationBar.setBackgroundImage(image1, for: .default)
        }
    }
    
    // 左按钮方法
    @objc func leftButtonMethod() {
        if self.isPrensent {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 右按钮方法
    @objc func rightButtonMethod() {
        
    }
    
    // 判断当前显示的是否是本控制器
    class func isCurrentViewControllerVisible(_ viewController: UIViewController) -> Bool {
        return viewController.isViewLoaded && viewController.view.window != nil
    }
    
    func popToViewController(withClassName className: String) {
        var popController: UIViewController? = nil
        if let viewControllers = self.navigationController?.viewControllers {
            for viewController in viewControllers {
                if NSStringFromClass(type(of: viewController)) == ("MKPSSwiftProject.\(className)") {
                    popController = viewController
                    break
                }
            }
        }
        
        if let popController = popController {
            self.navigationController?.popToViewController(popController, animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func isRootViewController() -> Bool {
        return self == self.navigationController?.viewControllers.first
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationParams()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension MKBaseViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if isRootViewController() {
            return false
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }
}

private extension MKBaseViewController {
    func setupNavigationParams() {
        view.backgroundColor = .white;
        setupNavigationBarColor(navbarColor)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        navigationItem.titleView = titleLabel
    }
    
    func setupNavigationBarColor(_ color: UIColor) {
        guard let navigationBar = navigationController?.navigationBar else { return }
        if #available(iOS 15, *) {
            let app = UINavigationBarAppearance.init()
            app.configureWithOpaqueBackground()  // 重置背景和阴影颜色
//            app.titleTextAttributes = [
//                NSAttributedString.Key.font: MKFont(withSize: 18),
//                NSAttributedString.Key.foregroundColor: UIColor.white
//            ]
            app.backgroundColor = color  // 设置导航栏背景色
            app.shadowImage = UIImage()  // 设置导航栏下边界分割线透明
            navigationBar.scrollEdgeAppearance = app  // 带scroll滑动的页面
            navigationBar.standardAppearance = app // 常规页面
        }else{
            // 设置导航栏背景色
            navigationBar.barTintColor = color
            // 设置导航条上的标题
            // navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:.white]
            // 取消半透明效果
            navigationBar.isTranslucent  = false

            _ = UIBarButtonItem.appearance()
//            naviItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:.black,NSAttributedString.Key.font:MKFont(withSize: 18)], for: UIControl.State())
            // 设置导航栏下边界分割线透明
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
        }
    }
    
    func navigationBarColor() -> UIColor? {
        guard let navigationBar = navigationController?.navigationBar else { return nil }
        if #available(iOS 15, *) {
            guard let color = navigationBar.standardAppearance.backgroundColor else { return navigationBar.scrollEdgeAppearance?.backgroundColor }
            return color;
        }else{
            return navigationBar.barTintColor;
        }
    }
}
