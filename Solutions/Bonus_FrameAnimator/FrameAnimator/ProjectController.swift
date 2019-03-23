import AppKit

final class ProjectController: NSViewController {
    @IBOutlet var imagesArrayController: NSArrayController?
    @IBOutlet var animationsArrayController: NSArrayController?
    @IBOutlet var framesArrayController: NSArrayController?
    var timer: Timer?
    
    override func awakeFromNib() {
        framesArrayController?.sortDescriptors = [NSSortDescriptor(key: "sortIndex", ascending: false)]
    }
    
    @IBAction func doLoadImages(sender: AnyObject?) {
        guard let window = view.window else { return }
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.allowedFileTypes = ["jpg", "jpeg", "png", "bmp", "tiff"]
        panel.beginSheetModal(for: window) { (response) in
            guard response == NSApplication.ModalResponse.OK else { return }
            let sorted = panel.urls.sorted { $0.lastPathComponent < $1.lastPathComponent }
            self.imagesArrayController?.content = NSMutableArray(array: sorted.map(Image.init))
        }
    }
    
    @IBAction func doAddImages(sender: AnyObject?) {
        guard let images = imagesArrayController?.selectedObjects as? [Image],
            let currentFrames = framesArrayController?.arrangedObjects as? [Frame]
            else { return }
        framesArrayController?.add(contentsOf: images.enumerated().map { (index, image) in
            return Frame(image, sortIndex: index + currentFrames.count )
        })
        framesArrayController?.setSelectionIndex(0)
    }
    
    @IBAction func doTogglePlay(sender: AnyObject?) {
        if let t = self.timer {
            t.invalidate()
        } else {
            schedule()
        }
    }
    
    private func schedule() {
        guard let controller = framesArrayController,
            let currentAnimation = animationsArrayController?.selectedObjects.first as? Animation
            else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(currentAnimation.fps), repeats: false, block: { [weak self] (timer) in
            while true {
                controller.setSelectionIndex(controller.canSelectNext ? controller.selectionIndex + 1 : 0)
                if let frame = controller.selectedObjects.first as? Frame, frame.active {
                    break
                }
            }
            self?.schedule()
        })
    }
}
