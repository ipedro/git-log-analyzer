import ArgumentParser
import FileEnumerationLibrary
import Foundation
import GitLibrary
import TSCBasic

struct GitLogAnalyser: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Analyzes the commit git logs of individual files in bulk.")

    @Option(
        help: "The root path",
        completion: .directory,
        transform: Foundation.URL.init(fileURLWithPath:))
    var directory: Foundation.URL

    @Option(
        help: "true/false",
        transform: Bool.init(stringLiteral:))
    var verbose: Bool = false

    @Option(help: "The regex rules to include files")
    var included: [String] = []

    @Option(
        help: .init(ReportOption.allCases.map(\.rawValue).joined(separator: ", ")),
        transform: ReportOption.init(stringLiteral:))
    var report: ReportOption
    
    @Option(help: "Shows only commits before this date (inclusive). Accepts a variety of date formats like YY-MM-DD")
    var before: String?
    
    @Option(help: "Include only commits after this date (inclusive). Accepts a variety of date formats like YY-MM-DD")
    var after: String?
    
    @Option(help: "The maximum number of commits to index per file. Sorted from newest to oldest. For unlimited set zero")
    var maxCommitsPerFile: Int?

    private lazy var indexer = try! FileIndexer(
        directory: directory,
        includeRules: included,
        verbose: verbose)
    
    private lazy var fileURLs = indexer.run()
    
    private lazy var gitLog = GitLog(
        format: .json,
        maxCount: maxCommitsPerFile,
        before: before,
        after: after)
    
    private lazy var queue = OperationQueue()

    mutating func run() throws {
        defer { queue.waitUntilAllOperationsAreFinished() }
        
        let start = Date()
        let reportType = report.type
        let directory = directory
        let included = included
        let maxCommitsPerFile = maxCommitsPerFile
        
        try readFiles() { items in
            var reporter = reportType.init(
                directory: directory,
                items: items,
                includeRules: included,
                maxCommitsPerFile: maxCommitsPerFile
            )

            print()
            print("Generating report...")
            print()

            let report = reporter.report()
            guard let reportData = report.data(using: .utf8) else { throw ReportOuputError(report: report) }
            
            let standardOutput = FileHandle.standardOutput
            try standardOutput.write(contentsOf: reportData)

            print()
            print("Report done!", elapsedTime(since: start))
        }
    }
    
    private mutating func readFiles(handler: @escaping ([URL: [GitLogEntry]]) throws -> ()) rethrows {
        let gitLog = gitLog
        let lock = NSLock()
        let total = fileURLs.count
        let verbose = verbose
        var current = 0
        var result = [URL: [GitLogEntry]]()

        print()
        print("Found \(total) file\(fileURLs.count != 1 ? "s" : "")")
        print()
        
        fileURLs.forEach { fileURL in
            queue.addOperation {
                do {
                    let start = Date()
                    let logs = try gitLog.follow(fileURL)
                    lock.lock()
                    current += 1
                    result[fileURL] = logs.reversed() // oldest -> newest
                    if verbose { print("[\(current)/\(total)]", fileURL.relativePath, elapsedTime(since: start)) }
                    lock.unlock()
                }
                catch {
                    if verbose { print("❌", fileURL.relativePath, "Error:", (error as NSError).localizedDescription) }
                }
            }
        }
        
        queue.addBarrierBlock { try! handler(result) }
    }
}

private func elapsedTime(since date: Date) -> String {
    String(format: "(%.2fs)", Date().timeIntervalSince(date))
}

struct ReportOuputError: LocalizedError {
    let report: String
    var errorDescription: String? { "Couldn't convert the report to data.\n\nReport:\n\n\(report)" }
}
