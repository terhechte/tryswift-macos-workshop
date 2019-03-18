import Cocoa

/// This is required to properly detect Bindings Errors at runtime
@objc public final class CCApplication: NSApplication {
    @objc func _crashOnException(_ exception: NSException) {
        print("exception: \(exception)")
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var arrayController: NSArrayController!

    override init() {
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }
}

