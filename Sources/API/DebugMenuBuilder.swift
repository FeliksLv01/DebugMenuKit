@resultBuilder
public enum DebugMenuBuilder {
    public static func buildBlock(_ components: DebugMenuNode...) -> [DebugMenuNode] {
        components
    }

    public static func buildArray(_ components: [[DebugMenuNode]]) -> [DebugMenuNode] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [DebugMenuNode]?) -> [DebugMenuNode] {
        component ?? []
    }

    public static func buildEither(first component: [DebugMenuNode]) -> [DebugMenuNode] {
        component
    }

    public static func buildEither(second component: [DebugMenuNode]) -> [DebugMenuNode] {
        component
    }
}
