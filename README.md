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

Targets expanding `@DebugMenuEntry` must enable `-enable-experimental-feature SymbolLinkageMarkers` in their Swift compiler flags.

#
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



## License

DebugMenuKit is released under the MIT License. See [LICENSE](LICENSE).

中文说明：[README.zh-CN.md](README.zh-CN.md)

## Tests and releases

This is a standard SwiftPM package: `Package.swift`, `Sources/` and `Tests/`. SwiftPM is the only supported integration, and macros compile from source. Historical versions remain unchanged.

```sh
bash Scripts/test-macros.sh
bash Scripts/test-ios.sh
```

GitHub Actions runs host macro tests and iOS package tests on pull requests, main updates and version tags. Runtime tests include real macro expansion and automatic registration/database assertions. `xcodebuild` uses pipefail and xcbeautify; logs and xcresults are uploaded even on failure. New numeric version tags create a GitHub Release only after all CI jobs pass. Local release orchestration, CocoaPods and precompiled macro distribution have been removed.
