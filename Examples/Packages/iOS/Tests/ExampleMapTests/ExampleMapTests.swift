import Atoms
import CoreLocation
import XCTest

@testable import ExampleMap

final class ExampleMapTests: XCTestCase {
    @MainActor
    func testLocationObserverAtom() {
        let atom = LocationObserverAtom()
        let context = AtomTestContext()
        let manager = MockLocationManager()

        context.override(atom) { _ in
            LocationObserver(manager: manager)
        }

        context.watch(atom)

        XCTAssertNotNil(manager.delegate)
        XCTAssertTrue(manager.isUpdatingLocation)

        context.unwatch(atom)

        XCTAssertFalse(manager.isUpdatingLocation)
    }

    @MainActor
    func testCoordinateAtom() {
        let atom = CoordinateAtom()
        let context = AtomTestContext()
        let manager = MockLocationManager()

        context.override(LocationObserverAtom()) { _ in
            LocationObserver(manager: manager)
        }

        manager.location = CLLocation(latitude: 1, longitude: 2)

        XCTAssertEqual(context.watch(atom)?.latitude, 1)
        XCTAssertEqual(context.watch(atom)?.longitude, 2)
    }

    @MainActor
    func testAuthorizationStatusAtom() async {
        let atom = AuthorizationStatusAtom()
        let manager = MockLocationManager()
        let context = AtomTestContext()
        let observer = LocationObserver(manager: manager)

        context.override(LocationObserverAtom()) { _ in
            observer
        }

        manager.authorizationStatus = .authorizedWhenInUse

        XCTAssertEqual(context.watch(atom), .authorizedWhenInUse)

        manager.authorizationStatus = .authorizedAlways

        Task {
            observer.objectWillChange.send()
        }

        await context.waitForUpdate()

        XCTAssertEqual(context.watch(atom), .authorizedAlways)

        observer.objectWillChange.send()
        let didUpdate = await context.waitForUpdate(timeout: 0.1)

        // Should not update if authorizationStatus is not changed.
        XCTAssertFalse(didUpdate)
    }
}
