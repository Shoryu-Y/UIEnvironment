import UIKit

public extension UIViewController {
    var _environmentValues: UIEnvironmentValues? {
        get {
            if let navigationController = self as? EnvironmentNavigationController {
                navigationController.environmentValues
            } else if let navigationController = navigationController as? EnvironmentNavigationController {
                navigationController.environmentValues
            } else {
                nil
            }
        }

        set {
            guard let newValue else { return }

            if let navigationController = self as? EnvironmentNavigationController {
                navigationController.environmentValues = newValue
            } else if let navigationController = navigationController as? EnvironmentNavigationController {
                navigationController.environmentValues = newValue
            }
        }
    }

    @MainActor
    @propertyWrapper
    struct _UIEnvironment<Key: UIEnvironmentKey> {
        private weak var viewController: UIViewController?
        private let keyPath: KeyPath<UIEnvironmentValues, Key.Value>

        public init(
            _ viewController: UIViewController,
            keyPath: KeyPath<UIEnvironmentValues, Key.Value>
        ) {
            self.viewController = viewController
            self.keyPath = keyPath
        }

        public var wrappedValue: Key.Value {
            get { viewController?._environmentValues?[keyPath: keyPath] ?? Key.defaultValue }
            set { viewController?._environmentValues?[Key.self] = newValue }
        }
    }
}
