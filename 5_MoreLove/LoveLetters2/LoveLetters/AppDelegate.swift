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
        ValueTransformer.setValueTransformer(HideEmptySelectionValueTransformer(),
                                             forName: NSValueTransformerName(rawValue: "IsEmptySelection"))
    }
}

