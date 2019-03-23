import AppKit

final class LoveLetterController: NSViewController {
    @IBOutlet var repoArrayController: NSArrayController?
    @IBOutlet var commitsArrayController: NSArrayController?
    
    let model = CommitModel()

    override func awakeFromNib() {
        self.repoArrayController?.content = model.repos
    }
}
