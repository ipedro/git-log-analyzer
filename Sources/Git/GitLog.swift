import Foundation
import TSCBasic

public struct GitLog: Sendable {
    private let git = Git()
    public let format: GitLogFormat
    public let maxCount: Int?
    public let before: String?
    public let after: String?

    private let decoder = GitLogDecoder {
        $0.dateDecodingStrategy = .iso8601
    }
    
    public init(format: GitLogFormat = .json, maxCount: Int?, before: String? = nil, after: String? = nil) {
        self.format = format
        self.maxCount = maxCount
        self.before = before
        self.after = after
    }

    public func follow(_ url: URL) throws -> [GitLogEntry] {
        let output = try _follow(url)
        let rawEntries = try split(output)
        let logEntries = try decoder.decode(rawEntries, stripEmptyProperties: true)
        return logEntries.sorted()
    }

    private func _follow(_ url: URL) throws -> String {
        var arguments: [String?] = ["log"]
        arguments.append("--format=\(format)")
        arguments.append("--follow")
        if let maxCount = maxCount { arguments.append("-\(maxCount)") }
        if let before = before { arguments.append("--before=\(before)") }
        if let after = after { arguments.append("--after=\(after)") }
        arguments.append(url.lastPathComponent)
        return try git.run(arguments.compactMap({ $0 }), url: url)
    }

    private func split(_ output: String) throws -> [String] {
        try output.split(
            separator: format.eofSymbol,
            omittingEmptySubsequences: true)
            .map {
                var string = String($0)
                string = string.trimmingCharacters(in: .whitespacesAndNewlines)
                let sanitizedString = try sanitize(string)
                return sanitizedString
            }
    }

    private func sanitize(_ item: String) throws -> String {
        let regex = try NSRegularExpression(pattern: format.sanitizePattern)

        let results = regex.matches(in: item, range: NSRange(item.startIndex..., in: item))

        var sanitized = item

        for result in results {
            let rawValue = (item as NSString).substring(with: result.range)

            let cleanValue = rawValue
                .replacingOccurrences(of: #"""#, with: "'")
                .replacingOccurrences(of: "\t", with: " ")
                .replacingOccurrences(of: "\\", with: #"\\"#)
                .replacingOccurrences(of: #"/"#, with: #"\/"#)
                .replacingOccurrences(of: "\r", with: #"\r"#)
                .replacingOccurrences(of: "\n", with: #"\n"#)

            sanitized = sanitized.replacingOccurrences(of: rawValue, with: cleanValue)
        }

        sanitized = sanitized
            .replacingOccurrences(of: String(format.quoteSymbol), with: #"""#)

        return sanitized
    }
}
