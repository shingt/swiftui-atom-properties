import XCTest

@testable import Atoms

final class TransactionTests: XCTestCase {
    @MainActor
    func testCommit() {
        let key = AtomKey(TestValueAtom(value: 0))
        var commitCount = 0
        let transaction = Transaction(key: key) {
            commitCount += 1
        }

        XCTAssertEqual(commitCount, 0)
        transaction.commit()
        XCTAssertEqual(commitCount, 1)
        transaction.commit()
        XCTAssertEqual(commitCount, 1)
    }

    @MainActor
    func testAddTermination() {
        let key = AtomKey(TestValueAtom(value: 0))
        let transaction = Transaction(key: key) {}

        XCTAssertTrue(transaction.terminations.isEmpty)
        transaction.addTermination {}
        XCTAssertEqual(transaction.terminations.count, 1)
        transaction.addTermination {}
        XCTAssertEqual(transaction.terminations.count, 2)
    }

    @MainActor
    func testTerminate() {
        let key = AtomKey(TestValueAtom(value: 0))
        var isCommitted = false
        var isTerminationCalled = false
        let transaction = Transaction(key: key) {
            isCommitted = true
        }

        transaction.addTermination {
            isTerminationCalled = true
        }

        XCTAssertFalse(isCommitted)
        XCTAssertFalse(isTerminationCalled)
        XCTAssertFalse(transaction.isTerminated)
        XCTAssertFalse(transaction.terminations.isEmpty)

        transaction.terminate()

        XCTAssertTrue(isCommitted)
        XCTAssertTrue(isTerminationCalled)
        XCTAssertTrue(transaction.isTerminated)
        XCTAssertTrue(transaction.terminations.isEmpty)

        isTerminationCalled = false
        transaction.addTermination {
            isTerminationCalled = true
        }

        XCTAssertTrue(isTerminationCalled)
        XCTAssertTrue(transaction.terminations.isEmpty)
    }
}
