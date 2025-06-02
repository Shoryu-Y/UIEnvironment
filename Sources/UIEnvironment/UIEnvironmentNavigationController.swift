import Collections
import Foundation
import UIKit

/// A custom `UINavigationController` subclass that manages and propagates
/// environment values (`UIEnvironmentValues`) to its child view controllers.
///
/// This controller stores a stack of `UIEnvironmentValues` associated with each
/// pushed `UIViewController`. When a view controller is pushed, the current
/// environment values are copied forward.
///
/// Use this class (or a subclass) as your navigation controller when you need
/// SwiftUI-style environment propagation in a UIKit-based app.
///
/// - Tip: Use in conjunction with `@UIEnvironment` property wrapper to access environment values.
open class UIEnvironmentNavigationController: UINavigationController {
    var environmentValuesStack: OrderedDictionary<Int, UIEnvironmentValues>

    private var pendingEnvironmentValues: UIEnvironmentValues?

    /// The environment values currently active for the navigation controller.
    ///
    /// When pushing a view controller, this value is automatically forwarded to the
    /// destination. When popping, this value may be temporarily overridden by a pending
    /// value during the transition.
    ///
    /// Use this property only if you need to manually read or update the current
    /// environment state.
    public var environmentValues: UIEnvironmentValues {
        get {
            pendingEnvironmentValues
                ?? environmentValuesStack.values.last
                ?? UIEnvironmentValues()
        }

        set {
            if pendingEnvironmentValues != nil {
                pendingEnvironmentValues = newValue
            } else if let topViewController {
                environmentValuesStack[topViewController.hash] = newValue
            }
        }
    }

    /// Creates a `UIEnvironmentNavigationController` with a root view controller and
    /// optionally inherits or modifies the existing environment values.
    ///
    /// - Parameters:
    ///   - rootViewController: The initial view controller.
    ///   - inheritEnvironmentValuesFrom: Optionally inherit values from another `UIEnvironmentNavigationController`.
    ///   - modify: A closure to modify the inherited values before storing.
    public init(
        rootViewController: UIViewController,
        inheritEnvironmentValuesFrom navigationController: UIEnvironmentNavigationController? = nil,
        modify: ((inout UIEnvironmentValues) -> Void)? = nil
    ) {
        var environmentValues = navigationController?.environmentValues ?? UIEnvironmentValues()
        modify?(&environmentValues)
        environmentValuesStack = [rootViewController.hash: environmentValues]
        super.init(rootViewController: rootViewController)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        environmentValuesStack[viewController.hash] = environmentValues
        super.pushViewController(viewController, animated: animated)
    }

    override open func popViewController(animated: Bool) -> UIViewController? {
        let lastIndex = environmentValuesStack.count - 1
        pendingEnvironmentValues = environmentValuesStack.values[lastIndex - 1]
        return super.popViewController(animated: animated)
    }
}

extension UIEnvironmentNavigationController: UINavigationControllerDelegate {
    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated _: Bool) {
        defer {
            pendingEnvironmentValues = nil
        }

        if let pendingEnvironmentValues {
            environmentValuesStack[viewController.hash] = pendingEnvironmentValues
        }

        if let index = environmentValuesStack.index(forKey: viewController.hash) {
            let popCount = environmentValuesStack.elements.count - (index + 1)
            environmentValuesStack.removeLast(popCount)
        }
    }
}
