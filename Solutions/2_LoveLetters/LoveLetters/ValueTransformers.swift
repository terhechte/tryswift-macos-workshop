import Foundation

class GroupedValues: NSObject {
    @objc var firstGrouped: NSObjectProtocol?
    @objc var groupedBy: String?
    @objc var count: Int
    init(firstGrouped: NSObjectProtocol, groupedBy: String, count: Int) {
        self.firstGrouped = firstGrouped
        self.groupedBy = groupedBy
        self.count = count
    }
}

@objc class GroupingValueTransformer: ValueTransformer {
    var grouper: (NSObjectProtocol) -> String
    init(grouper: @escaping (NSObjectProtocol) -> String) {
        self.grouper = grouper
    }

    open override class func transformedValueClass() -> AnyClass {
        return GroupedValues.self
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? [NSObjectProtocol] else { return nil }
        let grouped = [String: [NSObjectProtocol]](grouping: value, by: grouper)
        return grouped.compactMap({ (entries: (key: String, value: [NSObjectProtocol])) -> GroupedValues? in
            guard value.count > 0 else { return nil }
            return GroupedValues(firstGrouped: entries.value[0], groupedBy: entries.key, count: entries.value.count)
        })
    }
}
