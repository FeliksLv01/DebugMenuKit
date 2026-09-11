import XCTest
@testable import DebugMenuKit

@MainActor
final class DebugMenuKitTests: XCTestCase {
    func testNodeMaintainsParentAndFlattenedOrder() {
        let child = DebugMenuNode(title: "Child", identifier: "child")
        let root = DebugMenuNode(title: "Root", identifier: "root", children: [child])

        XCTAssertTrue(child.parent === root)
        XCTAssertEqual(root.flattened().map(\.identifier), ["root", "child"])
        XCTAssertEqual(child.pathTitles, ["Child"])
    }
}
