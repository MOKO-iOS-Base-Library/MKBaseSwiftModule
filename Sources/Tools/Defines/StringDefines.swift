//
//  StringDefines.swift
//  MKPSSwiftProject
//
//  Created by aa on 2024/3/29.
//

import Foundation

import UIKit

let isRealNumbers = "[0-9]*" // 是否是纯数字
let isChinese = "[\\u4e00-\\u9fa5]+" // 是否是汉字
let isLetter = "[a-zA-Z]*" // 是否是字母
let isLetterOrRealNumbers = "[a-zA-Z0-9]*" // 是否是数字或者字母
let isHexadecimal = "[a-fA-F0-9]*" // 是否是16进制字符
let isIPAddress = "^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    + "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    + "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    + "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$" // 是否是IP地址
let isUrl = "[a-zA-z]+://[^\\s]*" // 是否是Url

/// 根据文字的内容、字体大小、最大尺寸范围 计算文字所占的尺寸
/// - Parameters:
///   - string: 文字内容
///   - font: 文字字体
///   - maxSize: 最大尺寸范围
/// - Returns: 文字所占的尺寸
func stringSize(string: String,font: UIFont, maxSize: CGSize) -> CGSize {
    var expectedLabelSize = CGSize.zero
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = .byWordWrapping
    paragraphStyle.lineSpacing = 0 // 设置行间距为0
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .paragraphStyle: paragraphStyle.copy()
    ]
    expectedLabelSize = string.boundingRect(with: maxSize,
                                          options: [.usesLineFragmentOrigin, .usesFontLeading],
                                          attributes: attributes,
                                          context: nil).size
    return CGSize(width: ceil(expectedLabelSize.width), height: ceil(expectedLabelSize.height))
}

/// 验证目标字符串是否符合正则表达式
/// - Parameters:
///   - string: 目标字符串
///   - regex: 正则表达式
/// - Returns: 结果
func regularExpressions(string: String, regex: String) -> Bool {
    if regex.isEmpty || string.isEmpty {
        return false
    }
    let pred = NSPredicate(format: "SELF MATCHES %@", regex)
    return pred.evaluate(with: string)
}


/// 验证字符串是否为UUID字符串
/// - Parameter string: 字符串
/// - Returns: true:是UUID字符串 false:不是
func isUUIDNumber(string: String) -> Bool {
    let uuidPattern = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
    guard let regex = try? NSRegularExpression(pattern: uuidPattern, options: .caseInsensitive) else {
        return false
    }
    let numberOfMatches = regex.numberOfMatches(in: string, options: [], range: NSRange(location: 0, length: string.count))
    return numberOfMatches > 0
}

/// 验证字符串是否为ascii码字符串
/// - Parameter string: 字符串
/// - Returns: true:是ascii码字符串 false:不是
func isAsciiString(string: String) -> Bool {
    let strlen = string.count
    let datalen = string.data(using: .utf8)?.count ?? 0
    return strlen == datalen
}

/// 将十六进制字符转换成对应字节数的8位二进制字符
/// - Parameter string: 十六进制字符
/// - Returns: (string.count / 2) * 8位的二进制字符
func binaryByhex(string: String) -> String {
    guard (try? NSRegularExpression(pattern: isHexadecimal, options: [])) != nil else {
        return ""
    }
    var hex = string
    if hex.count % 2 != 0 {
        let mStr = String(repeating: "0", count: 2 - hex.count % 2)
        hex = mStr + hex
    }
    let hexDic: [String: String] = [
        "0": "0000", "1": "0001", "2": "0010",
        "3": "0011", "4": "0100", "5": "0101",
        "6": "0110", "7": "0111", "8": "1000",
        "9": "1001", "A": "1010", "a": "1010",
        "B": "1011", "b": "1011", "C": "1100",
        "c": "1100", "D": "1101", "d": "1101",
        "E": "1110", "e": "1110", "F": "1111",
        "f": "1111"
    ]
    var binaryString = ""
    for i in 0..<hex.count {
        let key = String(hex[hex.index(hex.startIndex, offsetBy: i)])
        let value = hexDic[key]
        if let value = value {
            binaryString += value
        }
    }
    return binaryString
}

/// 字符串截取
/// - Parameters:
///   - string: 要截取的字符串
///   - startIndex: 开始的位置
///   - length: 要截取的长度
/// - Returns: 截取后的字符串
func substring(string: String, startIndex: Int, length: Int) -> String {
    guard startIndex >= 0 && startIndex < string.count else { return "" }
    let endIndex = startIndex + length
    guard endIndex <= string.count else { return "" }
    
    let start = string.index(string.startIndex, offsetBy: startIndex)
    let end = string.index(string.startIndex, offsetBy: endIndex)
    return String(string[start..<end])
}
