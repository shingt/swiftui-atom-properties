import XCTest

@testable import Atoms

final class ModifiedAtomTests: XCTestCase {
    @MainActor
    func testKey() {
        let base = TestAtom(value: 0)
        let modifier = ChangesOfModifier<Int, String>(keyPath: \.description)
        let atom = ModifiedAtom(atom: base, modifier: modifier)

        XCTAssertEqual(atom.key, atom.key)
        XCTAssertEqual(atom.key.hashValue, atom.key.hashValue)
        XCTAssertNotEqual(AnyHashable(atom.key), AnyHashable(modifier.key))
        XCTAssertNotEqual(AnyHashable(atom.key).hashValue, AnyHashable(modifier.key).hashValue)
        XCTAssertNotEqual(AnyHashable(atom.key), AnyHashable(base.key))
        XCTAssertNotEqual(AnyHashable(atom.key).hashValue, AnyHashable(base.key).hashValue)
    }

    @MainActor
    func testValue() async {
        let base = TestStateAtom(defaultValue: "test")
        let modifier = ChangesOfModifier<String, Int>(keyPath: \.count)
        let atom = ModifiedAtom(atom: base, modifier: modifier)
        let context = AtomTestContext()

        do {
            // Initial value
            XCTAssertEqual(context.watch(atom), 4)
        }

        do {
            // Update
            Task {
                context[base] = "testtest"
            }

            await context.waitForUpdate()
            XCTAssertEqual(context.watch(atom), 8)
        }

        do {
            // Override
            context.unwatch(atom)
            context.override(atom) { _ in
                100
            }

            XCTAssertEqual(context.watch(atom), 100)
        }
    }
}
