//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/5/29.
//

import Foundation
import UIKit
import CommonCrypto
import zlib


public extension String {
    // MARK: - Size Calculations
    
    func substring(from location: Int, length: Int) -> String? {
        guard location >= 0, location < self.count else {
            return nil
        }
        
        let startIndex = self.index(self.startIndex, offsetBy: location)
        let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
        
        return String(self[startIndex..<endIndex])
    }
    
    static func size(with text: String, font: UIFont, maxSize: CGSize) -> CGSize {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = 0
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        
        let boundingRect = text.boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        
        return CGSize(
            width: ceil(boundingRect.width),
            height: ceil(boundingRect.height)
        )
    }
    
    static func spaceLabelHeight(with text: String, lineSpace: CGFloat, font: UIFont, width: CGFloat) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .kern: 1.5
        ]
        
        let boundingRect = text.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            attributes: attributes,
            context: nil
        )
        
        return boundingRect.height
    }
    
    // MARK: - Validation
    
    func matchesRegex(_ regex: String) -> Bool {
        guard !regex.isEmpty, !self.isEmpty else { return false }
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    var isUUIDNumber: Bool {
        let uuidPattern = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
        guard let regex = try? NSRegularExpression(pattern: uuidPattern, options: .caseInsensitive) else {
            return false
        }
        return regex.numberOfMatches(in: self, range: NSRange(location: 0, length: self.count)) > 0
    }
    
    var isAsciiString: Bool {
        return self.count == self.data(using: .utf8)?.count
    }
    
    // MARK: - Binary/Hex Conversion
    
    var binaryFromHex: String {
        guard !isEmpty, matchesRegex("[a-fA-F0-9]*") else { return "" }
        
        var hex = self
        if hex.count % 2 != 0 {
            hex = String(repeating: "0", count: 2 - hex.count % 2) + hex
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
        for char in hex {
            let key = String(char)
            binaryString += hexDic[key] ?? ""
        }
        
        return binaryString
    }
    
    var hexFromBinary: String {
        guard !isEmpty, matchesRegex("[a-fA-F0-9]*") else { return "" }
        
        var binary = self
        if binary.count % 8 != 0 {
            binary = String(repeating: "0", count: 8 - binary.count % 8) + binary
        }
        
        let binaryDic: [String: String] = [
            "0000": "0", "0001": "1", "0010": "2",
            "0011": "3", "0100": "4", "0101": "5",
            "0110": "6", "0111": "7", "1000": "8",
            "1001": "9", "1010": "A", "1011": "B",
            "1100": "C", "1101": "D", "1110": "E",
            "1111": "F"
        ]
        
        var tempString = ""
        let totalNum = binary.count / 8
        
        for j in 0..<totalNum {
            let start = binary.index(binary.startIndex, offsetBy: j * 8)
            let end = binary.index(start, offsetBy: 8)
            let tempBinary = String(binary[start..<end])
            
            var hex = ""
            for i in stride(from: 0, to: 8, by: 4) {
                let startIdx = tempBinary.index(tempBinary.startIndex, offsetBy: i)
                let endIdx = tempBinary.index(startIdx, offsetBy: 4)
                let key = String(tempBinary[startIdx..<endIdx])
                hex += binaryDic[key] ?? ""
            }
            
            tempString += hex
        }
        
        return tempString
    }
    
    var dataFromHexString: Data {
        guard !isEmpty else { return Data() }
        
        var hex = self
        if hex.count % 2 != 0 {
            hex = "0" + hex
        }
        
        var data = Data()
        var startIndex = hex.startIndex
        
        while startIndex < hex.endIndex {
            let endIndex = hex.index(startIndex, offsetBy: 2)
            let byteString = String(hex[startIndex..<endIndex])
            
            if let byte = UInt8(byteString, radix: 16) {
                data.append(byte)
            }
            
            startIndex = endIndex
        }
        
        return data
    }
    
    // MARK: - Phone Number Validation
    
    var isMobileNumber: Bool {
        let mobile = "^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$"
        let cm = "^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$"
        let cu = "^1(3[0-2]|5[256]|8[56])\\d{8}$"
        let ct = "^1((33|53|8[09])[0-9]|349)\\d{7}$"
        let phs = "^0(10|2[0-5789]|\\d{3})\\d{7,8}$"
        let xnhm = "^1(77)\\d{8}$"
        
        let predicates = [mobile, cm, cu, ct, phs, xnhm].map {
            NSPredicate(format: "SELF MATCHES %@", $0)
        }
        
        return predicates.contains { $0.evaluate(with: self) }
    }
    
    // MARK: - Encoding/Decoding
    
    var base64EncodedString: String {
        return data(using: .utf8)?.base64EncodedString() ?? ""
    }
    
    static func string(withBase64EncodedString base64EncodedString: String) -> String? {
        guard let data = Data(base64Encoded: base64EncodedString) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    var urlEncodedString: String {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        
        let batchSize = 50
        var index = startIndex
        var escaped = ""
        
        while index != endIndex {
            let endIndex = self.index(index, offsetBy: batchSize, limitedBy: self.endIndex) ?? self.endIndex
            let substring = String(self[index..<endIndex])
            
            if let encoded = substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
                escaped += encoded
            }
            
            index = endIndex
        }
        
        return escaped
    }
    
    var urlDecodedString: String {
        return removingPercentEncoding ?? self
    }
    
    var htmlEscapedString: String {
        guard !isEmpty else { return self }
        
        var result = ""
        for char in self {
            switch char {
            case "\"": result += "&quot;"
            case "&": result += "&amp;"
            case "'": result += "&apos;"
            case "<": result += "&lt;"
            case ">": result += "&gt;"
            default: result.append(char)
            }
        }
        return result
    }
    
    // MARK: - Drawing
    
    func size(withFont font: UIFont, maxSize: CGSize) -> CGSize {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = 0
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        
        let boundingRect = self.boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        
        return CGSize(
            width: ceil(boundingRect.width),
            height: ceil(boundingRect.height)
        )
    }
    
    // MARK: - Regular Expressions
    
    func matchesRegex(_ regex: String, options: NSRegularExpression.Options = []) -> Bool {
        guard let pattern = try? NSRegularExpression(pattern: regex, options: options) else { return false }
        return pattern.numberOfMatches(in: self, range: NSRange(location: 0, length: count)) > 0
    }
    
    func enumerateRegexMatches(_ regex: String, options: NSRegularExpression.Options = [], using block: (String, NSRange, inout Bool) -> Void) {
        guard !regex.isEmpty, let pattern = try? NSRegularExpression(pattern: regex, options: options) else { return }
        
        pattern.enumerateMatches(in: self, options: [], range: NSRange(location: 0, length: count)) { result, _, stop in
            guard let result = result else { return }
            var shouldStop = false
            let match = String(self[Range(result.range, in: self)!])
            block(match, result.range, &shouldStop)
            if shouldStop {
                stop.pointee = true
            }
        }
    }
    
    func stringByReplacingRegex(_ regex: String, options: NSRegularExpression.Options = [], with replacement: String) -> String {
        guard let pattern = try? NSRegularExpression(pattern: regex, options: options) else { return self }
        return pattern.stringByReplacingMatches(
            in: self,
            range: NSRange(location: 0, length: count),
            withTemplate: replacement
        )
    }
    
    // MARK: - Utilities
    
    static var uuidString: String {
        return UUID().uuidString
    }
}

// MARK: - Regular Expression Constants

public extension String {
    static let isRealNumbers = "[0-9]*"
    static let isChinese = "[\\u4e00-\\u9fa5]+"
    static let isLetter = "[a-zA-Z]*"
    static let isLetterOrRealNumbers = "[a-zA-Z0-9]*"
    static let isHexadecimal = "[a-fA-F0-9]*"
    static let isIPAddress = "^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\." +
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\." +
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\." +
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$"
    static let isUrl = "[a-zA-z]+://[^\\s]*"
}

extension Array {
    // MARK: - Plist
    
    static func mk_array(withPlistData plist: Data) -> [Any]? {
        do {
            let array = try PropertyListSerialization.propertyList(from: plist, options: [], format: nil)
            return array as? [Any]
        } catch {
            return nil
        }
    }
    
    static func mk_array(withPlistString plist: String) -> [Any]? {
        guard let data = plist.data(using: .utf8) else { return nil }
        return mk_array(withPlistData: data)
    }
    
    func mk_plistData() -> Data? {
        return try? PropertyListSerialization.data(fromPropertyList: self, format: .binary, options: 0)
    }
    
    func mk_plistString() -> String? {
        guard let xmlData = try? PropertyListSerialization.data(fromPropertyList: self, format: .xml, options: 0) else {
            return nil
        }
        return String(data: xmlData, encoding: .utf8)
    }
    
    // MARK: - Random Access
    
    func mk_randomObject() -> Element? {
        guard !isEmpty else { return nil }
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
    
    func mk_objectOrNil(at index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    // MARK: - JSON
    
    func mk_jsonStringEncoded() -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
    
    func mk_jsonPrettyStringEncoded() -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
}

extension Array where Element: Equatable {
    mutating func mk_removeFirstObject() {
        if !isEmpty {
            removeFirst()
        }
    }
    
    @discardableResult
    mutating func mk_popFirstObject() -> Element? {
        guard !isEmpty else { return nil }
        return removeFirst()
    }
}

extension Array {
    mutating func mk_removeLastObject() {
        if !isEmpty {
            removeLast()
        }
    }
    
    @discardableResult
    mutating func mk_popLastObject() -> Element? {
        guard !isEmpty else { return nil }
        return removeLast()
    }
    
    mutating func mk_appendObject(_ object: Element) {
        append(object)
    }
    
    mutating func mk_prependObject(_ object: Element) {
        insert(object, at: 0)
    }
    
    mutating func mk_appendObjects(_ objects: [Element]) {
        append(contentsOf: objects)
    }
    
    mutating func mk_prependObjects(_ objects: [Element]) {
        insert(contentsOf: objects, at: 0)
    }
    
    mutating func mk_insertObjects(_ objects: [Element], at index: Int) {
        guard index <= count else { return }
        insert(contentsOf: objects, at: index)
    }
    
    mutating func mk_reverse() {
        reverse()
    }
    
    mutating func mk_shuffle() {
        shuffle()
    }
}

extension NSArray {
    static func mk_array(withPlistData plist: Data) -> NSArray? {
        do {
            let array = try PropertyListSerialization.propertyList(from: plist, options: .mutableContainersAndLeaves, format: nil)
            return array as? NSArray
        } catch {
            return nil
        }
    }
    
    static func mk_array(withPlistString plist: String) -> NSArray? {
        guard let data = plist.data(using: .utf8) else { return nil }
        return mk_array(withPlistData: data)
    }
}

extension Dictionary {
    // MARK: - Dictionary Convertor
    
    static func mk_dictionary(withPlistData plist: Data) -> [AnyHashable: Any]? {
        guard !plist.isEmpty else { return nil }
        do {
            let dictionary = try PropertyListSerialization.propertyList(from: plist, options: [], format: nil)
            return dictionary as? [AnyHashable: Any]
        } catch {
            return nil
        }
    }
    
    static func mk_dictionary(withPlistString plist: String) -> [AnyHashable: Any]? {
        guard !plist.isEmpty else { return nil }
        guard let data = plist.data(using: .utf8) else { return nil }
        return mk_dictionary(withPlistData: data)
    }
    
    func mk_plistData() -> Data? {
        do {
            return try PropertyListSerialization.data(fromPropertyList: self, format: .binary, options: 0)
        } catch {
            return nil
        }
    }
    
    func mk_plistString() -> String? {
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: self, format: .xml, options: 0)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    func mk_allKeysSorted() -> [Key] where Key: Comparable {
        return keys.sorted()
    }
    
    func mk_allValuesSortedByKeys() -> [Value] where Key: Comparable {
        return mk_allKeysSorted().map { self[$0]! }
    }
    
    func mk_containsObject(forKey key: Key) -> Bool {
        return self[key] != nil
    }
    
    func mk_entries(forKeys keys: [Key]) -> [Key: Value] {
        var result: [Key: Value] = [:]
        for key in keys {
            if let value = self[key] {
                result[key] = value
            }
        }
        return result
    }
    
    func mk_jsonStringEncoded() -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    func mk_jsonPrettyStringEncoded() -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    // MARK: - Dictionary Value Getter
    
    private func numberFromValue(_ value: Any?) -> NSNumber? {
        guard let value = value else { return nil }
        
        if let number = value as? NSNumber {
            return number
        }
        
        if let string = value as? String {
            let lower = string.lowercased()
            if lower == "true" || lower == "yes" { return true }
            if lower == "false" || lower == "no" { return false }
            if lower == "nil" || lower == "null" { return nil }
            
            if string.contains(".") {
                return NSNumber(value: Double(string) ?? 0)
            } else {
                return NSNumber(value: Int64(string) ?? 0)
            }
        }
        
        return nil
    }
    
    func mk_boolValue(forKey key: Key, default def: Bool) -> Bool {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number.boolValue }
        if let string = value as? String { return numberFromValue(string)?.boolValue ?? def }
        return def
    }
    
    func mk_charValue(forKey key: Key, default def: Int8) -> Int8 {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number.int8Value }
        if let string = value as? String { return numberFromValue(string)?.int8Value ?? def }
        return def
    }
    
    func mk_unsignedCharValue(forKey key: Key, default def: UInt8) -> UInt8 {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number.uint8Value }
        if let string = value as? String { return numberFromValue(string)?.uint8Value ?? def }
        return def
    }
    
    func mk_shortValue(forKey key: Key, default def: Int16) -> Int16 {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number.int16Value }
        if let string = value as? String { return numberFromValue(string)?.int16Value ?? def }
        return def
    }
    
    func mk_unsignedShortValue(forKey key: Key, default def: UInt16) -> UInt16 {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number.uint16Value }
        if let string = value as? String { return numberFromValue(string)?.uint16Value ?? def }
        return def
    }
    
    func mk_intValue(forKey key: Key, default def: Int32) -> Int32 {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number.int32Value }
        if let string = value as? String { return numberFromValue(string)?.int32Value ?? def }
        return def
    }
    
    func mk_unsignedIntValue(forKey key: Key, default def: UInt32) -> UInt32 {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number.uint32Value }
        if let string = value as? String { return numberFromValue(string)?.uint32Value ?? def }
        return def
    }
    
    func mk_longValue(forKey key: Key, default def: Int) -> Int {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number.intValue }
        if let string = value as? String { return numberFromValue(string)?.intValue ?? def }
        return def
    }
    
    func mk_unsignedLongValue(forKey key: Key, default def: UInt) -> UInt {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number.uintValue }
        if let string = value as? String { return numberFromValue(string)?.uintValue ?? def }
        return def
    }
    
    func mk_longLongValue(forKey key: Key, default def: Int64) -> Int64 {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number.int64Value }
        if let string = value as? String { return numberFromValue(string)?.int64Value ?? def }
        return def
    }
    
    func mk_unsignedLongLongValue(forKey key: Key, default def: UInt64) -> UInt64 {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number.uint64Value }
        if let string = value as? String { return numberFromValue(string)?.uint64Value ?? def }
        return def
    }
    
    func mk_floatValue(forKey key: Key, default def: Float) -> Float {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number.floatValue }
        if let string = value as? String { return numberFromValue(string)?.floatValue ?? def }
        return def
    }
    
    func mk_doubleValue(forKey key: Key, default def: Double) -> Double {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number.doubleValue }
        if let string = value as? String { return numberFromValue(string)?.doubleValue ?? def }
        return def
    }
    
    func mk_integerValue(forKey key: Key, default def: Int) -> Int {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number.intValue }
        if let string = value as? String { return numberFromValue(string)?.intValue ?? def }
        return def
    }
    
    func mk_unsignedIntegerValue(forKey key: Key, default def: UInt) -> UInt {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number.uintValue }
        if let string = value as? String { return numberFromValue(string)?.uintValue ?? def }
        return def
    }
    
    func mk_numberValue(forKey key: Key, default def: NSNumber?) -> NSNumber? {
        guard let value = self[key] else { return def }
        if let number = value as? NSNumber { return number }
        if let string = value as? String { return numberFromValue(string) }
        return def
    }
    
    func mk_stringValue(forKey key: Key, default def: String?) -> String? {
        guard let value = self[key] else { return def }
        if let string = value as? String { return string }
        if let number = value as? NSNumber { return number.stringValue }
        return def
    }
}

