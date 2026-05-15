import UIKit

@MainActor
public enum DebugMenu {
    public static var presentationViewController: UIViewController? {
        DebugAssistiveTouch.shared.presentationViewController
    }

    public static func show() {
        registerAll()
        DebugAssistiveTouch.shared.show()
    }

    public static func hide() {
        DebugAssistiveTouch.shared.hide()
    }

    public static func register(_ itemType: any DebugMenuItem.Type) {
        DebugAssistiveTouch.shared.register(itemType.init().menu)
    }

    public static func registerAll() {
        DebugMenuAutoRegistrar.registerAll()
    }

    @discardableResult
    public static func triggerAction(identifier: String) -> Result<Void, DebugMenuControlError> {
        registerAll()
        return DebugAssistiveTouch.shared.triggerAction(identifier: identifier)
    }

    @discardableResult
    public static func setSwitch(identifier: String, isOn: Bool) -> Result<Void, DebugMenuControlError> {
        registerAll()
        return DebugAssistiveTouch.shared.setSwitch(identifier: identifier, isOn: isOn)
    }

    @discardableResult
    public static func selectOption(identifier: String) -> Result<Void, DebugMenuControlError> {
        registerAll()
        return DebugAssistiveTouch.shared.selectOption(identifier: identifier)
    }

    @discardableResult
    public static func setCheckboxOption(identifier: String, isOn: Bool) -> Result<Void, DebugMenuControlError> {
        registerAll()
        return DebugAssistiveTouch.shared.setCheckboxOption(identifier: identifier, isOn: isOn)
    }
}
