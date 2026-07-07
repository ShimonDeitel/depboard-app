import XCTest
@testable import Depboard

@MainActor
final class DepboardTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testSeedDataLoadedBelowFreeLimit() {
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let before = store.entries.count
        let added = store.add(field1: "Test One", field2: "Test Two", field3: "Test Three")
        XCTAssertTrue(added)
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testAddEntryRespectsFreeLimit() {
        while store.entries.count < Store.freeLimit {
            store.add(field1: "Filler", field2: "Filler", field3: "Filler")
        }
        let result = store.add(field1: "Overflow", field2: "Overflow", field3: "Overflow")
        XCTAssertFalse(result)
        XCTAssertEqual(store.entries.count, Store.freeLimit)
    }

    func testProUserBypassesFreeLimit() {
        store.isPro = true
        while store.entries.count <= Store.freeLimit {
            store.add(field1: "Filler", field2: "Filler", field3: "Filler")
        }
        XCTAssertGreaterThan(store.entries.count, Store.freeLimit)
    }

    func testDeleteEntryRemovesIt() {
        store.add(field1: "ToDelete", field2: "X", field3: "Y")
        let countBefore = store.entries.count
        guard let entry = store.entries.first else { return XCTFail("expected entry") }
        store.delete(entry)
        XCTAssertEqual(store.entries.count, countBefore - 1)
        XCTAssertFalse(store.entries.contains(entry))
    }

    func testUpdateEntryChangesFields() {
        store.add(field1: "Original", field2: "X", field3: "Y")
        guard var entry = store.entries.first else { return XCTFail("expected entry") }
        entry.field1 = "Updated"
        store.update(entry)
        XCTAssertEqual(store.entries.first?.field1, "Updated")
    }

    func testCanAddMoreReflectsLimit() {
        XCTAssertTrue(store.canAddMore)
        while store.entries.count < Store.freeLimit {
            store.add(field1: "Filler", field2: "Filler", field3: "Filler")
        }
        XCTAssertFalse(store.canAddMore)
    }
}
