import Foundation

@MainActor
public protocol DebugMenuItem {
    init()

    @DebugMenuBuilder
    var menu: [DebugMenuNode] { get }
}

@MainActor
public final class DebugMenuNode {
    public enum Kind {
        case group
        case selectionGroup
        case selectionOption((DebugMenuNode) -> Void)
        case checkboxGroup
        case checkboxOption((DebugMenuNode) -> Void)
        case info
        case action((DebugMenuNode) -> Void)
        case toggle((DebugMenuNode) -> Void)
    }

    public let identifier: String
    public let kind: Kind
    public let sortOrder: Int

    public var title: String {
        didSet {
            searchKeyword = title.debugMenuSearchKeyword
        }
    }

    public var isOn: Bool
    public var detailText: String?
    public var isHighlighted = false
    public weak var parent: DebugMenuNode?
    public var children: [DebugMenuNode]
    private let isOnProvider: (() -> Bool)?
    public private(set) var searchKeyword: String

    public init(
        title: String,
        identifier: String = UUID().uuidString,
        kind: Kind = .group,
        isOn: Bool = false,
        detailText: String? = nil,
        sortOrder: Int = 0,
        children: [DebugMenuNode] = [],
        isOnProvider: (() -> Bool)? = nil
    ) {
        self.title = title
        self.identifier = identifier
        self.kind = kind
        self.isOn = isOn
        self.detailText = detailText
        self.sortOrder = sortOrder
        self.children = children
        self.isOnProvider = isOnProvider
        self.searchKeyword = title.debugMenuSearchKeyword

        for child in children {
            child.parent = self
        }
    }

    public var pathTitles: [String] {
        var titles: [String] = []
        var current: DebugMenuNode? = self
        while let node = current {
            if node.identifier != "root" {
                titles.insert(node.title, at: 0)
            }
            current = node.parent
        }
        return titles
    }

    public func flattened() -> [DebugMenuNode] {
        [self] + children.flatMap { $0.flattened() }
    }

    public func refreshStateIfNeeded() {
        guard let isOnProvider else { return }
        isOn = isOnProvider()
    }
}
