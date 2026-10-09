# DebugMenuKit conventions

- Reply in Chinese. Verify personal Git author/committer identity before committing; use English Conventional Commits. New Swift files have no header comments.
- SwiftPM is the only supported integration. Applications import DebugMenuKit; compiler plugins stay in Sources/DebugMenuKitMacros and build from source. Never add CocoaPods, prebuilt macro artifacts, download/cache scripts or LFS rules.
- Keep Package.swift exposing only DebugMenuKit; preserve existing platform and public API behavior. All scripts belong in Scripts/; versioning uses Git tags.
- Preserve macro-emitted Mach-O sections and runtime scanners together. SymbolLinkageMarkers remains this library's consumer configuration; never place it in generic defaults.

## Runtime behavior

- UI and menu state are main-actor isolated.
- Preserve stable identifiers and the documented duplicate-registration behavior.
- Changes to registration, merging, sorting, searching, control APIs, or window lifecycle should include tests where practical.
- Lookin exclusion selectors should remain on all custom debug UI containers.



## Tests and CI

- GitHub Actions is the verification and release gate. Preserve macro tests, all runtime tests and actual macro expansion/registration assertions. Host macro tests are separate because iOS cannot execute compiler-plugin host test bundles.
- python3 Scripts/test.py macros runs host macro tests; python3 Scripts/test.py ios runs the standard package runtime tests. Use Python 3.11+ standard library for automation; no Ruby dependencies, shell wrappers or local release orchestrator.
- Every xcodebuild uses pipefail, tee logs and xcbeautify; check Simulator availability. CI uploads logs and xcresults on success or failure. Stale results never validate new sources.
- Numeric version tags create a library Release only after all CI jobs pass. Never add skip-test options or overwrite existing tags/Releases. Preserve historical versions.
- Use rtk for shell tools, finish with git diff --check, and keep English/Chinese docs synchronized. Never commit generated projects, caches or build output. Do not patch dependency checkouts/generated fixtures to hide failures.
