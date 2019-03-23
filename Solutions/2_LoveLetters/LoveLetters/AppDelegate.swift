import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    override init() {
        ValueTransformer.setValueTransformer(GroupingValueTransformer(grouper: { (obj) -> String in
            guard let commiter = obj as? Commiter else { return "Wrong" }
            return (commiter.name ?? "Wrong")
        }), forName: NSValueTransformerName(rawValue: "GroupCommitersByEmailTransformer"))
    }
}
