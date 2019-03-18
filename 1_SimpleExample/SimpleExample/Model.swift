import Cocoa

public class Developer: NSObject {
    @objc var username: String = ""
    @objc var ticketCount: Int = 0
    
    init(_ username: String, ticketCount: Int) {
        self.username = username
        self.ticketCount = ticketCount
        super.init()
    }
}

public struct Model {
    static var developers: [Developer] {
        return [
            Developer("Staltz", ticketCount: 5),
            Developer("Chand", ticketCount: 7),
            Developer("Da luz", ticketCount: 3),
            Developer("Sismanidis", ticketCount: 2),
            Developer("Montonen", ticketCount: 4),
            Developer("Usalj", ticketCount: 3),
            Developer("Röhre", ticketCount: 42)
        ]
    }
}
