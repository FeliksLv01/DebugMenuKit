import Foundation

@MainActor
public extension DebugMenuItem {
    func DebugMenuGroup(
        _ title: String,
        identifier: String = UUID().uuidString,
        subtitle: String? = nil,
        sortOrder: Int = 0,
        @DebugMenuBuilder children: () -> [DebugMenuNode]
    ) -> DebugMenuNode {
        DebugMenuNode(
            title: title,
            identifier: identifier,
            kind: .group,
            detailText: subtitle,
            sortOrder: sortOrder,
            children: children()
        )
    }

    func DebugMenuAction(
        _ title: String,
        identifier: String = UUID().uuidString,
        subtitle: String? = nil,
        sortOrder: Int = 0,
        action: @escaping (DebugMenuNode) -> Void
    ) -> DebugMenuNode {
        DebugMenuNode(
            title: title,
            identifier: identifier,
            kind: .action(action),
            detailText: subtitle,
            sortOrder: sortOrder
        )
    }

    func DebugMenuInfo(
        _ title: String,
        identifier: String = UUID().uuidString,
        subtitle: String? = nil,
        sortOrder: Int = 0
    ) -> DebugMenuNode {
        DebugMenuNode(
            title: title,
            identifier: identifier,
            kind: .info,
            detailText: subtitle,
            sortOrder: sortOrder
        )
    }

    func DebugMenuSwitch(
        _ title: String,
        identifier: String = UUID().uuidString,
        subtitle: String? = nil,
        isOn: @escaping () -> Bool,
        sortOrder: Int = 0,
        action: @escaping (DebugMenuNode) -> Void
    ) -> DebugMenuNode {
        DebugMenuNode(
            title: title,
            identifier: identifier,
            kind: .toggle(action),
            isOn: isOn(),
            detailText: subtitle,
            sortOrder: sortOrder,
            isOnProvider: isOn
        )
    }

    func DebugMenuCheckboxGroup<Option: Hashable & CaseIterable>(
        _ title: String,
        identifier: String = UUID().uuidString,
        subtitle: String? = nil,
        options: Option.AllCases = Option.allCases,
        selected: @escaping () -> Set<Option>,
        title optionTitle: @escaping (Option) -> String,
        subtitle optionSubtitle: @escaping (Option) -> String? = { _ in nil },
        sortOrder: Int = 0,
        onChange: @escaping (Set<Option>) -> Void
    ) -> DebugMenuNode {
        DebugMenuNode(
            title: title,
            identifier: identifier,
            kind: .checkboxGroup,
            detailText: subtitle,
            sortOrder: sortOrder,
            children: options.enumerated().map { index, option in
                DebugMenuNode(
                    title: optionTitle(option),
                    identifier: "\(identifier).\(option)",
                    kind: .checkboxOption { node in
                        var values = selected()
                        if node.isOn {
                            values.insert(option)
                        } else {
                            values.remove(option)
                        }
                        onChange(values)
                    },
                    isOn: selected().contains(option),
                    detailText: optionSubtitle(option),
                    sortOrder: index,
                    isOnProvider: {
                        selected().contains(option)
                    }
                )
            }
        )
    }

    func DebugMenuSelection<Option: Hashable & CaseIterable>(
        _ title: String,
        identifier: String = UUID().uuidString,
        subtitle: String? = nil,
        options: Option.AllCases = Option.allCases,
        selected: @escaping () -> Option,
        title optionTitle: @escaping (Option) -> String,
        subtitle optionSubtitle: @escaping (Option) -> String? = { _ in nil },
        sortOrder: Int = 0,
        onChange: @escaping (Option) -> Void
    ) -> DebugMenuNode {
        DebugMenuNode(
            title: title,
            identifier: identifier,
            kind: .selectionGroup,
            detailText: subtitle,
            sortOrder: sortOrder,
            children: options.enumerated().map { index, option in
                DebugMenuNode(
                    title: optionTitle(option),
                    identifier: "\(identifier).\(option)",
                    kind: .selectionOption { _ in
                        onChange(option)
                    },
                    isOn: selected() == option,
                    detailText: optionSubtitle(option),
                    sortOrder: index,
                    isOnProvider: {
                        selected() == option
                    }
                )
            }
        )
    }
}
