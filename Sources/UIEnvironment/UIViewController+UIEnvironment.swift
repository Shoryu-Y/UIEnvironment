import UIKit

public extension UIViewController {
    var _environmentValues: UIEnvironmentValues {
        get {
            if let navigationController = self as? EnvironmentNavigationController {
                navigationController.environmentValues
            } else if let navigationController = navigationController as? EnvironmentNavigationController {
                navigationController.environmentValues
            } else {
                UIEnvironmentValues()
            }
        }

        set {
            if let navigationController = self as? EnvironmentNavigationController {
                navigationController.environmentValues = newValue
            } else if let navigationController = navigationController as? EnvironmentNavigationController {
                navigationController.environmentValues = newValue
            }
        }
    }

    func environment<Value: Sendable>(
        _ keyPath: WritableKeyPath<UIEnvironmentValues, Value>,
        _ value: Value
    ) {
        _environmentValues[keyPath: keyPath] = value
    }
}
