import Cocoa

@objc public final class TerminatorController: NSViewController {

    /// Hosts an array of `SystemProcess` instances.
    /// You can find a list of the possible actions on an instance
    /// in the `SystemProcess` class
    @IBOutlet var processesArrayController: NSArrayController?
    private var reloadTimer: Timer?

    public override func viewWillAppear() {
        super.viewWillAppear()
        reload()
    }

    // MARK: IB Actions

    @IBAction func terminateAllSelected(sender: AnyObject) {
        terminateAllSelected(force: false)
    }

    @IBAction func forceTerminateAllSelected(sender: AnyObject) {
        terminateAllSelected(force: true)
    }

    // MARK: Private

    private func terminateAllSelected(force: Bool) {
        guard let processes = processesArrayController?.selectedObjects as? [SystemProcess] else { return }
        processes.forEach { process in
            if force {
                process.forceTerminate()
            } else {
                process.terminate()
            }
        }
    }

    private func reload() {
        reloadTimer?.invalidate()
        processesArrayController?.content = SystemProcess.processes
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.reload()
        }
    }
}
