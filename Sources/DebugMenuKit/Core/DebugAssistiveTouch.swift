import Foundation
import UIKit

@MainActor
final class DebugAssistiveTouch {
    static let shared = DebugAssistiveTouch()

    let rootNode = DebugMenuNode(title: "root", identifier: "root")

    private var window: DebugAssistiveTouchWindow?
    private var floatingView: DebugAssistiveTouchFloatingView?

    private init() {}

    var presentationViewController: UIViewController? {
        hostTopViewController()
    }

    var hostRootViewController: UIViewController? {
        hostWindow()?.rootViewController
    }

    func show() {
        showFloatingView()
    }

    func expand(from shrinkFrame: CGRect) {
        guard let windowScene = currentWindowScene() else {
            return
        }

        let window: DebugAssistiveTouchWindow
        if let existingWindow = self.window {
            window = existingWindow
        } else {
            window = DebugAssistiveTouchWindow(windowScene: windowScene, touch: self)
            window.windowLevel = .alert + 1
            window.onDidShrink = { [weak self] in
                self?.showFloatingView()
            }
            self.window = window
        }

        floatingView?.isHidden = true
        window.expand(from: shrinkFrame)
    }

    func hide() {
        window?.hide()
        floatingView?.removeFromSuperview()
        floatingView = nil
    }

    func register(_ items: [DebugMenuNode]) {
        append(items, to: rootNode)
    }

    private func showFloatingView() {
        guard let hostWindow = hostWindow() else {
            return
        }

        let floatingView: DebugAssistiveTouchFloatingView
        if let existingView = self.floatingView {
            floatingView = existingView
        } else {
            floatingView = DebugAssistiveTouchFloatingView(touch: self)
            self.floatingView = floatingView
        }

        if floatingView.superview !== hostWindow {
            floatingView.removeFromSuperview()
            floatingView.frame = hostWindow.bounds
            floatingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hostWindow.addSubview(floatingView)
        }

        floatingView.isHidden = false
        floatingView.setNeedsLayout()
        floatingView.layoutIfNeeded()
    }

    private func hostTopViewController() -> UIViewController? {
        topViewController(of: hostWindow()?.rootViewController)
    }

    private func hostWindow() -> UIWindow? {
        guard let windowScene = currentWindowScene() else {
            return nil
        }

        let visibleHostWindows = windowScene.windows.filter { candidate in
            candidate !== window
                && !candidate.isHidden
                && candidate.alpha > 0
                && candidate.windowLevel == .normal
                && candidate.rootViewController != nil
        }
        return visibleHostWindows.first { $0.isKeyWindow } ?? visibleHostWindows.first
    }

    private func currentWindowScene() -> UIWindowScene? {
        let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return windowScenes.first { $0.activationState == .foregroundActive }
            ?? windowScenes.first { $0.activationState == .foregroundInactive }
            ?? windowScenes.first
    }

    private func topViewController(of viewController: UIViewController?) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            return topViewController(of: navigationController.visibleViewController)
        }

        if let tabBarController = viewController as? UITabBarController {
            return topViewController(of: tabBarController.selectedViewController)
        }

        if let presentedViewController = viewController?.presentedViewController,
           !presentedViewController.isBeingDismissed {
            return topViewController(of: presentedViewController)
        }

        return viewController
    }

    func search(_ text: String) -> [DebugAssistiveTouchSearchResult] {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else {
            return []
        }

        return rootNode.flattened()
            .filter { node in
                node !== rootNode
                    && (node.searchKeyword.localizedCaseInsensitiveContains(query)
                        || node.identifier.localizedCaseInsensitiveContains(query))
            }
            .map { node in
                DebugAssistiveTouchSearchResult(
                    node: node,
                    pathText: node.pathTitles.dropLast().joined(separator: " > ")
                )
            }
    }

    private func append(_ nodes: [DebugMenuNode], to parent: DebugMenuNode) {
        nodes.forEach { node in
            if let existingIndex = parent.children.firstIndex(where: { $0.identifier == node.identifier }) {
                let existingNode = parent.children[existingIndex]
                switch (existingNode.kind, node.kind) {
                case (.group, .group):
                    append(node.children, to: existingNode)
                default:
                    node.parent = parent
                    parent.children[existingIndex] = node
                }
            } else {
                node.parent = parent
                parent.children.append(node)
            }
        }
        parent.children.sort {
            if $0.sortOrder != $1.sortOrder {
                return $0.sortOrder < $1.sortOrder
            }
            return $0.title.localizedStandardCompare($1.title) == .orderedAscending
        }
    }

    func triggerAction(identifier: String) -> Result<Void, DebugMenuControlError> {
        guard let node = node(identifier: identifier) else {
            return .failure(.itemNotFound(identifier: identifier))
        }

        guard case .action(let action) = node.kind else {
            return .failure(.unsupportedKind(identifier: identifier, expected: "action"))
        }

        action(node)
        return .success(())
    }

    func setSwitch(identifier: String, isOn: Bool) -> Result<Void, DebugMenuControlError> {
        guard let node = node(identifier: identifier) else {
            return .failure(.itemNotFound(identifier: identifier))
        }

        guard case .toggle(let action) = node.kind else {
            return .failure(.unsupportedKind(identifier: identifier, expected: "switch"))
        }

        node.refreshStateIfNeeded()
        node.isOn = isOn
        action(node)
        return .success(())
    }

    func selectOption(identifier: String) -> Result<Void, DebugMenuControlError> {
        guard let node = node(identifier: identifier) else {
            return .failure(.itemNotFound(identifier: identifier))
        }

        guard case .selectionOption(let action) = node.kind else {
            return .failure(.unsupportedKind(identifier: identifier, expected: "selection option"))
        }

        action(node)
        node.parent?.children.forEach { $0.refreshStateIfNeeded() }
        return .success(())
    }

    func setCheckboxOption(identifier: String, isOn: Bool) -> Result<Void, DebugMenuControlError> {
        guard let node = node(identifier: identifier) else {
            return .failure(.itemNotFound(identifier: identifier))
        }

        guard case .checkboxOption(let action) = node.kind else {
            return .failure(.unsupportedKind(identifier: identifier, expected: "checkbox option"))
        }

        node.refreshStateIfNeeded()
        node.isOn = isOn
        action(node)
        return .success(())
    }

    private func node(identifier: String) -> DebugMenuNode? {
        rootNode.flattened().first { $0.identifier == identifier }
    }
}
