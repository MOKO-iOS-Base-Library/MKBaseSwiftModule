//
//  File.swift
//  MKBaseSwiftModule
//
//  Created by aa on 2025/5/30.
//

import Foundation

// MARK: - MKEncodingNSType
private enum MKEncodingNSType: UInt {
    case unknown = 0
    case string
    case mutableString
    case value
    case number
    case decimalNumber
    case data
    case mutableData
    case date
    case url
    case array
    case mutableArray
    case dictionary
    case mutableDictionary
    case set
    case mutableSet
}

// MARK: - Model Property Meta
private class MKModelPropertyMeta {
    var name: String = ""
    var type: UInt = 0
    var nsType: MKEncodingNSType = .unknown
    var isCNumber: Bool = false
    var cls: AnyClass?
    var genericCls: AnyClass?
    var getter: Selector?
    var setter: Selector?
    var isKVCCompatible: Bool = false
    var isStructAvailableForKeyedArchiver: Bool = false
    var hasCustomClassFromDictionary: Bool = false
    var mappedToKey: String?
    var mappedToKeyPath: [String]?
    var mappedToKeyArray: [Any]?
    var next: MKModelPropertyMeta?
    
    class func meta(with classInfo: Any, propertyInfo: Any, generic: AnyClass?) -> MKModelPropertyMeta {
        let meta = MKModelPropertyMeta()
        // Implementation would mirror the Objective-C version
        return meta
    }
}

// MARK: - Model Meta
private class MKModelMeta {
    var classInfo: Any?
    var mapper: [String: MKModelPropertyMeta] = [:]
    var allPropertyMetas: [MKModelPropertyMeta] = []
    var keyPathPropertyMetas: [MKModelPropertyMeta] = []
    var multiKeysPropertyMetas: [MKModelPropertyMeta] = []
    var keyMappedCount: UInt = 0
    var nsType: MKEncodingNSType = .unknown
    var hasCustomWillTransformFromDictionary: Bool = false
    var hasCustomTransformFromDictionary: Bool = false
    var hasCustomTransformToDictionary: Bool = false
    var hasCustomClassFromDictionary: Bool = false
    
    init(with cls: AnyClass) {
        // Implementation would mirror the Objective-C version
    }
    
    class func meta(with cls: AnyClass) -> MKModelMeta? {
        // Implementation would mirror the Objective-C version
        return nil
    }
}

// MARK: - Model Protocol
@objc public protocol MKModel {
    @objc optional static func mk_modelCustomPropertyMapper() -> [String: Any]
    @objc optional static func mk_modelContainerPropertyGenericClass() -> [String: AnyClass]
    @objc optional static func mk_modelCustomClassForDictionary(_ dictionary: [String: Any]) -> AnyClass?
    @objc optional static func mk_modelPropertyBlacklist() -> [String]
    @objc optional static func mk_modelPropertyWhitelist() -> [String]
    @objc optional func mk_modelCustomWillTransformFromDictionary(_ dictionary: [String: Any]) -> [String: Any]?
    @objc optional func mk_modelCustomTransformFromDictionary(_ dictionary: [String: Any]) -> Bool
    @objc optional func mk_modelCustomTransformToDictionary(_ dictionary: [String: Any]) -> Bool
}

// MARK: - NSObject Extension
extension NSObject {
    // MARK: JSON/Dictionary to Model
    
    @objc public class func mk_model(withJSON json: Any?) -> Self? {
        guard let json = json else { return nil }
        let dictionary: [String: Any]?
        
        if let dict = json as? [String: Any] {
            dictionary = dict
        } else if let string = json as? String {
            dictionary = try? JSONSerialization.jsonObject(with: Data(string.utf8), options: []) as? [String: Any]
        } else if let data = json as? Data {
            dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } else {
            dictionary = nil
        }
        
        return mk_model(with: dictionary)
    }
    
    @objc public class func mk_model(with dictionary: [String: Any]?) -> Self? {
        guard let dictionary = dictionary else { return nil }
        
        let cls = self as NSObject.Type
        var modelCls: AnyClass = cls
        
        if let customCls = (modelCls as? MKModel.Type)?.mk_modelCustomClassForDictionary?(dictionary) {
            modelCls = customCls
        }
        
        let model = modelCls.init()
        if model.mk_modelSet(with: dictionary) {
            return model as? Self
        }
        return nil
    }
    
    // MARK: Model to JSON/Dictionary
    
    @objc public func mk_modelToJSONObject() -> Any? {
        // Implementation would mirror the Objective-C version
        return nil
    }
    
