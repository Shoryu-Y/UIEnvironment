import Collections
import Foundation
import UIKit

open class EnvironmentNavigationController: UINavigationController, UINavigationControllerDelegate {
    private var environmentValuesStack: OrderedDictionary<Int, UIEnvironmentValues>

    private var pendingEnvironmentValues: UIEnvironmentValues?

    var environmentValues: UIEnvironmentValues {
        get {
            pendingEnvironmentValues
                ?? environmentValuesStack.values.last
                ?? UIEnvironmentValues()
        }

        set {
            guard let topViewController else {
                return
            }
            environmentValuesStack[topViewController.hash] = newValue
        }
    }

    public init(
        rootViewController: UIViewController,
        environmentValues: UIEnvironmentValues? = nil,
        _ modifying: ((UIEnvironmentValues) -> UIEnvironmentValues)? = nil
    ) {
        var environmentValues = environmentValues ?? UIEnvironmentValues()
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
        pendingEnvironmentValues = environmentValuesStack[lastIndex - 1]
        return super.popViewController(animated: animated)
    }

    open func navigationController(
        _: UINavigationController,
        didShow viewController: UIViewController,
        animated _: Bool
    ) {
        if let index = environmentValuesStack.index(forKey: viewController.hash) {
            let popCount = environmentValuesStack.elements.count - (index + 1)
            environmentValuesStack.removeLast(popCount)
        }

        pendingEnvironmentValues = nil
    }
}
