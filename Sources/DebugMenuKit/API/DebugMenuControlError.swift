import Foundation

public enum DebugMenuControlError: Error, Equatable, CustomStringConvertible {
    case itemNotFound(identifier: String)
    case unsupportedKind(identifier: String, expected: String)

    public var description: String {
        switch self {
        case .itemNotFound(let identifier):
            return "Debug menu item not found: \(identifier)"
        case .unsupportedKind(let identifier, let expected):
            return "Debug menu item \(identifier) does not support this operation. Expected: \(expected)"
        }
    }
}
