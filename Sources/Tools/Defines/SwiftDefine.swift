//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/5/29.
//

import Foundation
import UIKit

// MARK: - Weak/Strong References
public func weakify<T: AnyObject>(_ object: T) -> () -> T? {
    return { [weak object] in object }
}

public func strongify<T: AnyObject>(weakObject: () -> T?, closure: (T) -> Void) {
    guard let object = weakObject() else { return }
    closure(object)
}

// MARK: - Device Related
@MainActor public enum Screen {
    public static let bounds = UIScreen.main.bounds
    public static let width = UIScreen.main.bounds.width
    public static let height = UIScreen.main.bounds.height
    public static let maxLength = max(width, height)
    public static let minLength = min(width, height)
    public static let scale = UIScreen.main.scale
}

// MARK: - System Related
@MainActor public enum App {
    public static var delegate: UIApplicationDelegate? {
        UIApplication.shared.delegate
    }
    
    public static var window: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap { $0 as? UIWindowScene }?.windows
            .first
    }
    
    public static var rootViewController: UIViewController? {
        window?.rootViewController
    }
    
    public static var systemVersion: String {
        UIDevice.current.systemVersion
    }
    
    public static var name: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    }
    
    public static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    public static func isIOS(_ version: Int) -> Bool {
        ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= version
    }
    
    public static var timeStamp: String {
        String(Int(Date().timeIntervalSince1970))
    }
    
    public static func dispatchMainSafe(_ closure: @Sendable @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }
}

// MARK: - Status Bar, Navigation Bar, Tab Bar
@MainActor public enum Layout {
    public static var statusBarHeight: CGFloat {
        return App.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
    
    public static var navigationBarHeight: CGFloat {
        UINavigationController().navigationBar.frame.height
    }
    
    public static var tabBarHeight: CGFloat {
        UITabBarController().tabBar.frame.height
    }
    
    public static var topBarHeight: CGFloat {
        statusBarHeight + navigationBarHeight
    }
    
    public static var safeAreaBottom: CGFloat {
        return App.window?.safeAreaInsets.bottom ?? 0
    }
}

// MARK: - File Paths
public enum Path {
    public static let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    public static let library = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first ?? ""
    public static let caches = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
    public static let temp = NSTemporaryDirectory()
    
    public static func filePath(_ filename: String) -> String {
        (documents as NSString).appendingPathComponent(filename)
    }
}

// MARK: - Font
public enum Font {
    public static func MKFont(_ size: CGFloat) -> UIFont {
        if let font = UIFont(name: "Helvetica-Bold", size: size) {
            return font
        }
        return UIFont.systemFont(ofSize: size)
    }
}

// MARK: - Line
@MainActor public enum Line {
    public static let height: CGFloat = Screen.scale == 2.0 ? 0.5 : 0.34
    public static let color = Color.fromHex(0xe5e5e5)
}

// MARK: - Images
@MainActor public func loadImage(name: String, ext: String? = nil) -> UIImage? {
    let bundle = Bundle.main
    let imageName = name + (Screen.scale > 2.0 ? "@3x" : "@2x")
    var image = UIImage(named: imageName, in: bundle, compatibleWith: nil)
    
    if image == nil, let ext = ext {
        let path = bundle.path(forResource: name, ofType: ext)
        image = path.flatMap { UIImage(contentsOfFile: $0) }
    }
    
    return image
}

public func moduleIcon(name :String) -> UIImage? {
    return UIImage(named: name, in: .module, compatibleWith: nil)
}

// MARK: - Colors
public enum Color {
    public static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) -> UIColor {
        UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    public static func fromHex(_ rgbValue: Int) -> UIColor {
        UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0xFF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
    
    public static var random: UIColor {
        UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
    }
    
    public static let black = fromHex(0x333333)
    public static let deepBlack = fromHex(0x000000)
    public static let blue = fromHex(0x4790ef)
    public static let skyBlue = fromHex(0xf3f8fe)
    public static let lightBlue = fromHex(0x4490ee)
    public static let gray = fromHex(0x999999)
    public static let lightGray = fromHex(0xdddddd)
    public static let line = fromHex(0xe5e5e5)
    public static let red = fromHex(0xff3400)
    public static let lightRed = fromHex(0xff4200)
    public static let green = fromHex(0x32b16c)
    public static let buttonSure = rgb(75, 146, 236)
    public static let fontBlack = rgb(51, 51, 51)
    public static let white = rgb(255, 255, 255)
    public static let clear = white.withAlphaComponent(0)
    public static let navBar = fromHex(0x2F84D0)
    public static let defaultText = fromHex(0x353535)
}

// MARK: - String/Array/Dictionary Validation
public enum Valid {
    public static func string(_ s: Any?) -> String {
        guard let str = s as? String else { return "" }
        return ["(null)", "null", "<null>"].contains(str) ? "" : str
    }
    
    public static func date(_ d: Date?) -> Date {
        d ?? Date()
    }
    
    public static func isStringEmpty(_ s: Any?) -> Bool {
        guard let str = s as? String else { return true }
        return str.isEmpty
    }
    
    public static func isStringValid(_ s: Any?) -> Bool {
        !isStringEmpty(s)
    }
    
    public static func safeString(_ s: Any?) -> String {
        isStringValid(s) ? (s as! String) : ""
    }
    
    public static func stringContains(_ str: String, key: String) -> Bool {
        str.contains(key)
    }
    
    public static func isDictValid(_ d: Any?) -> Bool {
        guard let dict = d as? [AnyHashable: Any] else { return false }
        return !dict.isEmpty
    }
    
    public static func isArrayValid(_ a: Any?) -> Bool {
        guard let array = a as? [Any] else { return false }
        return !array.isEmpty
    }
    
    public static func isNumberValid(_ n: Any?) -> Bool {
        n is NSNumber
    }
    
    public static func isClassValid(_ o: Any?, cls: AnyClass) -> Bool {
        o != nil && (type(of: o!) == cls)
    }
    
    public static func isDataValid(_ d: Any?) -> Bool {
        d is Data
    }
}