    @objc public func mk_modelToJSONData() -> Data? {
        guard let jsonObject = mk_modelToJSONObject() else { return nil }
        return try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
    
    @objc public func mk_modelToJSONString() -> String? {
        guard let data = mk_modelToJSONData() else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: Model Copy
    
    @objc public func mk_modelCopy() -> Any? {
        // Implementation would mirror the Objective-C version
        return nil
    }
    
    // MARK: NSCoding Support
    
    @objc public func mk_modelEncode(with aCoder: NSCoder) {
        // Implementation would mirror the Objective-C version
    }
    
    @objc public func mk_modelInit(with aDecoder: NSCoder) -> Any? {
        // Implementation would mirror the Objective-C version
        return nil
    }
    
    // MARK: Equality & Hashing
    
    @objc public func mk_modelHash() -> UInt {
        // Implementation would mirror the Objective-C version
        return 0
    }
    
    @objc public func mk_modelIsEqual(_ model: Any?) -> Bool {
        // Implementation would mirror the Objective-C version
        return false
    }
    
    // MARK: Description
    
    @objc public func mk_modelDescription() -> String {
        // Implementation would mirror the Objective-C version
        return ""
    }
    
    // MARK: Dictionary to Model
    
    @objc public func mk_modelSet(withJSON json: Any?) -> Bool {
        guard let json = json else { return false }
        
        let dictionary: [String: Any]?
        if let dict = json as? [String: Any] {
            dictionary = dict
        } else if let string = json as? String {
            dictionary = try? JSONSerialization.jsonObject(with: Data(string.utf8), options: []) as? [String: Any]
        } else if let data = json as? Data {
            dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } else {
            dictionary = nil
        }
        
        return mk_modelSet(with: dictionary)
    }
    
    @objc public func mk_modelSet(with dictionary: [String: Any]?) -> Bool {
        guard let dictionary = dictionary else { return false }
        
        // Implementation would mirror the Objective-C version
        return true
    }
}

// MARK: - NSArray Extension
extension NSArray {
    @objc public class func mk_modelArray(with cls: AnyClass, json: Any?) -> [Any]? {
        guard let json = json else { return nil }
        
        let array: [Any]?
        if let arr = json as? [Any] {
            array = arr
        } else if let string = json as? String {
            array = try? JSONSerialization.jsonObject(with: Data(string.utf8), options: []) as? [Any]
        } else if let data = json as? Data {
            array = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any]
        } else {
            array = nil
        }
        
        return mk_modelArray(with: cls, array: array)
    }
    
    @objc public class func mk_modelArray(with cls: AnyClass, array: [Any]?) -> [Any]? {
        guard let array = array else { return nil }
        
        var result: [Any] = []
        for item in array {
            if let dict = item as? [String: Any], let obj = (cls as? NSObject.Type)?.mk_model(with: dict) {
                result.append(obj)
            }
        }
        return result
    }
}

// MARK: - NSDictionary Extension
extension NSDictionary {
    @objc public class func mk_modelDictionary(with cls: AnyClass, json: Any?) -> [String: Any]? {
        guard let json = json else { return nil }
        
        let dictionary: [String: Any]?
        if let dict = json as? [String: Any] {
            dictionary = dict
        } else if let string = json as? String {
            dictionary = try? JSONSerialization.jsonObject(with: Data(string.utf8), options: []) as? [String: Any]
        } else if let data = json as? Data {
            dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } else {
            dictionary = nil
        }
        
        return mk_modelDictionary(with: cls, dictionary: dictionary)
    }
    
    @objc public class func mk_modelDictionary(with cls: AnyClass, dictionary: [String: Any]?) -> [String: Any]? {
        guard let dictionary = dictionary else { return nil }
        
        var result: [String: Any] = [:]
        for (key, value) in dictionary {
            if let dict = value as? [String: Any], let obj = (cls as? NSObject.Type)?.mk_model(with: dict) {
                result[key] = obj
            }
        }
        return result
    }
}

private class MKNSObjectKVOBlockTarget: NSObject {
    var block: ((Any?, Any?, Any?) -> Void)?
    
    init(block: @escaping (Any?, Any?, Any?) -> Void) {
        self.block = block
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                              of object: Any?,
                              change: [NSKeyValueChangeKey : Any]?,
                              context: UnsafeMutableRawPointer?) {
        guard let block = block,
              let change = change,
              !(change[.notificationIsPriorKey] as? Bool ?? false),
              change[.kindKey] as? UInt == NSKeyValueChange.setting.rawValue else {
            return
        }
        
        let oldValue = change[.oldKey] is NSNull ? nil : change[.oldKey]
        let newValue = change[.newKey] is NSNull ? nil : change[.newKey]
        
        block(object, oldValue, newValue)
    }
}

extension NSObject {
    // MARK: - Associated Objects
    
