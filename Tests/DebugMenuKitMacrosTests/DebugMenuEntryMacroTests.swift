import DebugMenuKitMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class DebugMenuEntryMacroTests: XCTestCase {
    private let testMacros: [String: Macro.Type] = [
        "DebugMenuEntry": DebugMenuEntryMacro.self,
    ]

    func testDebugMenuEntryEmitsDiscoverySectionEntry() {
        assertMacroExpansion(
            """
            @DebugMenuEntry
            struct DemoMenu: DebugMenuItem {
            }
            """,
            expandedSource: """
            struct DemoMenu: DebugMenuItem {

                @section("__DATA_CONST,__debug_menu_kit")
                @used
                private static let _debug_menu_item: @convention(c) () -> UnsafeRawPointer = {
                    unsafeBitCast(DemoMenu.self, to: UnsafeRawPointer.self)
                }
            }
            """,
            macros: testMacros
        )
    }
}
