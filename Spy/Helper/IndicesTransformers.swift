import Foundation

@objc(SpyIndicesAllRoundsTransformer)
final class SpyIndicesAllRoundsTransformer: ValueTransformer {
    static let name = "SpyIndicesAllRoundsTransformer"
    
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let arrayOfArrays = value as? [[Int]] else { return nil }
        let nsArray = arrayOfArrays.map { NSArray(array: $0) }
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: NSArray(array: nsArray),
                                                   requiringSecureCoding: true)
        } catch {
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let allowedClasses = [NSArray.self, NSNumber.self]
            guard let nsArray = try NSKeyedUnarchiver.unarchivedObject(ofClasses: allowedClasses, from: data) as? NSArray,
                  let arrays = nsArray as? [NSArray] else {
                return nil
            }
            return arrays.map { innerArray in
                (innerArray as? [NSNumber])?.map { $0.intValue } ?? []
            }
        } catch {
            print("Failed to reverse transform SpyIndicesAllRoundsTransformer: \(error)")
            return nil
        }
    }
}

@objc(BlamedCivilianIndicesTransformer)
final class BlamedCivilianIndicesTransformer: ValueTransformer {
    static let name = "BlamedCivilianIndicesTransformer"
    
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let intSet = value as? Set<Int> else { return nil }
        let nsArray = NSArray(array: Array(intSet))
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: nsArray,
                                                   requiringSecureCoding: true)
        } catch {
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let allowedClasses = [NSArray.self, NSNumber.self]
            guard let nsArray = try NSKeyedUnarchiver.unarchivedObject(ofClasses: allowedClasses, from: data) as? NSArray,
                  let array = nsArray as? [NSNumber] else {
                return nil
            }
            return Set(array.map { $0.intValue })
        } catch {
            print("Failed to reverse transform BlamedCivilianIndicesTransformer: \(error)")
            return nil
        }
    }
}

@objc(FoundSpyIndicesTransformer)
final class FoundSpyIndicesTransformer: ValueTransformer {
    static let name = "FoundSpyIndicesTransformer"
    
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let intSet = value as? Set<Int> else { return nil }
        let nsArray = NSArray(array: Array(intSet))
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: nsArray,
                                                   requiringSecureCoding: true)
        } catch {
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let allowedClasses = [NSArray.self, NSNumber.self]
            guard let nsArray = try NSKeyedUnarchiver.unarchivedObject(ofClasses: allowedClasses, from: data) as? NSArray,
                  let array = nsArray as? [NSNumber] else {
                return nil
            }
            return Set(array.map { $0.intValue })
        } catch {
            print("Failed to reverse transform FoundSpyIndicesTransformer: \(error)")
            return nil
        }
    }
}

@objc(SpyIndicesTransformer)
final class SpyIndicesTransformer: ValueTransformer {
    static let name = "SpyIndicesTransformer"
    
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let intSet = value as? Set<Int> else { return nil }
        let nsArray = NSArray(array: Array(intSet))
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: nsArray,
                                                   requiringSecureCoding: true)
        } catch {
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let allowedClasses = [NSArray.self, NSNumber.self]
            guard let nsArray = try NSKeyedUnarchiver.unarchivedObject(ofClasses: allowedClasses, from: data) as? NSArray,
                  let array = nsArray as? [NSNumber] else {
                return nil
            }
            return Set(array.map { $0.intValue })
        } catch {
            print("Failed to reverse transform SpyIndicesTransformer: \(error)")
            return nil
        }
    }
} 
