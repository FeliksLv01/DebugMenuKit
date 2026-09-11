import Foundation

@MainActor
enum DebugMenuAutoRegistrar {
    private static let _performRegistration: Void = {
        let itemTypes = DebugMenuItemScanner.scan()
        for itemType in itemTypes {
            DebugAssistiveTouch.shared.register(itemType.init().menu)
        }
    }()

    static func registerAll() {
        _ = _performRegistration
    }
}
