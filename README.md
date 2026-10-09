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

Targets expanding `@DebugMenuEntry` must enable `-enable-experimental-feature SymbolLinkageMarkers` in their Swift compiler flags. CocoaPods supplies these flags through the podspec and consumer helper.

### CocoaPods

```ruby
pod 'DebugMenuKit'
```

CocoaPods downloads and caches `Prebuilt/DebugMenuKitMacros` using the pinned artifact lock; Git LFS is not required.

If another Pod target uses `@DebugMenuEntry` through a direct or transitive dependency on DebugMenuKit, copy both `Scripts/debug_menu_kit_swift_flags.rb` and `Scripts/consumer_macro_flags.rb` into your application repository and load it from the Podfile:

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


## Macro artifacts and local releases

SwiftPM builds macros from source and never downloads the prebuilt executable. CocoaPods runs `prepare_command` to install the single macOS arm64 plugin pinned by `MacroArtifact.lock.json`. Generated executables are ignored, not stored in Git or LFS.

```sh
bundle install
./build.sh
./verify
```

The build fingerprint covers macro sources, locked dependencies, build options and the toolchain. Runtime/UI, documentation and test-only changes reuse the artifact. Prebuilts support Apple Silicon only; toolchain upgrades require verification.

The installer validates local bytes, then a shared SHA256-keyed cache at `~/Library/Caches/SwiftMacroArtifacts/v1`, then downloads. Library versions sharing one artifact reuse the cache. Override `SWIFT_MACRO_CACHE_DIR` when needed. Download and checksum failures stop installation.

`./verify` publishes nothing. It always runs macro unit tests, library tests, distribution/cache tests and real SwiftPM/CocoaPods iOS consumer integration tests. CocoaPods tests include direct/transitive macro consumers and runtime menu discovery. Logs, xcresult bundles and JSON reports live under `.distribution/`.

Synchronize the version in the distribution config and podspec, build and commit the artifact lock, then run:

```sh
./release 0.0.2
# Also publish the podspec:
./release 0.0.2 --publish-pod
```

Release requires a clean committed worktree and never skips tests. It verifies a local candidate, pushes verified sources, publishes/reuses the immutable macro Release, verifies hosted downloads, pushes the library tag, repeats both remote integrations with fresh caches, then creates the library Release. Failures stop publication; tags/assets are never overwritten. A failed remote test can leave the tag in place; retry the same commit.

Development Pods using `:path` do not run `prepare_command`. Run `ruby Scripts/macro_artifact.rb` for a pinned artifact, or `./build.sh` after changing macro implementation. Never commit generated artifacts or verification output.

## License

DebugMenuKit is released under the MIT License. See [LICENSE](LICENSE).

中文说明：[README.zh-CN.md](README.zh-CN.md)
