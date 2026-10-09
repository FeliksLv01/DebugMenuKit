# DebugMenuKit

DebugMenuKit 是一个轻量级的 iOS 悬浮调试菜单库。各业务模块可以声明自己的 `DebugMenuItem`，并通过 `@DebugMenuEntry` 自动注册。

## 效果预览

| 悬浮按钮 | 调试菜单 |
| --- | --- |
| <img src="Docs/screenshot1.png" width="260" alt="DebugMenuKit 悬浮按钮"> | <img src="Docs/screenshot2.png" width="260" alt="DebugMenuKit 调试菜单"> |

## 环境要求

- iOS 15.0 或更高版本
- Swift 6.0 或更高版本
- Xcode 26 或更高版本

## 安装

### Swift Package Manager

在 Xcode 中添加本仓库作为 package dependency，并选择 `DebugMenuKit` product。

使用 `@DebugMenuEntry` 的 target 需要在 Swift 编译参数中启用 `-enable-experimental-feature SymbolLinkageMarkers`。CocoaPods 通过 podspec 和依赖注入脚本提供这些参数。

### CocoaPods

```ruby
pod 'DebugMenuKit'
```

CocoaPods 按产物锁文件下载并缓存 `Prebuilt/DebugMenuKitMacros`，无需 Git LFS。

如果其他 Pod target 通过直接或传递依赖使用 `@DebugMenuEntry`，请把 `Scripts/debug_menu_kit_swift_flags.rb` 和 `Scripts/consumer_macro_flags.rb` 一起复制到应用仓库，并在 Podfile 中加载：

```ruby
require_relative 'Scripts/debug_menu_kit_swift_flags'

post_install do |installer|
  inject_debug_menu_kit_swift_flags_if_needed(installer)
end
```

脚本只会为直接或间接依赖 DebugMenuKit 的 Pod target 注入编译器插件参数；应用 target 使用的同类参数由 podspec 提供。

## 基本用法

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

在主线程上下文展示菜单：

```swift
DebugMenu.show()
```

`show()` 会自动调用 `registerAll()`，发现所有带有 `@DebugMenuEntry` 的类型。需要按条件注册时，可以使用 `DebugMenu.register(NetworkDebugMenu.self)`。

## 菜单节点

- `DebugMenuGroup`：可以嵌套其他节点的分组。
- `DebugMenuAction`：点击后执行的动作。
- `DebugMenuInfo`：只读信息项，可带详情文本。
- `DebugMenuSwitch`：由状态 provider 驱动的开关。
- `DebugMenuSelection`：单选配置组。
- `DebugMenuCheckboxGroup`：多选配置组。

需要通过外部接口控制，或需要跨模块合并的菜单项，请使用稳定的 identifier。同一个 parent 下 identifier 相同的 group 会合并；其他重复 identifier 会由后注册的节点覆盖。

控制 API 返回 `Result`：

```swift
DebugMenu.triggerAction(identifier: "network.clearCache")
DebugMenu.setSwitch(identifier: "network.mockAPI", isOn: true)
DebugMenu.selectOption(identifier: "api.environment.sit")
DebugMenu.setCheckboxOption(identifier: "debug.modules.network", isOn: true)
```

搜索支持标题、可用时的拼音/首字母以及 identifier。

## 从 TKDebugMenu 迁移

修改依赖名称和 import：

```swift
import DebugMenuKit
```

`DebugMenu`、`DebugMenuItem`、`DebugMenuNode` 等主要公开 API 名称保持不变。


## Macro 产物与本地发布

SwiftPM 从源码构建 Macro，不下载预编译文件。CocoaPods 的 `prepare_command` 按 `MacroArtifact.lock.json` 下载唯一的 macOS arm64 插件到 `Prebuilt/DebugMenuKitMacros`。Git 仓库不保存该产物，也不需要 Git LFS。

```sh
bundle install
./build.sh
./verify
```

`./build.sh` 根据宏实现、锁定依赖、构建选项和工具链计算指纹；输入未变时复用原产物。普通 UI/运行时代码或文档修改无需重建。预编译插件仅支持 Apple Silicon；Xcode/Swift 升级需要重新验证。

插件先查询本地文件和 `~/Library/Caches/SwiftMacroArtifacts/v1`，按 SHA256 校验后复用。多个库版本引用同一插件时无需重复下载。可用 `SWIFT_MACRO_CACHE_DIR` 更改缓存目录；下载或校验失败会中止安装。

`./verify` 不发布任何内容，但会运行宏单元测试、库测试、下载缓存测试，以及真实 SwiftPM/CocoaPods iOS 消费工程测试；CocoaPods 包含直接和传递依赖的宏展开及菜单自动发现断言。每次运行的日志、结果包和报告保存在 `.distribution/`。

发布前同步 `MacroDistribution.json` 和 podspec 版本，运行构建并提交源码及产物锁文件，然后执行：

```sh
./release 0.0.2
# 同时发布 CocoaPods spec：
./release 0.0.2 --publish-pod
```

发布要求干净工作区；所有测试不可跳过。流程先验证本地候选，再推送已验证源码并发布/复用 Macro Release，验证真实附件下载，推送库 tag 并重新运行远程双路径测试，最后创建库 Release。失败立即停止，不覆盖 tag 或附件；远程测试失败时 tag 可能已经存在，可在同一提交上重试。

本地 `pod ..., :path => ...` 不运行 `prepare_command`。使用锁定插件时先运行 `ruby Scripts/macro_artifact.rb`；改宏实现时运行 `./build.sh`。插件和 `.distribution/` 都不要提交。

## License

DebugMenuKit 使用 MIT License，详见 [LICENSE](LICENSE)。

English documentation: [README.md](README.md)
