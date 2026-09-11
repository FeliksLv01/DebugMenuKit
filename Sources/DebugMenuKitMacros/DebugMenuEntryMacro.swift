import SwiftSyntax
import SwiftSyntaxMacros

public struct DebugMenuEntryMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let typeName = declaration.debugMenuTypeName else { throw DebugMenuEntryMacroError.notANominalType }
        let conforms = declaration.inheritanceClause?.inheritedTypes.contains { inheritedType in
            inheritedType.type.as(IdentifierTypeSyntax.self)?.name.text == "DebugMenuItem"
                || inheritedType.type.as(MemberTypeSyntax.self)?.name.text == "DebugMenuItem"
        } ?? false
        guard conforms else { throw DebugMenuEntryMacroError.missingDebugMenuItemConformance }
        return ["""
        @section("__DATA_CONST,__debug_menu_kit")
        @used
        private static let _debug_menu_item: @convention(c) () -> UnsafeRawPointer = {
            unsafeBitCast(\(raw: typeName).self, to: UnsafeRawPointer.self)
        }
        """]
    }
}

private extension DeclGroupSyntax {
    var debugMenuTypeName: String? {
        if let declaration = self.as(StructDeclSyntax.self) { return declaration.name.text }
        if let declaration = self.as(ClassDeclSyntax.self) { return declaration.name.text }
        return nil
    }
}

enum DebugMenuEntryMacroError: Error, CustomStringConvertible {
    case notANominalType
    case missingDebugMenuItemConformance

    var description: String {
        switch self {
        case .notANominalType: return "@DebugMenuEntry can only be applied to a struct or class."
        case .missingDebugMenuItemConformance: return "@DebugMenuEntry requires the type to conform to DebugMenuItem."
        }
    }
}
