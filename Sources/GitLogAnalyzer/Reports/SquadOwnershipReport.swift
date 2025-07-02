import Foundation
import Git
import TSCBasic

struct SquadOwnershipReport: Reportable {
    let directory: URL
    let items: [URL: [GitLogEntry]]
    let includedFiles: [String]
    let maxCommitsPerFile: Int?
    
    init(directory: URL, items: [URL : [GitLogEntry]], includeRules: [String], maxCommitsPerFile: Int?) {
        self.directory = directory
        self.items = items
        self.includedFiles = includeRules
        self.maxCommitsPerFile = maxCommitsPerFile
    }
    
    private lazy var fileOwnership: [URL: Ownership] = items.keys.reduce(into: [:]) { dictionary, url in
        dictionary[url] = Ownership(extractSquads(from: url))
    }
    
    private lazy var unownedFiles: [URL] = {
        let allFiles = Set(items.keys)
        let ownedFiles = Set(fileOwnership.keys)
        let unownedFiles = allFiles.subtracting(ownedFiles)
        return Array(unownedFiles)
    }()
    
    mutating private func extractSquads(from url: URL) -> CountedSet<String> {
        let regex = try! RegEx(pattern: #"(([A-Z]+)-\d+)(?=\W)"#)
        var countedSet = CountedSet<String>()
        
        guard let logEntries = items[url] else { return countedSet }
        
        logEntries.forEach { logEntry in
            let matchGroups = regex.matchGroups(in: logEntry.subject.description)
            guard let firstGroup = matchGroups.first else { return }
            guard firstGroup.count == 2 else { return }
            let match = firstGroup[1]
            countedSet.insert(match)
        }
        return countedSet
    }
    
    mutating func allSquads() -> Set<String> {
        Set(fileOwnership.values.flatMap(\.set.members))
    }
    
    mutating func report() -> String {
"""
# Squad Ownership Report
- Date: \(Date().formatted())
- Directory: \(directory.path)
- Files Query: \(includedFiles.map { "\"\($0)\"" }.joined(separator: ", "))
- Files with squad: \(fileOwnership.count) / \(items.count)

## Files
\(fileOwnership.reduce(into: "") { partialResult, element in
    let (url, ownership) = element
    partialResult += [
        lastModifiedDate(of: url),
        url.relativePath,
        ownership.description
    ].joined(separator: ", ") + "\n"
})
\(unownedFiles.isEmpty ? "" : "\n\n## \(unownedFiles.count) Unowned Files\n\(unownedFiles.map({ "- \($0.relativePath)" }).joined(separator: "\n"))")
"""
    }
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter
    }()
    
    private func lastModifiedDate(of url: URL) -> String {
        guard let date = items[url]?.map(\.published).max() else { return "No date" }
        return Self.dateFormatter.string(from: date)
    }
}

extension SquadOwnershipReport {
    struct Ownership: CustomStringConvertible {
        let set: CountedSet<String>
                
        private static let percentFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            formatter.maximumFractionDigits = .zero
            return formatter
        }()
        
        init?(_ set: CountedSet<String>) {
            guard !set.isEmpty else { return nil }
            self.set = set
        }
        
        var description: String {
            guard let maxCount = set.maxCount else { return "Undefined" }
            let totalCount = set.totalCount
            let squadNames = set.members
            
            var index = maxCount
            
            var components = [String]()
            
            while index >= .zero {
                for squadName in squadNames where set.count(of: squadName) == index {
                    let ratio = Float(index) / Float(totalCount)
                    components.append("\(squadName), \(ratio.formatted(.percent))")
                }
                index -= 1
            }
            
            return components.joined(separator: ", ")
        }
    }
}