extension Dictionary where Key == AnyHashable {
    static func mk_dictionary(withXML xml: Any) -> [AnyHashable: Any]? {
        // XML parsing implementation would go here
        // This is complex and would require a separate XML parser implementation
        return nil
    }
}

extension NSDictionary {
    @objc static func mk_dictionary(withPlistData plist: Data) -> NSDictionary? {
        guard !plist.isEmpty else { return nil }
        do {
            let dictionary = try PropertyListSerialization.propertyList(from: plist, options: [], format: nil)
            return dictionary as? NSDictionary
        } catch {
            return nil
        }
    }
    
    @objc static func mk_dictionary(withPlistString plist: String) -> NSDictionary? {
        guard !plist.isEmpty else { return nil }
        guard let data = plist.data(using: .utf8) else { return nil }
        return mk_dictionary(withPlistData: data)
    }
    
    @objc func mk_plistData() -> Data? {
        do {
            return try PropertyListSerialization.data(fromPropertyList: self, format: .binary, options: 0)
        } catch {
            return nil
        }
    }
    
    @objc func mk_plistString() -> String? {
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: self, format: .xml, options: 0)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    @objc func mk_allKeysSorted() -> [Any] {
        return allKeys.sorted { a, b in
            let aStr = "\(a)"
            let bStr = "\(b)"
            return aStr.compare(bStr) == .orderedAscending
        }
    }
    
