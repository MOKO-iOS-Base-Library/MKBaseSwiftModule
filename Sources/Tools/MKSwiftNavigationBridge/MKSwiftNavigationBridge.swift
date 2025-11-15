//
//  MKSwiftNavigationBridge.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/11/15.
//

import UIKit
import SwiftUI

/// 混合架构导航桥接器
/// 支持 SwiftUI 与 UIKit 之间的无缝导航
@MainActor
public final class MKSwiftNavigationBridge: NSObject {
    
    // MARK: - Singleton
    public static let shared = MKSwiftNavigationBridge()
    private override init() {
        super.init()
        setupNotifications()
    }
    
    // MARK: - Properties
    private weak var currentNavigationController: UINavigationController?
    private var navigationStack: [UINavigationController] = []
    
    /// 导航配置
    public struct NavigationConfig: Sendable {
        public var animationEnabled: Bool = true
        public var modalPresentationStyle: UIModalPresentationStyle = .fullScreen
        public var shouldSetCurrentNavControllerAutomatically: Bool = true
        public var enableGestureBack: Bool = true
        
        public static let `default` = NavigationConfig()
    }
    
    public var config: NavigationConfig = .default
    
    // MARK: - Public API
    
    // MARK: SwiftUI -> UIKit 导航
    
    /// 从 SwiftUI 推送到 UIKit 页面
    /// - Parameters:
    ///   - viewController: 目标 UIKit 视图控制器
    ///   - animated: 是否动画
    public func pushToUIKit(_ viewController: UIViewController, animated: Bool? = nil) {
        let shouldAnimate = animated ?? config.animationEnabled
        performPushToUIKit(viewController, animated: shouldAnimate)
    }
    
    /// 从 SwiftUI 模态呈现 UIKit 页面
    /// - Parameters:
    ///   - viewController: 目标 UIKit 视图控制器
    ///   - completion: 完成回调
    public func presentUIKit(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        performPresentUIKit(viewController, completion: completion)
    }
    
    // MARK: SwiftUI -> SwiftUI 导航
    
    /// 从 SwiftUI 推送到另一个 SwiftUI 页面
    /// - Parameters:
    ///   - swiftUIView: 目标 SwiftUI 视图
    ///   - animated: 是否动画
    public func pushToSwiftUI<Content: View>(_ swiftUIView: Content, animated: Bool? = nil) {
        let hostingController = createHostingController(swiftUIView)
        pushToUIKit(hostingController, animated: animated)
    }
    
    /// 从 SwiftUI 模态呈现另一个 SwiftUI 页面
    /// - Parameters:
    ///   - swiftUIView: 目标 SwiftUI 视图
    ///   - completion: 完成回调
    public func presentSwiftUI<Content: View>(_ swiftUIView: Content, completion: (() -> Void)? = nil) {
        let hostingController = createHostingController(swiftUIView)
        presentUIKit(hostingController, completion: completion)
    }
    
    // MARK: UIKit -> SwiftUI 导航
    
    /// 从 UIKit 推送到 SwiftUI 页面
    /// - Parameters:
    ///   - swiftUIView: 目标 SwiftUI 视图
    ///   - navigationController: 源导航控制器
    ///   - animated: 是否动画
    public static func pushSwiftUIFromUIKit<Content: View>(
        _ swiftUIView: Content,
        from navigationController: UINavigationController?,
        animated: Bool = true
    ) {
        let hostingController = UIHostingController(rootView: swiftUIView)
        navigationController?.pushViewController(hostingController, animated: animated)
        
        if shared.config.shouldSetCurrentNavControllerAutomatically {
            shared.currentNavigationController = navigationController
            shared.enableGestureRecognizerIfNeeded()
        }
    }
    
    /// 从 UIKit 模态呈现 SwiftUI 页面
    /// - Parameters:
    ///   - swiftUIView: 目标 SwiftUI 视图
    ///   - presentingController: 源视图控制器
    ///   - completion: 完成回调
    public static func presentSwiftUIFromUIKit<Content: View>(
        _ swiftUIView: Content,
        from presentingController: UIViewController,
        completion: (() -> Void)? = nil
    ) {
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.modalPresentationStyle = shared.config.modalPresentationStyle
        presentingController.present(hostingController, animated: true, completion: completion)
    }
    
    // MARK: 导航控制器管理
    
    /// 设置当前导航控制器
    /// - Parameter navigationController: 当前活跃的导航控制器
    public func setCurrentNavigationController(_ navigationController: UINavigationController?) {
        currentNavigationController = navigationController
        if let navController = navigationController {
            addToNavigationStack(navController)
            enableGestureRecognizerIfNeeded()
        }
    }
    
    /// 清除当前导航控制器引用
    public func clearCurrentNavigationController() {
        currentNavigationController = nil
    }
    
