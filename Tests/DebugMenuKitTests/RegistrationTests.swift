import XCTest
import DebugMenuKit

@DebugMenuEntry
public struct RegistrationProbe: DebugMenuItem {
    public init() {}
    public var menu: [DebugMenuNode] {
        DebugMenuAction("Distribution probe", identifier: "registration") { _ in }
    }
}

@MainActor
public func RegistrationProbeCheck() -> Bool {
    if case .success = DebugMenu.triggerAction(identifier: "registration") { return true }
    return false
}

@MainActor
final class RegistrationTests: XCTestCase {
    func testMacroIsDiscoveredAtRuntime() { XCTAssertTrue(RegistrationProbeCheck()) }
}
