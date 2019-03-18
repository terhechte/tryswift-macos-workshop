import Foundation

final class Animation: NSObject {
    @objc var name: String?
    @objc var fps: Int = 25
    @objc var frames: [Frame] = []
    override init() {
        self.name = "New Animation"
        super.init()
    }
}

class Image: NSObject {
    @objc var name: String?
    @objc var image: URL?
    init(_ url: URL) {
        self.name = url.lastPathComponent
        self.image = url
        super.init()
    }
}

final class Frame: Image {
    @objc var active: Bool = true
    @objc var sortIndex: Int = 0
    init(_ image: Image, sortIndex: Int) {
        super.init(image.image!)
    }
}
