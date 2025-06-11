//
//  MKSwiftBaseViewController.swift
//  MKBaseSwiftModule_Example
//
//  Created by aa on 2024/2/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

open class MKSwiftBaseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    open var isPresented: Bool = false
    open var defaultTitle: String? {
        didSet {
            titleLabel.text = self.title ?? defaultTitle
        }
    }
    
    open var custom_naviBarColor: UIColor? = .systemBlue {
        didSet {
            updateNavigationBarAppearance()
        }
    }
    
    open var isRootViewController: Bool {
        return navigationController?.viewControllers.first == self
    }
    
    // MARK: - UI Components
    
    open private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    
    open private(set) lazy var leftButton: UIButton = {
        let button = UIButton(type: .system)
        if let image = moduleIcon(name: "mk_swift_back_button_white") {
            button.setImage(image, for: .normal)
        } else {
            button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        }
        button.tintColor = .white
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(leftButtonMethod), for: .touchUpInside)
        return button
    }()
    
    open private(set) lazy var rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .highlighted)
        button.addTarget(self, action: #selector(rightButtonMethod), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    // MARK: - Actions
    
    @objc open func leftButtonMethod() {
        if isPresented {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc open func rightButtonMethod() {
        // Subclasses should override
    }
    
    // MARK: - Public Methods
    
    open func setNavigationBarImage(_ image: UIImage) {
        edgesForExtendedLayout = []
        let resizedImage = image.resizableImage(withCapInsets: UIEdgeInsets(top: 2, left: 1, bottom: 2, right: 1))
        navigationController?.navigationBar.setBackgroundImage(resizedImage, for: .default)
    }
    
    open class func isCurrentViewControllerVisible(_ viewController: UIViewController) -> Bool {
        return viewController.isViewLoaded && viewController.view.window != nil
    }
    
    open func popToViewController(withClassName className: String) {
        guard let navController = navigationController else { return }
        
        if let targetVC = navController.viewControllers.first(where: { String(describing: type(of: $0)) == className }) {
            navController.popToViewController(targetVC, animated: true)
        } else {
            navController.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !isRootViewController
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationItems()
    }
    
    private func setupNavigationItems() {
        // Left Button
        let leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        // Right Button
        let rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        // Title View
        navigationItem.titleView = titleLabel
    }
    
    private func setupNavigationBar() {
        updateNavigationBarAppearance()
    }
    
    private func updateNavigationBarAppearance() {
        guard let navBar = navigationController?.navigationBar else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = custom_naviBarColor
        
        // Set title color based on background darkness
        let isDarkColor = custom_naviBarColor?.isDark ?? true
        let textColor: UIColor = isDarkColor ? .white : .black
        
        appearance.titleTextAttributes = [.foregroundColor: textColor]
        navBar.tintColor = textColor
        
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        
        setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: - UIColor Extension

extension UIColor {
    var isDark: Bool {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate luminance (0-1)
        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return luminance < 0.5
    }
}
