import Cocoa

@objc class SystemProcess: NSObject {

    /// The CPU load of the app
    @objc var cpu: Float

    /// Is the app hidden?
    @objc var isHidden: Bool {
        return app.isHidden
    }

    /// Is the app active?
    @objc var isActive: Bool {
        return app.isActive
    }

    /// The name of the app
    @objc var name: String? {
        return app.localizedName
    }

    /// The bundle identifier of the app
    @objc var bundleIdentifier: String? {
        return app.bundleURL?.absoluteString
    }

    /// The process identifier (pid) of the app
    @objc var processIdentifier: Int {
        return Int(app.processIdentifier)
    }

    /// The icon of the app
    @objc var icon: NSImage? {
        return app.icon
    }

    /// The time when the app was launched
    @objc var launchDate: Date? {
        return app.launchDate
    }

    private let app: NSRunningApplication
    private init(app: NSRunningApplication, cpu: Float?) {
        self.app = app
        self.cpu = cpu ?? 0.0
        super.init()
    }

    /// Hide the app
    @objc func hide() {
        app.hide()
    }

    /// Unhide the app
    @objc func unhide() {
        app.unhide()
    }

    /// Terminate the app
    @objc func terminate() {
        app.terminate()
    }

    /// Force-Terminate the app
    @objc func forceTerminate() {
        app.forceTerminate()
    }

    /// We need equality to make sure the selection stays
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? SystemProcess else { return false }
        return other.processIdentifier == processIdentifier
    }
}

extension SystemProcess {
    /// Return a list of `SystemProcess` entities
    static var processes: [SystemProcess] {
        let tuples = executePs()?.split(separator: "\n")
            .dropFirst()
            .compactMap { line -> (Int, Float)? in
                let comps = line.components(separatedBy: .whitespaces).filter({ $0.count > 0 })
            guard let load = Float(comps[0]) else { return nil }
            guard let pid = Int(comps[1]) else { return nil }
            return (pid, load)
        }
        let map = tuples.map({ Dictionary(uniqueKeysWithValues: $0) }) ?? [:]
        return NSWorkspace.shared.runningApplications.map { app in
            return SystemProcess(app: app, cpu: map[Int(app.processIdentifier)])
        }
    }

    /// Execute the `ps` command to retrieve cpu usage per pid
    static private func executePs() -> String? {
        let psCommand = "ps -axo pcpu,pid"
        /// What to do here?
        return nil
    }
}
