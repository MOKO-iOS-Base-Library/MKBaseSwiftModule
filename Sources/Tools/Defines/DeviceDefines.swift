//
//  MKDevice.swift
//  MKPS101SwiftProject_Example
//
//  Created by aa on 2024/2/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

// Screen dimensions
let screenRect = UIScreen.main.bounds
let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height

let screenMaxLength = max(screenWidth, screenHeight)
let screenMinLength = min(screenWidth, screenHeight)

var appWindow: UIWindow? {
    if #available(iOS 13.0, *) {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .last
    } else {
        return UIApplication.shared.windows.last
    }
}

var appRootController: UIViewController? {
    if #available(iOS 15.0, *) {
        guard let activeScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return nil
        }
        return activeScene.windows.first?.rootViewController
    } else {
        return UIApplication.shared.windows.first?.rootViewController
    }
}

// System-related properties
let systemVersion: String = {
    if #available(iOS 15.0, *) {
        return ProcessInfo.processInfo.operatingSystemVersionString
    } else {
        return UIDevice.current.systemVersion
    }
}()

let appName: String? = {
    if #available(iOS 15.0, *) {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
    } else {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}()

let appVersion: String? = {
    if #available(iOS 15.0, *) {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    } else {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}()

func iOS(_ version: Int) -> Bool {
    if #available(iOS 15.0, *) {
        return true
    } else {
        return false
    }
}

// System timestamp
let systemTimeStamp = "\(Int(Date().timeIntervalSince1970))"

// Status bar, navigation bar, and tab bar related properties
//let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
let statusBarHeight:CGFloat = {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        return windowScene.statusBarManager?.statusBarFrame.size.height ?? 0
    }
    return 0
}()

let navigationBarHeight = UINavigationController().navigationBar.frame.size.height

let tabBarHeight = UITabBarController().tabBar.frame.size.height

let topBarHeight = statusBarHeight + navigationBarHeight

let safeAreaHeight: CGFloat = {
    if #available(iOS 11.0, *) {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0.0
    } else {
        return 0.0
    }
}()

// Document directory paths
let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first

func filePath(for filename: String) -> String {
    return (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as NSString?)?.appendingPathComponent(filename) ?? ""
}

// Library directory path
let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first

// Caches directory path
let cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first

// Temporary directory path
let tmpPath = NSTemporaryDirectory()

// Dispatch to main queue safely
func dispatchMainSafe(_ block: @escaping () -> Void) {
    if DispatchQueue.getSpecific(key: DispatchSpecificKey<Int>()) == DispatchQueue.main.getSpecific(key: DispatchSpecificKey<Int>()) {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}

// Font
func MKFont(withSize size: CGFloat) -> UIFont {
    if let customFont = UIFont(name: "Helvetica-Bold", size: size) {
        return customFont
    } else {
        return UIFont.systemFont(ofSize: size)
    }
}


let CUTTING_LINE_HEIGHT: CGFloat = UIScreen.main.scale == 2.0 ? 0.5 : 0.34


func LOADIMAGE(_ file: String, _ ext: String) -> UIImage? {
    let bundle = Bundle.main
    let imageName = "\(file)\(UIScreen.main.nativeScale > 2.0 ? "@3x" : "@2x")"
    var image = UIImage(named: imageName, in: bundle, compatibleWith: nil)
    
    if image == nil {
        if let imagePath = bundle.path(forResource: file, ofType: ext) {
            image = UIImage(contentsOfFile: imagePath)
        }
    }
    
    return image
}


func LOADICON(_ podLibName: String, _ bundleClassName: String, _ imageName: String) -> UIImage? {
    guard let bundle = Bundle(for: NSClassFromString(bundleClassName)!) as Bundle? else {
        return nil
    }

    let bundlePath = bundle.path(forResource: podLibName, ofType: "bundle")
    let image = UIImage(contentsOfFile: (bundlePath! as NSString).appendingPathComponent(imageName))

    return image
}