    @objc public func mk_setAssociateValue(_ value: Any?, withKey key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc public func mk_setAssociateWeakValue(_ value: Any?, withKey key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_ASSIGN)
    }
    
    @objc public func mk_getAssociatedValue(forKey key: UnsafeRawPointer) -> Any? {
        return objc_getAssociatedObject(self, key)
    }
    
    @objc public func mk_removeAssociatedValues() {
        objc_removeAssociatedObjects(self)
    }
    
    // MARK: - Class Name
    
    @objc public class func mk_className() -> String {
        return NSStringFromClass(self)
    }
    
    @objc public func mk_className() -> String {
        return String(cString: class_getName(type(of: self)))
    }
    
    // MARK: - Deep Copy
    
    @objc public func mk_deepCopy() -> Any? {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            return try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSObject.self], from: data)
        } catch {
            print("Deep copy failed: \(error)")
            return nil
        }
    }
    
    @objc public func mk_deepCopyWithArchiver(_ archiver: AnyClass, unarchiver: AnyClass) -> Any? {
        // Implementation would need to use the custom archiver/unarchiver classes
        return nil
    }
    
    // MARK: - KVO Blocks
    
    private struct AssociatedKeys {
        nonisolated(unsafe) static var observerBlocks = "mk_observerBlocks"
    }
    
    private func mk_allObserverBlocks() -> NSMutableDictionary {
        // Define the key as a static variable
        struct Static {
            nonisolated(unsafe) static var key: UInt8 = 0
        }
        
        if let targets = objc_getAssociatedObject(self, &Static.key) as? NSMutableDictionary {
            return targets
        }
        
        let targets = NSMutableDictionary()
        objc_setAssociatedObject(self, &Static.key, targets, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return targets
    }
    
    @objc public func mk_addObserverBlock(forKeyPath keyPath: String, block: @escaping (Any?, Any?, Any?) -> Void) {
        guard !keyPath.isEmpty else { return }
        
        let target = MKNSObjectKVOBlockTarget(block: block)
        let targets = mk_allObserverBlocks()
        var arr = targets[keyPath] as? NSMutableArray
        if arr == nil {
            arr = NSMutableArray()
            targets[keyPath] = arr
        }
        arr?.add(target)
        addObserver(target, forKeyPath: keyPath, options: [.new, .old], context: nil)
    }
    
    @objc public func mk_removeObserverBlocks(forKeyPath keyPath: String) {
        guard !keyPath.isEmpty else { return }
        
        let targets = mk_allObserverBlocks()
        guard let arr = targets[keyPath] as? NSArray else { return }
        
        for target in arr {
            removeObserver(target as! NSObject, forKeyPath: keyPath)
        }
        
        targets.removeObject(forKey: keyPath)
    }
    
    @objc public func mk_removeObserverBlocks() {
        let targets = mk_allObserverBlocks()
        
        for (keyPath, arr) in targets {
            if let keyPath = keyPath as? String, let arr = arr as? NSArray {
                for target in arr {
                    removeObserver(target as! NSObject, forKeyPath: keyPath)
                }
            }
        }
        
        targets.removeAllObjects()
    }
    
    // MARK: - Method Swizzling
    
    @objc public class func mk_swizzleInstanceMethod(_ originalSel: Selector, with newSel: Selector) -> Bool {
        guard let originalMethod = class_getInstanceMethod(self, originalSel),
              let newMethod = class_getInstanceMethod(self, newSel) else {
            return false
        }
        
        class_addMethod(self,
                       originalSel,
                        class_getMethodImplementation(self, originalSel)!,
                       method_getTypeEncoding(originalMethod))
        
        class_addMethod(self,
                       newSel,
                        class_getMethodImplementation(self, newSel)!,
                       method_getTypeEncoding(newMethod))
        
        method_exchangeImplementations(class_getInstanceMethod(self, originalSel)!,
                                     class_getInstanceMethod(self, newSel)!)
        return true
    }
    
    @objc public class func mk_swizzleClassMethod(_ originalSel: Selector, with newSel: Selector) -> Bool {
        guard let cls = object_getClass(self),
              let originalMethod = class_getClassMethod(cls, originalSel),
              let newMethod = class_getClassMethod(cls, newSel) else {
            return false
        }
        
        method_exchangeImplementations(originalMethod, newMethod)
        return true
    }
}
