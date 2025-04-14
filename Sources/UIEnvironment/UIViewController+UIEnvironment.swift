import UIKit

extension UIViewController {
    public func environment<Value: Sendable>(
        _ keyPath: WritableKeyPath<UIEnvironmentValues, Value>,
        _ value: Value
    ) {
        _environmentValues[keyPath: keyPath] = value
    }

    var _environmentValues: UIEnvironmentValues {
        get {
            if let navigationController = self as? UIEnvironmentNavigationController {
                navigationController.environmentValues
            } else if let navigationController = navigationController as? UIEnvironmentNavigationController {
                navigationController.environmentValues
            } else {
                UIEnvironmentValues()
            }
        }

        set {
            if let navigationController = self as? UIEnvironmentNavigationController {
                navigationController.environmentValues = newValue
            } else if let navigationController = navigationController as? UIEnvironmentNavigationController {
                navigationController.environmentValues = newValue
            }
        }
    }
}
