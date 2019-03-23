import Foundation
import AppKit

public class Repository: NSObject {
    @objc public var name: String
    @objc public var folder: String
    @objc public var commits: [Commit] = []
    
    private let pageCount = 30
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    private var isLoading: Bool = false
    
    public init(name: String, folder: String) {
        self.name = name
        self.folder = folder
    }
    
    public func reload() {
        commits = []
        load()
    }
    
    public func load() {
        guard !isLoading else { return }
        isLoading = true
        retrieveCommits(repo: folder, page: commits.last?.oid, count: pageCount) { (output) in
            guard let commitsJson = output,
                let commits = try? self.decoder.decode([Commit].self, from: commitsJson) else { return }
            DispatchQueue.main.async {
                // Trigger KVO
                self.setValue(self.commits + commits, forKey: "commits")
                self.isLoading = false
            }
        }
    }
}

/// This is decoded from JSON
public class Commiter: NSObject, Codable {
    @objc public var name: String
    @objc public var email: String
}

/// This is decoded from JSON
public class Commit: NSObject, Codable {
    @objc public var oid: String
    @objc public var shortOid: String {
        return String(oid[oid.startIndex..<oid.index(oid.startIndex, offsetBy: 5)])
    }
    @objc public var summary: String
    @objc public var message: String
    @objc public var time: Date
    @objc public var author: Commiter
    @objc public var committer: Commiter
    @objc public var parents: [String]
    
    @objc public var isMerge: Bool {
        return parents.count > 1
    }

    @objc var isBookmarked: Bool {
        get {
            return UserDefaults.standard.bool(forKey: oid)
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: oid)
        }
    }

    public func diff(repo: String, completion: @escaping (String?) -> Void) {
        retrieveDiff(repo: repo, commit: oid) { (data) in
            guard let data = data,
                let diffString = String(data: data, encoding: .utf8)
                else { return completion(nil) }
            DispatchQueue.main.async {
                completion(diffString)
            }
        }
    }
}

