# DebugMenuKit contribution guide

## Project scope

DebugMenuKit is an iOS-only floating debug menu library. Keep the public API focused on menu declaration, registration, presentation, search, external control, and window lifecycle. Do not add a documentation-generation system or DocC guides unless the project requirements change; the two README files are the primary user documentation.

## Package integrations

1. Swift Package Manager and CocoaPods must compile the same runtime sources under `Sources`.
2. `Package.swift` must expose only the `DebugMenuKit` library product and keep the macro implementation target in the root package.
3. `DebugMenuKit.podspec` must expose the same module name and load `Prebuilt/DebugMenuKitMacros`.
4. Keep `Scripts/debug_menu_kit_swift_flags.rb` compatible with both direct and transitive Pod dependencies.
5. Keep the package name, pod name, README installation examples, release workflow, and version tags consistent.
6. Do not commit generated Xcode projects, workspaces, DerivedData, or SwiftPM build directories.

## Macros and Git LFS

1. Public macro declarations belong in `Sources/DebugMenuKit/API` so consumers only import `DebugMenuKit`.
2. Compiler-plugin implementations belong in `Sources/DebugMenuKitMacros`.
3. `DebugMenuKitPlugin` must list every public macro implementation.
4. After changing macro implementation code, run `./build.sh`.
5. `Prebuilt/DebugMenuKitMacros` must remain a Git LFS object. Check it with `git check-attr filter -- Prebuilt/DebugMenuKitMacros` and `git lfs status` before release.
6. Keep the macro-emitted Mach-O section name and `DebugMenuItemScanner` synchronized.

## Runtime behavior

- UI and menu state are main-actor isolated.
- Preserve stable identifiers and the documented duplicate-registration behavior.
- Changes to registration, merging, sorting, searching, control APIs, or window lifecycle should include tests where practical.
- Lookin exclusion selectors should remain on all custom debug UI containers.

## Validation

Use `rtk` for shell commands. Format every `xcodebuild` command through `xcbeautify`:

```sh
rtk xcodebuild -scheme DebugMenuKit -destination 'generic/platform=iOS' build | xcbeautify
rtk xcodebuild -scheme DebugMenuKit -destination 'platform=iOS Simulator,name=iPhone 17' test | xcbeautify
rtk pod lib lint DebugMenuKit.podspec --allow-warnings
```

Run `./build.sh` whenever macro implementation changes. Run `git diff --check` before handing off changes.

## Documentation policy

- `README.md` is the default English documentation.
- `README.zh-CN.md` is the Simplified Chinese equivalent.
- Keep installation, requirements, public usage, migration notes, and package behavior synchronized in both files.
- Avoid duplicating implementation details in README files; put contributor and release rules here instead.

## Commits

Use English Conventional Commits, for example:

```text
feat(package): add SwiftPM and CocoaPods distribution
fix(window): restore host window after hiding debug menu
```
