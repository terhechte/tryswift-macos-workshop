import AppKit
import WebKit

private let initialRepositories = [
    ("Snail", "/tmp/repos/Snail"),
    ("SnapKit", "/tmp/repos/SnapKit"),
    ("SwiftyJSON", "/tmp/repos/SwiftyJSON"),
    ("ios-good-practices", "/tmp/repos/ios-good-practices"),
]

final class LoveLetterController: NSViewController {
    
    // MARK: Initial Setup
    
    override func awakeFromNib() {
        reposArrayController?.content = initialRepositories.map { Repository(name: $0.0, folder: $0.1) }
        NotificationCenter.default.addObserver(forName: NSView.boundsDidChangeNotification, object: nil, queue: nil) { [weak self] (_) in
            self?.scrollViewDidScroll()
        }
        scrollView?.contentView.postsBoundsChangedNotifications = true
    }

    // MARK: Interface Builder Outlets

    @IBOutlet var scrollView: NSScrollView?
    @IBOutlet var webView: WebView?

    @IBOutlet var reposArrayController: NSArrayController?
    @IBOutlet var firstCommitsArrayController: NSArrayController?
    @IBOutlet var secondCommitsArrayController: NSArrayController?
    @IBOutlet var thirdCommitsArrayController: NSArrayController?
    
    // MARK: Bindings Properties
    
    @objc var selectedRepositories: IndexSet? {
        didSet {
            (reposArrayController?.selectedObjects.first as? Repository)?.reload()
        }
    }
    
    @objc var selectedCommits: IndexSet? {
        didSet {
            guard let repo = reposArrayController?.selectedObjects.first as? Repository else { return }
            guard let commit = thirdCommitsArrayController?.selectedObjects.first as? Commit else { return }
            commit.diff(repo: repo.folder) { (html) in
                html.map { self.webView?.mainFrame.loadHTMLString($0, baseURL: nil) }
            }
        }
    }
    
    @objc var ignoreMerges: Bool = false {
        didSet {
            // what to do here?
        }
    }
    
    // MARK: Interface Builder Interaction
    
    @IBAction func closeDiffSidebar(_ sender: NSButton?) {
        // what to do here?
    }
    
    // MARK: Private

    private func scrollViewDidScroll() {
        guard let scrollView = self.scrollView, let documentView = scrollView.documentView else { return }
        if scrollView.contentView.bounds.maxY > (documentView.bounds.height - 150) {
            (reposArrayController?.selectedObjects.first as? Repository)?.load()
        }
    }
}
