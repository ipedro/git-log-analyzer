import XCTest
@testable import FileIndexer

final class FileEnumeratorTests: XCTestCase {
    let testDirectory = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
    
    func testEnumeration() {
        let sut = FileEnumerator(directory: testDirectory) { _ in return true }
        let results = sut.run().map(\.lastPathComponent)
        XCTAssertEqual(results, [
            "FileIndexerTests.swift",
            "FileEnumeratorTests.swift"
        ])
    }
}