    @objc func mk_allValuesSortedByKeys() -> [Any] {
        let sortedKeys = mk_allKeysSorted()
        return sortedKeys.compactMap { self[$0] }
    }
    
    @objc func mk_containsObject(forKey key: Any) -> Bool {
        return object(forKey: key) != nil
    }
    
    @objc func mk_entries(forKeys keys: [Any]) -> [AnyHashable: Any] {
        var result: [AnyHashable: Any] = [:]
        for key in keys {
            if let value = object(forKey: key) {
                result[key as! AnyHashable] = value
            }
        }
        return result
    }
    
    @objc func mk_jsonStringEncoded() -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    @objc func mk_jsonPrettyStringEncoded() -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    @objc static func mk_dictionary(withXML xml: Any) -> NSDictionary? {
        // XML parsing implementation would go here
        // This is complex and would require a separate XML parser implementation
        return nil
    }
}

extension NSMutableDictionary {
    @objc func mk_popObject(forKey aKey: Any) -> Any? {
        guard let key = aKey as? NSCopying else { return nil }
        let value = self[key]
        removeObject(forKey: key)
        return value
    }
    
    @objc func mk_popEntries(forKeys keys: [Any]) -> [AnyHashable: Any] {
        var result: [AnyHashable: Any] = [:]
        for key in keys {
            if let nscKey = key as? NSCopying, let value = self[nscKey] {
                result[nscKey as! AnyHashable] = value
                removeObject(forKey: nscKey)
            }
        }
        return result
    }
}