    /// 刷新导航上下文
    public func refreshNavigationContext() {
        enableGestureRecognizerIfNeeded()
    }
    
    // MARK: 导航操作
    
    /// 返回上一页
    /// - Parameter animated: 是否动画
    public func popViewController(animated: Bool? = nil) {
        let shouldAnimate = animated ?? config.animationEnabled
        currentNavigationController?.popViewController(animated: shouldAnimate)
        enableGestureRecognizerIfNeeded()
    }
    
    /// 返回到根页面
    /// - Parameter animated: 是否动画
    public func popToRootViewController(animated: Bool? = nil) {
        let shouldAnimate = animated ?? config.animationEnabled
        currentNavigationController?.popToRootViewController(animated: shouldAnimate)
        enableGestureRecognizerIfNeeded()
    }
    
    /// 关闭模态页面
    /// - Parameter animated: 是否动画
    public func dismissViewController(animated: Bool? = nil, completion: (() -> Void)? = nil) {
        let shouldAnimate = animated ?? config.animationEnabled
        findTopViewController()?.dismiss(animated: shouldAnimate, completion: completion)
    }
    
    // MARK: - Private Methods
    
    private func performPushToUIKit(_ viewController: UIViewController, animated: Bool) {
        if let navController = currentNavigationController {
            navController.pushViewController(viewController, animated: animated)
            enableGestureRecognizerIfNeeded()
        } else {
            fallbackPushViewController(viewController, animated: animated)
        }
    }
    
    private func performPresentUIKit(_ viewController: UIViewController, completion: (() -> Void)?) {
        viewController.modalPresentationStyle = config.modalPresentationStyle
        findTopViewController()?.present(viewController, animated: true, completion: completion)
    }
    
    private func fallbackPushViewController(_ viewController: UIViewController, animated: Bool) {
        guard let topViewController = findTopViewController() else {
            logNavigationError("无法找到顶层视图控制器")
            return
        }
        
        if let navController = topViewController as? UINavigationController {
            navController.pushViewController(viewController, animated: animated)
            setCurrentNavigationController(navController)
        } else if let navController = topViewController.navigationController {
            navController.pushViewController(viewController, animated: animated)
            setCurrentNavigationController(navController)
        } else {
            // 创建新的导航控制器
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = config.modalPresentationStyle
            topViewController.present(navController, animated: animated)
            setCurrentNavigationController(navController)
        }
        
        enableGestureRecognizerIfNeeded()
    }
    
    private func findTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        
        var topController = rootViewController
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
    }
    
    private func createHostingController<Content: View>(_ view: Content) -> UIHostingController<Content> {
        let hostingController = UIHostingController(rootView: view)
        
        // 配置返回按钮
        if config.shouldSetCurrentNavControllerAutomatically {
            setupBackButton(for: hostingController)
        }
        
        return hostingController
    }
    
    private func setupBackButton<Content: View>(for hostingController: UIHostingController<Content>) {
        // 确保 SwiftUI 页面支持手势返回
        hostingController.navigationItem.largeTitleDisplayMode = .never
    }
    
    /// 启用手势返回识别器
    private func enableGestureRecognizerIfNeeded() {
        guard config.enableGestureBack else { return }
        
        if let navController = currentNavigationController {
            navController.interactivePopGestureRecognizer?.isEnabled = true
            // 确保手势代理不为空
            if navController.interactivePopGestureRecognizer?.delegate == nil {
                navController.interactivePopGestureRecognizer?.delegate = self
            }
            
            #if DEBUG
            print("[MKSwiftNavigationBridge] 手势返回已启用 - VC数量: \(navController.viewControllers.count)")
            #endif
        }
    }
    
    private func addToNavigationStack(_ navigationController: UINavigationController) {
        navigationStack.removeAll { $0 == navigationController }
        navigationStack.append(navigationController)
        
        // 保持栈的大小合理
        if navigationStack.count > 10 {
            navigationStack.removeFirst()
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleViewControllerDidAppear(_:)),
            name: NSNotification.Name("ViewControllerDidAppearNotification"),
            object: nil
        )
    }
    
    @objc private func handleViewControllerDidAppear(_ notification: Notification) {
        if config.shouldSetCurrentNavControllerAutomatically,
           let viewController = notification.object as? UIViewController {
            currentNavigationController = viewController.navigationController
            enableGestureRecognizerIfNeeded()
        }
    }
    
    private func logNavigationError(_ message: String) {
        #if DEBUG
        print("[MKSwiftNavigationBridge] Error: \(message)")
        #endif
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MKSwiftNavigationBridge: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 允许手势返回
        return true
    }
}

// MARK: - 便捷扩展
public extension MKSwiftNavigationBridge {
    
    /// 便捷方法：推送到 UIKit 页面（类型安全）
    func pushToUIKit<T: UIViewController>(_ type: T.Type, animated: Bool? = nil) where T: Navigatable {
        let viewController = T()
        pushToUIKit(viewController, animated: animated)
    }
    
