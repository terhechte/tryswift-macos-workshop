import Cocoa

final class EmptySelectionMeans: ValueTransformer {
    
    private let emptyValue: Bool
    
    init(emptyValue: Bool) {
        self.emptyValue = emptyValue
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSNumber.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let v = value as? NSIndexSet else { return nil }
        return NSNumber(booleanLiteral: v.count == 0 ? emptyValue : !emptyValue)
    }
}
