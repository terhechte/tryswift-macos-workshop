import Cocoa

@objc public final class CCApplication: NSApplication {
    @objc func _crashOnException(_ exception: NSException) {
        print("exception: \(exception)")
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    override init() {
        ValueTransformer.setValueTransformer(EmptySelectionMeans(emptyValue: false), forName: NSValueTransformerName(rawValue: "EmptySelectionMeansFalse"))
        ValueTransformer.setValueTransformer(EmptySelectionMeans(emptyValue: true), forName: NSValueTransformerName(rawValue: "EmptySelectionMeansTrue"))
        super.init()
    }
}

