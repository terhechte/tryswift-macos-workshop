import Cocoa

let repository = "/tmp/repos/ios-good-practices"

class Branch: NSObject {
    @objc var name: String
    init(_ name: String) {
        self.name = name
    }
}

extension Branch {
    static var Master = Branch("master")
    static var Develop = Branch("develop")
    static var Integration = Branch("integration")
    static var iOS12 = Branch("iOS12")
}

public class Developer: NSObject {
    @objc var username: String = ""
    @objc var ticketCount: Int = 0
    
    @objc var branches: [Branch] = [.Master]

    var lastChange: Date? {
        let process = Process()
        process.launchPath = "/bin/sh"
        process.currentDirectoryPath = repository
        process.arguments = [
            "-c",
            "git log --format='format:%an|%ct|%cr' | grep -i '\(username.lowercased())' | cut -d '|' -f 2"
        ]
        
        let output = Pipe()
        process.standardOutput = output
        process.launch()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { Double($0) ?? 0 }
            .map { Date(timeIntervalSince1970: $0) }
    }
    
    init(_ username: String, ticketCount: Int, branches: [Branch] = [.Master]) {
        self.username = username
        self.ticketCount = ticketCount
        self.branches = branches
        super.init()
    }

    override init() {
        self.username = "No One"
        super.init()
    }
}

public struct Model {
    static var developers: [Developer] {
        return [
            Developer("Staltz", ticketCount: 5),
            Developer("Chand", ticketCount: 7, branches: [.Master, .Develop, .iOS12]),
            Developer("Da luz", ticketCount: 3, branches: [.Develop, .Integration]),
            Developer("Sismanidis", ticketCount: 2, branches: [.iOS12]),
            Developer("Montonen", ticketCount: 4),
            Developer("Usalj", ticketCount: 3, branches: [.Integration]),
            Developer("Röhre", ticketCount: 42),
        ]
    }
}
