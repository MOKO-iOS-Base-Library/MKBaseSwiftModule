//
//  MKSwiftBaseViewController.swift
//  MKBaseSwiftModule_Example
//
//  Created by aa on 2024/2/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class MKSwiftBaseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - UI Components
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) lazy var leftButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(leftButtonMethod), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private(set) lazy var rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(rightButtonMethod), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    
    var isPresented: Bool = false
    var defaultTitle: String? {
        didSet {
            titleLabel.text = self.title ?? defaultTitle
        }
    }
    
    var custom_naviBarColor: UIColor? = .systemBlue {
        didSet {
            updateNavigationBarAppearance()
        }
    }
    
    var isRootViewController: Bool {
        return navigationController?.viewControllers.first == self
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationItems()
    }
    
    private func setupNavigationItems() {
        // Title View
        let titleContainer = UIView()
        titleContainer.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width - 120)
        ])
        
        navigationItem.titleView = titleContainer
        
        // Left Button
        let leftButtonContainer = UIView()
        leftButtonContainer.addSubview(leftButton)
        
        NSLayoutConstraint.activate([
            leftButton.leadingAnchor.constraint(equalTo: leftButtonContainer.leadingAnchor),
            leftButton.topAnchor.constraint(equalTo: leftButtonContainer.topAnchor),
            leftButton.bottomAnchor.constraint(equalTo: leftButtonContainer.bottomAnchor),
            leftButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButtonContainer)
        
        // Right Button
        let rightButtonContainer = UIView()
        rightButtonContainer.addSubview(rightButton)
        
        NSLayoutConstraint.activate([
            rightButton.trailingAnchor.constraint(equalTo: rightButtonContainer.trailingAnchor),
            rightButton.topAnchor.constraint(equalTo: rightButtonContainer.topAnchor),
            rightButton.bottomAnchor.constraint(equalTo: rightButtonContainer.bottomAnchor),
            rightButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButtonContainer)
    }
    
    private func setupNavigationBar() {
        updateNavigationBarAppearance()
    }
    
    private func updateNavigationBarAppearance() {
        guard let navBar = navigationController?.navigationBar else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = custom_naviBarColor
        
        // 根据背景色自动调整文字和图标颜色
        let isDarkColor = custom_naviBarColor?.isDark ?? true
        let textColor: UIColor = isDarkColor ? .white : .black
        
        appearance.titleTextAttributes = [.foregroundColor: textColor]
        navBar.tintColor = textColor
        
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        
        // 设置状态栏样式
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - Actions
    
    @objc func leftButtonMethod() {
        if isPresented {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func rightButtonMethod() {
        // 子类重写实现
    }
    
    // MARK: - Public Methods
    
    func setNavigationBarImage(_ image: UIImage) {
        edgesForExtendedLayout = []
        let resizedImage = image.resizableImage(withCapInsets: UIEdgeInsets(top: 2, left: 1, bottom: 2, right: 1))
        navigationController?.navigationBar.setBackgroundImage(resizedImage, for: .default)
    }
    
    func popToViewController(withClassName className: String) {
        guard let navController = navigationController else { return }
        
        if let targetVC = navController.viewControllers.first(where: { String(describing: type(of: $0)) == className }) {
            navController.popToViewController(targetVC, animated: true)
        } else {
            navController.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !isRootViewController
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }
    
    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return custom_naviBarColor?.isDark == true ? .lightContent : .darkContent
    }
}

// MARK: - UIColor Extension

extension UIColor {
    var isDark: Bool {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // 计算亮度 (0-1)
        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return luminance < 0.5
    }
    
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        var hexColor = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexColor.hasPrefix("#") {
            hexColor.remove(at: hexColor.startIndex)
        }
        
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        guard scanner.scanHexInt64(&hexNumber) else { return nil }
        
        switch hexColor.count {
        case 6: // RGB (24-bit)
            r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
            b = CGFloat(hexNumber & 0x0000FF) / 255
            a = 1.0
        case 8: // ARGB (32-bit)
            r = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000FF) / 255
        default:
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
