import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
public struct DebugMenuKitPlugin: CompilerPlugin {
    public init() {}
    public let providingMacros: [Macro.Type] = [DebugMenuEntryMacro.self]
}
