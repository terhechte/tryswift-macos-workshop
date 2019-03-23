import Foundation

private let gitreader = Bundle.main.path(forResource: "gitreader", ofType: nil)!
private let lovesyntax = Bundle.main.path(forResource: "lovesyntax", ofType: nil)!

/// Execute a Shell command and read output string from stdout
public func readShellCommandOutput(command: String, inDirectory: String?, completion: @escaping (Data?) -> Void) {
    DispatchQueue.global(qos: .userInteractive).async {
        let process = Process()
        // Execute the shell with the `-c [command]` parameter in order to
        // inherit the shell environment
        process.launchPath = "/bin/sh"
        inDirectory.map { process.currentDirectoryPath = $0 }
        process.arguments = [
            "-c",
            command
        ]
        let output = Pipe()
        process.standardOutput = output
        process.launch()
        
        completion(output.fileHandleForReading.readDataToEndOfFile())
    }
}

/// Retrieve a page of the current git commits
public func retrieveCommits(repo: String, page: String?, count: Int, completion: @escaping (Data?) -> Void) {
    var cmd = "'\(gitreader)' --remote --repo \(repo) --branch \"origin/master\" --page \(count)"
    if let lastCommit = page {
        cmd.append(contentsOf: " --from-commit \(lastCommit)")
    }
    readShellCommandOutput(command: cmd, inDirectory: nil, completion: completion)
}

/// Retrieve a colored HTML Git Diff
public func retrieveDiff(repo: String, commit: String, completion: @escaping (Data?) -> Void) {
    let cmd = "'\(lovesyntax)' --repo \(repo) --commit \(commit)"
    readShellCommandOutput(command: cmd, inDirectory: nil, completion: completion)
}
