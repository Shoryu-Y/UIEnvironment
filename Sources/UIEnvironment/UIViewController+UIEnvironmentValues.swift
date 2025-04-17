import UIKit

extension UIViewController {
    /// Sets a specific environment value on the current view controller.
    ///
    /// This updates the environment storage inside the nearest
    /// `UIEnvironmentNavigationController`. Use this to override environment
    /// values for a specific screen.
    ///
    /// - Parameters:
    ///   - keyPath: A writable key path into `UIEnvironmentValues`.
    ///   - value: The new value to assign.
    public func environment<Value: Sendable>(
        _ keyPath: WritableKeyPath<UIEnvironmentValues, Value>,
        _ value: Value,
        fileID: StaticString = #fileID,
        line: UInt = #line,
        column: UInt = #column,
        function: StaticString = #function
    ) {
        #if DEBUG
            if _environmentValues == nil {
                Logger.warning("""
                \(fileID):\(line):\(column):
                ⚠️ Warning: No UIEnvironmentNavigationController found in \(function).
                
                This may indicate that your view controller is not embedded in a UIEnvironmentNavigationController, or that the navigationController property has not been set yet (e.g. during viewDidLoad).
                
                Make sure to embed your view controller in a UIEnvironmentNavigationController (or its subclass), and access environment values only after the navigationController becomes available.
                """)
            }
        #endif
        _environmentValues?[keyPath: keyPath] = value
    }

    /// Internal accessor for the view controller’s current `UIEnvironmentValues`.
    ///
    /// This property walks up the navigation hierarchy to find a
    /// `UIEnvironmentNavigationController`, then returns its current environment values.
    ///
    /// If no compatible navigation controller is found, an empty
    /// `UIEnvironmentValues` instance is returned instead.
    var _environmentValues: UIEnvironmentValues? {
        get {
            if let navigationController = self as? UIEnvironmentNavigationController {
                navigationController.environmentValues
            } else if let navigationController = navigationController as? UIEnvironmentNavigationController {
                navigationController.environmentValues
            } else if let environmentValuesForPresented {
                environmentValuesForPresented
            } else {
                Self.findEnvironmentValuesInParentHierarchy(from: self)
            }
        }

        set {
            guard let newValue else {
                return
            }

            if let navigationController = self as? UIEnvironmentNavigationController {
                navigationController.environmentValues = newValue
            } else if let navigationController = navigationController as? UIEnvironmentNavigationController {
                navigationController.environmentValues = newValue
            }
        }
    }
}
