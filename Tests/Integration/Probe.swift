import DebugMenuKit

@DebugMenuEntry
public struct PROBE_NAME: DebugMenuItem {
    public init() {}
    public var menu: [DebugMenuNode] {
        DebugMenuAction("Distribution probe", identifier: "PROBE_ID") { _ in }
    }
}

@MainActor
public func PROBE_NAMECheck() -> Bool {
    if case .success = DebugMenu.triggerAction(identifier: "PROBE_ID") { return true }
    return false
}
