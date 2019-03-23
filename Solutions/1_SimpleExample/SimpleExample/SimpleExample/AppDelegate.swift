import Cocoa

@objc public final class CCApplication: NSApplication {
    @objc func _crashOnException(_ exception: NSException) {
        print("exception: \(exception)")
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var arrayController: NSArrayController!

    @objc dynamic var selectedDeveloper: NSIndexSet? {
        didSet {
            guard let dev = arrayController.selectedObjects.first as? Developer else { return }
            guard let lastChangeTime = dev.lastChange else { return }
            if lastChangeTime < Date(timeIntervalSinceNow: -1 * 3 * 365 * 24 * 60 * 60) {
                let alert = NSAlert()
                alert.addButton(withTitle: "ok")
                alert.informativeText = "Developer probably not working here anymore? Last Edit: \(lastChangeTime)"
                alert.beginSheetModal(for: window, completionHandler: nil)
            }
        }
    }
    
    override init() {
        ValueTransformer.setValueTransformer(EmptySelectionMeans(emptyValue: false), forName: NSValueTransformerName(rawValue: "EmptySelectionMeansFalse"))
        ValueTransformer.setValueTransformer(EmptySelectionMeans(emptyValue: true), forName: NSValueTransformerName(rawValue: "EmptySelectionMeansTrue"))
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        arrayController.content = NSMutableArray(array: Model.developers)
    }
}

