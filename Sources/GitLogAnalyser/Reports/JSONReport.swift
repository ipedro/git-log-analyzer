import Foundation
import GitLibrary

struct JSONReport: Reportable, Codable {
    private struct Item: Codable {
        var file: String
        var logs: [GitLogEntry]
    }

    private var created: Date
    private var directory: URL
    private var items: [Item]
    private var includeRules: [String]
    private var maxCommitsPerFile: Int?
    private var totalCommits: Int

    init(directory: URL, items: [URL: [GitLogEntry]], includeRules: [String], maxCommitsPerFile: Int?) {
        created = Date()
        self.directory = directory
        self.items = items.map { .init(file: $0.relativePath, logs: $1) }
        self.includeRules = includeRules
        self.maxCommitsPerFile = maxCommitsPerFile
        totalCommits = Set(self.items.flatMap(\.logs)).count
    }

    mutating func report() -> String {
        guard
            let data = try? Self.encoder.encode(self),
            let description = String(data: data, encoding: .utf8)
        else {
            fatalError("Couldn't parse string")
        }
        return description
    }
    
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}
