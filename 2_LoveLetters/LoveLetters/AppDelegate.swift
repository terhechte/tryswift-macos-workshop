import Cocoa

/// This is required to properly detect Bindings Errors at runtime
@objc public final class CCApplication: NSApplication {
    @objc func _crashOnException(_ exception: NSException) {
        print("exception: \(exception)")
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    override init() {
        ValueTransformer.setValueTransformer(GroupingValueTransformer(grouper: { (obj) -> String in
            guard let commiter = obj as? Commiter else { return "Wrong" }
            return (commiter.name ?? "Wrong")
        }), forName: NSValueTransformerName(rawValue: "GroupCommitersByEmailTransformer"))
    }
}
