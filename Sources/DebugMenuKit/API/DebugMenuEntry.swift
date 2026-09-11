/// Registers a `DebugMenuItem` type for automatic runtime discovery.
@attached(member, names: named(_debug_menu_item))
public macro DebugMenuEntry() = #externalMacro(
    module: "DebugMenuKitMacros",
    type: "DebugMenuEntryMacro"
)
