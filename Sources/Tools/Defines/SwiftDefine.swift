//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/5/29.
//

import Foundation
import UIKit

// MARK: - Weak/Strong References
// Weak reference
func weakify<T: AnyObject>(_ object: T) -> () -> T? {
    return { [weak object] in object }
}

// Strong reference (to be used inside closures)
func strongify<T: AnyObject>(weakObject: () -> T?, closure: (T) -> Void) {
    guard let object = weakObject() else { return }
    closure(object)
}

// MARK: - Device Related
@MainActor struct Screen {
    static let bounds = UIScreen.main.bounds
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
    static let maxLength = max(width, height)
    static let minLength = min(width, height)
    static let scale = UIScreen.main.scale
}

// MARK: - System Related
@MainActor struct App {
    static var delegate: UIApplicationDelegate? {
        UIApplication.shared.delegate
    }
    
    static var window: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap { $0 as? UIWindowScene }?.windows
            .first
    }
    
    static var rootViewController: UIViewController? {
        window?.rootViewController
    }
    
    static var systemVersion: String {
        UIDevice.current.systemVersion
    }
    
    static var name: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    }
    
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    static func isIOS(_ version: Int) -> Bool {
        return ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= version
    }
    
    static var timeStamp: String {
        String(Int(Date().timeIntervalSince1970))
    }
}

// MARK: - Status Bar, Navigation Bar, Tab Bar
@MainActor struct Layout {
    static var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return App.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    static var navigationBarHeight: CGFloat {
        UINavigationController().navigationBar.frame.height
    }
    
    static var tabBarHeight: CGFloat {
        UITabBarController().tabBar.frame.height
    }
    
    static var topBarHeight: CGFloat {
        statusBarHeight + navigationBarHeight
    }
    
    static var safeAreaBottom: CGFloat {
        if #available(iOS 11.0, *) {
            return App.window?.safeAreaInsets.bottom ?? 0
        }
        return 0
    }
}

// MARK: - File Paths
struct Path {
    static let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    static let library = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first ?? ""
    static let caches = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
    static let temp = NSTemporaryDirectory()
    
    static func filePath(_ filename: String) -> String {
        (documents as NSString).appendingPathComponent(filename)
    }
}

// MARK: - Dispatch
func dispatchMainSafe(_ closure: @Sendable @escaping () -> Void) {
    if Thread.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async(execute: closure)
    }
}

// MARK: - Font
func font(_ size: CGFloat) -> UIFont {
    UIFont(name: "Helvetica-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
}

// MARK: - Localization
func LS(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

// MARK: - Line
@MainActor struct Line {
    static let height: CGFloat = Screen.scale == 2.0 ? 0.5 : 0.34
    static let color = Color.fromHex(0xe8e8e8)
}

// MARK: - Images
@MainActor func loadImage(name: String, ext: String? = nil) -> UIImage? {
    let bundle = Bundle.main
    let imageName = name + (Screen.scale > 2.0 ? "@3x" : "@2x")
    var image = UIImage(named: imageName, in: bundle, compatibleWith: nil)
    
    if image == nil, let ext = ext {
        let path = bundle.path(forResource: name, ofType: ext)
        image = path.flatMap { UIImage(contentsOfFile: $0) }
    }
    
    return image
}

func loadIcon(podLibName: String, bundleClassName: String, imageName: String) -> UIImage? {
    guard let bundleClass = NSClassFromString(bundleClassName) else { return nil }
    let bundle = Bundle(for: bundleClass)
    guard let bundlePath = bundle.path(forResource: podLibName, ofType: "bundle") else { return nil }
    return UIImage(contentsOfFile: (bundlePath as NSString).appendingPathComponent(imageName))
}

// MARK: - Colors
struct Color {
    static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) -> UIColor {
        UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    static func fromHex(_ rgbValue: Int) -> UIColor {
        UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0xFF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
    
    static var random: UIColor {
        UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
    }
    
    static let black = fromHex(0x333333)
    static let deepBlack = fromHex(0x000000)
    static let blue = fromHex(0x4790ef)
    static let skyBlue = fromHex(0xf3f8fe)
    static let lightBlue = fromHex(0x4490ee)
    static let gray = fromHex(0x999999)
    static let lightGray = fromHex(0xdddddd)
    static let line = fromHex(0xe5e5e5)
    static let red = fromHex(0xff3400)
    static let lightRed = fromHex(0xff4200)
    static let green = fromHex(0x32b16c)
    static let buttonSure = rgb(75, 146, 236)
    static let fontBlack = rgb(51, 51, 51)
    static let white = rgb(255, 255, 255)
    static let clear = white.withAlphaComponent(0)
    static let navBar = fromHex(0x2F84D0)
    static let defaultText = fromHex(0x353535)
}

// MARK: - String/Array/Dictionary Validation
struct Valid {
    static func string(_ s: Any?) -> String {
        guard let str = s as? String else { return "" }
        return ["(null)", "null", "<null>"].contains(str) ? "" : str
    }
    
    static func date(_ d: Date?) -> Date {
        d ?? Date()
    }
    
    static func isStringEmpty(_ s: Any?) -> Bool {
        guard let str = s as? String else { return true }
        return str.isEmpty
    }
    
    static func isStringValid(_ s: Any?) -> Bool {
        !isStringEmpty(s)
    }
    
    static func safeString(_ s: Any?) -> String {
        isStringValid(s) ? (s as! String) : ""
    }
    
    static func stringContains(_ str: String, key: String) -> Bool {
        str.contains(key)
    }
    
    static func isDictValid(_ d: Any?) -> Bool {
        guard let dict = d as? [AnyHashable: Any] else { return false }
        return !dict.isEmpty
    }
    
    static func isArrayValid(_ a: Any?) -> Bool {
        guard let array = a as? [Any] else { return false }
        return !array.isEmpty
    }
    
    static func isNumberValid(_ n: Any?) -> Bool {
        n is NSNumber
    }
    
    static func isClassValid(_ o: Any?, cls: AnyClass) -> Bool {
        o != nil && (type(of: o!) == cls)
    }
    
    static func isDataValid(_ d: Any?) -> Bool {
        d is Data
    }
}
