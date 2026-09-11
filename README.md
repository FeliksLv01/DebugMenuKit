# DebugMenuKit

DebugMenuKit is a lightweight iOS floating debug menu. Modules declare their own `DebugMenuItem` values and can register them automatically with `@DebugMenuEntry`.

## Preview

| Floating button | Debug menu |
| --- | --- |
| <img src="Docs/screenshot1.png" width="260" alt="DebugMenuKit floating button"> | <img src="Docs/screenshot2.png" width="260" alt="DebugMenuKit menu"> |

## Requirements

- iOS 15.0 or later
- Swift 6.0 or later
- Xcode 26 or later

## Installation

### Swift Package Manager

Add this repository as a package dependency and select the `DebugMenuKit` product.

### CocoaPods

```ruby
pod 'DebugMenuKit'
```

The CocoaPods integration loads the macro compiler plugin from `Prebuilt/DebugMenuKitMacros`. This executable is tracked with Git LFS and must be present when publishing a release.

If another Pod target uses `@DebugMenuEntry` through a direct or transitive dependency on DebugMenuKit, copy `Scripts/debug_menu_kit_swift_flags.rb` into your application repository and load it from the Podfile:

```ruby
require_relative 'Scripts/debug_menu_kit_swift_flags'

post_install do |installer|
  inject_debug_menu_kit_swift_flags_if_needed(installer)
end
```

The script adds the compiler-plugin flags only to Pod targets that depend on DebugMenuKit. The application target receives the same flags from the podspec.

## Usage

```swift
import DebugMenuKit

@DebugMenuEntry
struct NetworkDebugMenu: DebugMenuItem {
    var menu: [DebugMenuNode] {
        DebugMenuGroup("Network", identifier: "network") {
            DebugMenuAction("Clear Cache", identifier: "network.clearCache") { _ in
                URLCache.shared.removeAllCachedResponses()
            }

            DebugMenuSwitch(
                "Use Mock API",
                identifier: "network.mockAPI",
                isOn: { MockAPI.shared.isEnabled }
            ) { item in
                MockAPI.shared.isEnabled = item.isOn
            }
        }
    }
}
```

Show the menu from the main actor:

```swift
DebugMenu.show()
```

`show()` automatically calls `registerAll()` and discovers all types annotated with `@DebugMenuEntry`. Conditional registrations can use `DebugMenu.register(NetworkDebugMenu.self)`.

## Menu nodes

- `DebugMenuGroup`: a nestable group.
- `DebugMenuAction`: an action invoked when selected.
- `DebugMenuInfo`: a read-only item with optional detail text.
- `DebugMenuSwitch`: a switch backed by a state provider.
- `DebugMenuSelection`: a single-choice option group.
- `DebugMenuCheckboxGroup`: a multiple-choice option group.

Use stable identifiers for items that are controlled externally or shared between modules. Groups with the same identifier under the same parent are merged; other duplicate identifiers are replaced by the later registration.

The control APIs return `Result` values:

```swift
DebugMenu.triggerAction(identifier: "network.clearCache")
DebugMenu.setSwitch(identifier: "network.mockAPI", isOn: true)
DebugMenu.selectOption(identifier: "api.environment.sit")
DebugMenu.setCheckboxOption(identifier: "debug.modules.network", isOn: true)
```

Search matches titles, pinyin/initials where available, and identifiers.

## Migration from TKDebugMenu

Change the dependency name and import to:

```swift
import DebugMenuKit
```

The main public API names such as `DebugMenu`, `DebugMenuItem`, and `DebugMenuNode` remain unchanged.

## Development

Build the macro executable for CocoaPods with `./build.sh`. Before committing a release, verify the generated executable is stored as a Git LFS object. SwiftPM builds the macro targets from the root package.

## License

DebugMenuKit is released under the MIT License. See [LICENSE](LICENSE).

中文说明：[README.zh-CN.md](README.zh-CN.md)
