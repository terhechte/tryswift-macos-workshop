import Foundation
import AppKit

public class Commiter: NSObject, Codable {
    @objc var name: String?
    @objc var email: String?
    @objc var date: Date?
}

public class Commit: NSObject, Codable {
    @objc var commit: String?
    @objc var subject: String?
    @objc var body: String?
    @objc var commiter: Commiter?
}

public class Repository: NSObject {
    @objc var name: String
    @objc var file: String
    fileprivate init(name: String) {
        self.name = name
        self.file = name
    }
    
    @objc var commits: [Commit] {
        guard let url = Bundle.main.url(forResource: self.file, withExtension: "json") else {
            return []
        }
        guard let commitsJsonData = try? Data(contentsOf: url) else {
            return []
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let commits = try decoder.decode([Commit].self, from: commitsJsonData)
            commits.forEach {
                $0.body = $0.body?.trimmingCharacters(in: .whitespacesAndNewlines)
                $0.subject = $0.subject?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return commits
        } catch _ {
            return []
        }
    }
}

public class CommitModel {
    public let repos: [Repository] = [
        Repository(name: "Vapor"),
        Repository(name: "ReactiveCocoa")
    ]
}