    /// 便捷方法：使用闭包创建 SwiftUI 页面并推送
    /// - Parameters:
    ///   - viewBuilder: 创建 SwiftUI 视图的闭包
    ///   - animated: 是否动画
    func pushToSwiftUI<Content: View>(
        _ viewBuilder: () -> Content,
        animated: Bool? = nil
    ) {
        let swiftUIView = viewBuilder()
        pushToSwiftUI(swiftUIView, animated: animated)
    }
    
    /// 便捷方法：使用闭包模态呈现 SwiftUI 页面
    /// - Parameters:
    ///   - viewBuilder: 创建 SwiftUI 视图的闭包
    ///   - completion: 完成回调
    func presentSwiftUI<Content: View>(
        _ viewBuilder: () -> Content,
        completion: (() -> Void)? = nil
    ) {
        let swiftUIView = viewBuilder()
        presentSwiftUI(swiftUIView, completion: completion)
    }
}

// MARK: - 协议定义
/// 可导航协议，用于类型安全的导航
public protocol Navigatable {
    init()
}

// MARK: - UIViewController 扩展
public extension UIViewController {
    
    /// 便捷方法：从 UIKit 推送到 SwiftUI
    func pushToSwiftUI<Content: View>(_ swiftUIView: Content, animated: Bool = true) {
        MKSwiftNavigationBridge.pushSwiftUIFromUIKit(swiftUIView, from: navigationController, animated: animated)
    }
    
    /// 便捷方法：使用闭包从 UIKit 推送到 SwiftUI
    func pushToSwiftUI<Content: View>(
        _ viewBuilder: () -> Content,
        animated: Bool = true
    ) {
        let swiftUIView = viewBuilder()
        MKSwiftNavigationBridge.pushSwiftUIFromUIKit(swiftUIView, from: navigationController, animated: animated)
    }
    
    /// 便捷方法：从 UIKit 模态呈现 SwiftUI
    func presentSwiftUI<Content: View>(_ swiftUIView: Content, completion: (() -> Void)? = nil) {
        MKSwiftNavigationBridge.presentSwiftUIFromUIKit(swiftUIView, from: self, completion: completion)
    }
    
    /// 便捷方法：使用闭包从 UIKit 模态呈现 SwiftUI
    func presentSwiftUI<Content: View>(
        _ viewBuilder: () -> Content,
        completion: (() -> Void)? = nil
    ) {
        let swiftUIView = viewBuilder()
        MKSwiftNavigationBridge.presentSwiftUIFromUIKit(swiftUIView, from: self, completion: completion)
    }
    
    /// 通知导航桥接器当前控制器已显示
    func notifyNavigationBridge() {
        NotificationCenter.default.post(
            name: NSNotification.Name("ViewControllerDidAppearNotification"),
            object: self
        )
    }
}

// MARK: - 非主Actor环境下的便捷扩展
public extension MKSwiftNavigationBridge {
    
    /// 在非主Actor环境中推送到 UIKit 页面
    func pushToUIKitAsync(_ viewController: UIViewController, animated: Bool? = nil) async {
        await MainActor.run {
            self.pushToUIKit(viewController, animated: animated)
        }
    }
    
    /// 在非主Actor环境中模态呈现 UIKit 页面
    func presentUIKitAsync(_ viewController: UIViewController, completion: (() -> Void)? = nil) async {
        await MainActor.run {
            self.presentUIKit(viewController, completion: completion)
        }
    }
    
    /// 在非主Actor环境中推送到 SwiftUI 页面
    func pushToSwiftUIAsync<Content: View>(_ swiftUIView: Content, animated: Bool? = nil) async {
        await MainActor.run {
            self.pushToSwiftUI(swiftUIView, animated: animated)
        }
    }
    
    /// 在非主Actor环境中使用闭包推送到 SwiftUI 页面
    func pushToSwiftUIAsync<Content: View>(
        _ viewBuilder: () -> Content,
        animated: Bool? = nil
    ) async {
        await MainActor.run {
            self.pushToSwiftUI(viewBuilder, animated: animated)
        }
    }
    
    /// 在非主Actor环境中返回上一页
    func popViewControllerAsync(animated: Bool? = nil) async {
        await MainActor.run {
            self.popViewController(animated: animated)
        }
    }
    
    /// 在非主Actor环境中返回到根页面
    func popToRootViewControllerAsync(animated: Bool? = nil) async {
        await MainActor.run {
            self.popToRootViewController(animated: animated)
        }
    }
    
    /// 在非主Actor环境中关闭模态页面
    func dismissViewControllerAsync(animated: Bool? = nil, completion: (() -> Void)? = nil) async {
        await MainActor.run {
            self.dismissViewController(animated: animated, completion: completion)
        }
    }
}
