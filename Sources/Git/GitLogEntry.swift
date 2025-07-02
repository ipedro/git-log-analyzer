import Foundation

public struct GitLogEntry: Codable, Hashable, Sendable {
    public let author: Contributor
    public let body: String
    public let created: Date
    public let hash: Hash
    public let notes: String
    public let parent: String
    public let published: Date
    public let committer: Contributor
    public let subject: Subject

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.author, forKey: .author)
        try container.encode(self.body, forKey: .body)
        try container.encode(self.created, forKey: .created)
        try container.encode(self.hash, forKey: .hash)
        try container.encode(self.notes, forKey: .notes)
        try container.encode(self.parent, forKey: .parent)
        try container.encode(self.published, forKey: .published)
        try container.encode(self.committer, forKey: .committer)
        try container.encode(self.subject, forKey: .subject)
    }
}

public struct Subject: Codable, Hashable, CustomStringConvertible, Sendable {
    public let description: String
    public let sanitized: String
}

public struct Hash: Codable, Hashable, CustomStringConvertible, Sendable {
    public let description: String
    public let abbreviated: String
}

// MARK: - Contributor

public struct Contributor: Codable, Hashable, CustomStringConvertible, Sendable {
    public let email: String
    public let name: String
    public var description: String { "\(name) <\(email)>" }
}

// MARK: - Comparable

extension GitLogEntry: Comparable {
    public static func < (lhs: GitLogEntry, rhs: GitLogEntry) -> Bool {
        lhs.published < rhs.published
    }
}

// MARK: - CustomStringConvertible

extension GitLogEntry: CustomStringConvertible {
    public enum Key: Hashable, CaseIterable {
        case hash
        case author
        case subject
        case body
        case created
        case hashAbbreviated
        case published
        case committer
        case notes
        case subjectSanitized
        
        var rawValue: String {
            switch self {
            case .hash: return "commit "
            case .author: return "Author: "
            case .subject: return "\n"
            case .body: return "\n"
            case .created: return "Created: "
            case .hashAbbreviated: return "Abbrev. Hash: "
            case .published: return "Published: "
            case .committer: return "Commit: "
            case .notes: return "Notes: "
            case .subjectSanitized: return "Sanitized Subject: "
            }
        }
    }
    
    public func description(
        including keys: [Key],
        prefix: String = "",
        separator: String = "\n",
        dateFormat: Date.FormatStyle = .dateTime,
        ommitEmptyValues: Bool = false
    ) -> String {
        var strings = [String]()
        for key in keys {
            let value = value(for: key, dateFormat: dateFormat)
            if !ommitEmptyValues || ommitEmptyValues && !isEmpty(value) {
                strings.append("\(prefix)\(key.rawValue)\(value)")
            }
        }
        return strings.joined(separator: separator)
    }

    private func isEmpty(_ value: String) -> Bool {
        value.isEmpty || value == "undefined"
    }

    private func value(
        for key: Key,
        dateFormat: Date.FormatStyle
    ) -> String {
        switch key {
        case .author: return author.description
        case .body: return body
        case .created: return dateFormat.format(created)
        case .hash: return hash.description
        case .notes: return notes
        case .published: return dateFormat.format(published)
        case .committer: return committer.description
        case .subjectSanitized: return subject.sanitized
        case .hashAbbreviated: return hash.abbreviated
        case .subject: return subject.description
        }
    }

    public var description: String {
        description(
            including: GitLogEntry.Key.allCases,
            dateFormat: .init(date: .abbreviated, time: .standard),
            ommitEmptyValues: true
        )
    }
}
