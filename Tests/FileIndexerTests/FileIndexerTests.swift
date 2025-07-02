import XCTest
@testable import FileIndexer

final class FileIndexerTests: XCTestCase {
    let testDirectory = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
    
    func test_indexFolder_noIncludeRules_IsCorrect() throws {
        var sut = try FileIndexer(directory: testDirectory, includeRules: [], verbose: false)
        let results = sut.run().map(\.lastPathComponent)
        XCTAssertEqual(results, [
            "FileIndexerTests.swift",
            "FileEnumeratorTests.swift"
        ])
    }
    
    func test_indexFolder_multipleIncludeRules_IsCorrect() throws {
        var sut = try FileIndexer(directory: testDirectory, includeRules: ["Indexer", "Enumerator"], verbose: false)
        let results = sut.run().map(\.lastPathComponent)
        XCTAssertEqual(results, [
            "FileIndexerTests.swift",
            "FileEnumeratorTests.swift"
        ])
    }
    
    func test_indexFolder_singleIncludeRule_IsCorrect() throws {
        var sut = try FileIndexer(directory: testDirectory, includeRules: ["Indexer"], verbose: false)
        let results = sut.run().map(\.lastPathComponent)
        XCTAssertEqual(results, [
            "FileIndexerTests.swift"
        ])
    }
    
    func test_indexFolder_withIncludeRules_IsEmpty() throws {
        var sut = try FileIndexer(directory: testDirectory, includeRules: [#"\.storyboard"#], verbose: false)
        let results = sut.run().map(\.lastPathComponent)
        XCTAssertTrue(results.isEmpty)
    }
}
