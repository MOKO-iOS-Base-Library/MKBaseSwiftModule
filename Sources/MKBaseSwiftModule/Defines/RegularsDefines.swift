//
//  MKRegulars.swift
//  MKPS101SwiftProject_Example
//
//  Created by aa on 2024/2/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation


func Str(_ s: Any?) -> String {
    guard let str = s as? String, !str.isEmpty, str != "(null)", str != "null", str != "<null>" else {
        return ""
    }
    return str
}

func StrDate(_ s: Any?) -> Any {
    return s ?? Date()
}

func StrNull(_ f: Any?) -> Bool {
    return f == nil || !(f is String) || ((f is String) && (f as! String) == "")
}

func StrValid(_ f: Any?) -> Bool {
    return f != nil && f is String && (f as! String) != ""
}

func SafeStr(_ f: Any?) -> String {
    return StrValid(Str(f)) ? (f as! String) : ""
}

func HasString(_ str: String, _ key: String) -> Bool {
    return str.range(of: key) != nil
}

func ValidStr(_ f: Any?) -> Bool {
    return StrValid(f)
}

func ValidDict(_ f: Any?) -> Bool {
    return f is NSDictionary && (f as! NSDictionary).count > 0
}

func ValidArray(_ f: Any?) -> Bool {
    return f is NSArray && (f as! NSArray).count > 0
}

func ValidNum(_ f: Any?) -> Bool {
    return f is NSNumber
}

func ValidClass<T>(_ f: Any?, cls: T.Type) -> Bool {
    return f != nil && f is T
}

func ValidData(_ f: Any?) -> Bool {
    return f is Data
}
