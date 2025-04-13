import Collections
import Foundation
import UIKit

open class UIEnvironmentNavigationController: UINavigationController {
    private var environmentValuesStack: OrderedDictionary<Int, UIEnvironmentValues>

    private var pendingEnvironmentValues: UIEnvironmentValues?

    var environmentValues: UIEnvironmentValues {
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

    public init(
        rootViewController: UIViewController,
        inheritEnvironmentValuesFrom navigationController: UIEnvironmentNavigationController? = nil,
        _ modifying: ((UIEnvironmentValues) -> UIEnvironmentValues)? = nil
    ) {
        var environmentValues = navigationController?.environmentValues ?? UIEnvironmentValues()
        if let modifying {
            environmentValues = modifying(environmentValues)
        }
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