extension NSNumber {
    @MainActor @objc static func mk_number(with string: String) -> NSNumber? {
        let str = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !str.isEmpty else { return nil }
        
        struct Static {
            @MainActor static let dict: [String: Any] = [
                "true": true,
                "yes": true,
                "false": false,
                "no": false,
                "nil": NSNull(),
                "null": NSNull(),
                "<null>": NSNull()
            ]
        }
        
        if let num = Static.dict[str] {
            if num is NSNull { return nil }
            return num as? NSNumber
        }
        
        // hex number
        var sign = 0
        if str.hasPrefix("0x") { sign = 1 }
        else if str.hasPrefix("-0x") { sign = -1 }
        
        if sign != 0 {
            let scanner = Scanner(string: str)
            var num: UInt64 = 0
            if scanner.scanHexInt64(&num) {
                return NSNumber(value: Int64(num) * Int64(sign))
            } else {
                return nil
            }
        }
        
        // normal number
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: string)
    }
}


extension DateFormatter {
    @objc static func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }
    
    @objc static func dateFormatter(withFormat dateFormat: String) -> DateFormatter {
        let formatter = dateFormatter()
        formatter.dateFormat = dateFormat
        return formatter
    }
    
    @objc static func defaultDateFormatter() -> DateFormatter {
        return dateFormatter(withFormat: "yyyy-MM-dd HH:mm:ss")
    }
}

