import ArgumentParser
import FileIndexer
import Foundation
import Git
import TSCBasic

@main
struct GitLogAnalyzer: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Analyzes the commit git logs of individual files in bulk.")

    @Argument(
        help: "The root path",
        completion: .directory,
        transform: Foundation.URL.init(fileURLWithPath:))
    var directory: Foundation.URL

    @Flag
    var verbose: Bool = false

    @Option(help: "The regex rules to include files")
    var included: [String] = []

    @Option(
        help: .init(ReportOption.allCases.map(\.rawValue).joined(separator: ", ")),
        transform: ReportOption.init(stringLiteral:))
    var report: ReportOption = .json

    @Option(help: "Shows only commits before this date (inclusive). Accepts a variety of date formats like YY-MM-DD")
    var before: String?

    @Option(help: "Include only commits after this date (inclusive). Accepts a variety of date formats like YY-MM-DD")
    var after: String?

    @Option(help: "The maximum number of commits to index per file. Sorted from newest to oldest. For unlimited set zero")
    var maxCommitsPerFile: Int?

    private lazy var fileIndexer = FileIndexer(
        directory: directory,
        includeRules: included,
        verbose: verbose
    )

    private mutating func fileURLs() throws -> [URL] {
        try fileIndexer.run()
    }

    private func gitLog() -> GitLog {
        GitLog(
            format: .json,
            maxCount: maxCommitsPerFile,
            before: before,
            after: after
        )
    }

    mutating func run() async throws {
        let start = Date()
        let reportType = report.type
        let directory = directory
        let included = included
        let maxCommitsPerFile = maxCommitsPerFile
        
        let items = try await readFiles()
        
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
    
    private mutating func readFiles() async throws -> [URL: [GitLogEntry]] {
        try await withThrowingTaskGroup(of: (URL, [GitLogEntry]).self) { group in
            let fileURLs = try fileURLs()
            let total = fileURLs.count

            print()
            print("Found \(total) file\(fileURLs.count != 1 ? "s" : "")")
            print()
            var result = [URL: [GitLogEntry]]()
            let gitLog = gitLog()

            // Add tasks for each file URL
            for fileURL in fileURLs {
                group.addTask {
                    let logs = try gitLog.follow(fileURL)
                    return (fileURL, logs.reversed()) // oldest -> newest
                }
            }
            
            // Collect results
            for try await (fileURL, logs) in group {
                result[fileURL] = logs
            }
            
            return result
        }
    }
}

private func elapsedTime(since date: Date) -> String {
    String(format: "(%.2fs)", Date().timeIntervalSince(date))
}

struct ReportOuputError: LocalizedError {
    let report: String
    var errorDescription: String? { "Couldn't convert the report to data.\n\nReport:\n\n\(report)" }
}
