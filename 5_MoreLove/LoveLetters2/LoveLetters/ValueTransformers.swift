import Foundation

/// Returns true if a `IndexSet` selection is empty
/// Can be used as a value transformer on the `hidden` propery of any view
final class HideEmptySelectionValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSNumber.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let v = value as? NSIndexSet else { return nil }
        return NSNumber(booleanLiteral: v.count == 0)
    }
}
