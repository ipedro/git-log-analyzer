import Foundation
import GitLibrary

struct OnelineTextReport: Reportable {
    private var _report: HumanReadableReport
    
    init(
        directory: URL,
        items: [URL : [GitLogEntry]],
        includeRules: [String],
        maxCommitsPerFile: Int?
    ) {
        _report = .init(
            directory: directory,
            items: items,
            includeRules: includeRules,
            maxCommitsPerFile: maxCommitsPerFile)
        _report.format = .oneline()
    }
    
    mutating func report() -> String { _report.report() }
}

struct FullTextReport: Reportable {
    private var _report: HumanReadableReport
    
    init(
        directory: URL,
        items: [URL : [GitLogEntry]],
        includeRules: [String],
        maxCommitsPerFile: Int?
    ) {
        _report = .init(
            directory: directory,
            items: items,
            includeRules: includeRules,
            maxCommitsPerFile: maxCommitsPerFile)
        _report.format = .full()
    }
    
    mutating func report() -> String { _report.report() }
}

struct HumanReadableReport: Reportable {
    var directory: URL
    var items: [Item]
    var includeRules: [String]
    var maxCommitsPerFile: Int?
    
    var format: Format!

    init(directory: URL, items: [URL: [GitLogEntry]], includeRules: [String], maxCommitsPerFile: Int?) {
        self.directory = directory
        self.items = items.map { .init(path: $0.relativePath, logs: $1) }
        self.includeRules = includeRules
        self.maxCommitsPerFile = maxCommitsPerFile
    }
    
    struct Format {
        var keys: [GitLogEntry.Key]
        var separator: String = "\n"
        
        static func full() -> Self {
            .init(keys: [
                .hash,
                .author,
                .committer,
                .subject,
                .body])
        }
        
        static func oneline() -> Self {
            .init(keys: [.hash, .subject], separator: " ")
        }
    }
    
    struct Item {
        var path: String
        var logs: [GitLogEntry]
        
        func description(format: Format) -> String {
            var string = "### \(path.split(separator: "/").last!) (\(logs.count) commits)"
            string += "\n\nPath: \(path)"
            if logs.isEmpty { return string }
            string += "\n\nHistory:\n"
            logs.enumerated().forEach { offset, logEntry in
                string += "\n\(offset + 1).\n"
                string += logEntry.description(including: format.keys, separator: format.separator)
                string += "\n"
            }
            return string
        }
    }

    mutating func report() -> String {
"""
# Git Logs
- Date: \(Date().formatted())
- Directory: \(directory.path)
- Include Rules: \(includeRules.joined(separator: ", "))
- Maximum commits per file: \(String(describing: maxCommitsPerFile))
- Total commits indexed: \(Set(items.flatMap(\.logs)).count)

\(items.map { $0.description(format: format) }.joined(separator: "\n"))
"""
    }
}
