import XCTest
@testable import Git

final class GitLogTests: XCTestCase {
    func test_follow_success() throws {
        // Given
        let sut = GitLog(maxCount: .none)
        let entries = try sut.follow(URL(fileURLWithPath: #file))
        let initialCommit = try XCTUnwrap(entries.first)
        
        // Then
        XCTAssertEqual(initialCommit.hash.abbreviated, "300458047")
        XCTAssertEqual(initialCommit.hash.description, "3004580476031355eefd8644e862192ec82a7fa9")
        XCTAssertEqual(initialCommit.author.email, "ip4dro@gmail.com")
        XCTAssertEqual(initialCommit.author.name, "Pedro Almeida")
        XCTAssertEqual(initialCommit.author.description, "Pedro Almeida <ip4dro@gmail.com>")
        XCTAssertEqual(initialCommit.committer.email, "noreply@github.com")
        XCTAssertEqual(initialCommit.committer.name, "GitHub")
        XCTAssertEqual(initialCommit.committer.description, "GitHub <noreply@github.com>")
        XCTAssertEqual(initialCommit.body, "* MOBD-2210: Create FileIndexer\r\n\r\n* MOBD-2210: Add Git\r\n\r\nI\'m a body message ;-)\r\n\r\n* Add GitLog test")
        XCTAssertEqual(initialCommit.created.timeIntervalSinceReferenceDate, 687451480)
        XCTAssertNil(initialCommit.notes)
        XCTAssertEqual(initialCommit.parent, "990e3a8a1721b93bd73cfbd1c1b85c5fc519de8d")
        XCTAssertEqual(initialCommit.published.timeIntervalSinceReferenceDate, 687451480)
        XCTAssertNil(initialCommit.signature)
        XCTAssertEqual(initialCommit.subject.description, "MOBD-2210: Add Git 1/2 (#286)")
    }
}
