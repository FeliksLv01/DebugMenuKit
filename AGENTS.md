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

## Macro sources and artifacts

1. Public macro declarations belong in `Sources/DebugMenuKit/API` so consumers only import `DebugMenuKit`.
2. Compiler-plugin implementations belong in `Sources/DebugMenuKitMacros`.
3. `DebugMenuKitPlugin` must list every public macro implementation.
4. After changing macro implementation code, run `./build.sh`.
5. Never commit `Prebuilt/`, macro executables, or an LFS endpoint/rule for macro artifacts. SwiftPM must clone and build this package without downloading a prebuilt macro. CocoaPods obtains the executable from the immutable Release URL in `MacroArtifact.lock.json`.
6. Keep the macro-emitted Mach-O section name and `DebugMenuItemScanner` synchronized.

## Runtime behavior

- UI and menu state are main-actor isolated.
- Preserve stable identifiers and the documented duplicate-registration behavior.
- Changes to registration, merging, sorting, searching, control APIs, or window lifecycle should include tests where practical.
- Lookin exclusion selectors should remain on all custom debug UI containers.

## Validation

Use `rtk` for shell commands. Format every `xcodebuild` command through `xcbeautify`:

```sh
rtk proxy bundle install
rtk proxy ./build.sh
rtk proxy ./verify
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

## Distribution and release gates

- `MacroDistribution.json` configures the library and build; its version must match the podspec. `MacroArtifact.lock.json` is checked in and pins the executable URL, input fingerprint, SHA256, architecture, minimum macOS and toolchain. Never use a mutable `latest` URL.
- Runtime/UI/docs/test-only changes reuse the same artifact. Macro sources, package manifest/locked dependencies, build script/options or toolchain changes require a new fingerprint and artifact. Run `./build.sh` and commit its resulting lock before releasing. Do not hand-edit a checksum to bypass validation.
- `./verify` must run distribution/cache tests, host macro unit tests, iOS runtime tests and BOTH real SwiftPM/CocoaPods consumer tests. Download success, `pod lib lint`, or macro compilation alone is not integration validation. Never add a skip-tests release option.
- CocoaPods tests cover application, direct and transitive Pod macro usage and actual runtime discovery. SwiftPM uses a fresh Git candidate and package checkout; it must never run the CocoaPods artifact installer. Simulator availability is checked before testing.
- Artifact caching is keyed by binary SHA256 across library versions. Verify local/cache bytes, serialize writes, install atomically and chmod executable. Failed downloads/checksums fail closed. Default cache is `~/Library/Caches/SwiftMacroArtifacts/v1`; CI/local tests may override `SWIFT_MACRO_CACHE_DIR`.
- `:path` development Pods do not execute `prepare_command`: run `ruby Scripts/macro_artifact.rb` to install a pinned artifact, or `./build.sh` after editing the macro. No implicit source-build fallback.
- `./release X.Y.Z` requires a clean committed worktree and matching config/podspec/lock. It runs all gates, pushes the verified source commit, publishes/reuses an immutable macro asset, verifies its real download, pushes the library tag, re-tests BOTH remote integrations with empty caches, then creates the library Release. `--publish-pod` explicitly adds trunk publication. Merely implementing scripts or running `verify` must not publish anything.
- Existing remote tags/assets must match the source commit/SHA256 on retries. Never overwrite tags/assets or rewrite history. If remote integration fails after tagging, stop before the library Release/trunk; retain evidence and retry the same commit. Never reuse old verification reports as proof of a new run.
- `.distribution/` contains per-run logs, xcresult bundles and JSON reports (including failures); never commit it. All xcodebuild pipelines must use `pipefail`, tee a log and pass through xcbeautify.
- Keep the existing `inject_debug_menu_kit_swift_flags_if_needed` entrypoint compatible. Its companion `consumer_macro_flags.rb` must be copied alongside it. Preserve inherited flags, quote plugin paths, support multiple Pods projects/development Pods and make injection idempotent.
- Default prebuilt support is macOS arm64 only. Keep SwiftSyntax's license in `ThirdPartyNotices/` and attach it to binary releases. Validate binary architecture, minimum macOS and linked library portability.
- CocoaPods/Xcodeproj versions are pinned by Gemfile.lock. Run commands with `rtk`; use `bundle exec` for Ruby distribution tools. Do not mutate generated fixtures or dependency checkouts to make tests pass.
