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

    /// Creates a `UIEnvironmentNavigationController` with a root view controller and
    /// optionally inherits or modifies the existing environment values.
    ///
    /// - Parameters:
    ///   - rootViewController: The initial view controller.
    ///   - inheritEnvironmentValuesFrom: Optionally inherit values from another `UIEnvironmentNavigationController`.
    ///   - modify: A closure to modify the inherited values before storing.
    ///
    public init(
        rootViewController: UIViewController,
        inheritEnvironmentValuesFrom navigationController: UIEnvironmentNavigationController? = nil,
        modify: ((inout UIEnvironmentValues) -> Void)? = nil
    ) {
        var environmentValue = navigationController?.environmentValuesStack.values.last ?? UIEnvironmentValues()
        modify?(&environmentValue)
        environmentValuesStack = [rootViewController.hash: environmentValue]
        relationships = [rootViewController.hash: Relationship()]
        super.init(rootViewController: rootViewController)

        UIViewController.swizzle()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    struct Relationship {
        var children: [Int] = []

        mutating func addChild(_ child: Int) {
            children.append(child)
        }
    }

    private var environmentValuesStack: OrderedDictionary<Int, UIEnvironmentValues>
    private var relationships: [Int: Relationship]
}

extension UIEnvironmentNavigationController {
    func environmentValues(of viewController: UIViewController) -> UIEnvironmentValues? {
        if let environmentValues = environmentValuesStack[viewController.hash] {
            environmentValues
        } else if let parentViewController = viewController.parent {
            environmentValues(of: parentViewController)
        } else {
            nil
        }
    }

    func setEnvironmentValues(
        _ environmentValues: UIEnvironmentValues,
        to viewController: UIViewController
    ) {
        environmentValuesStack[viewController.hash] = environmentValues
        UIEnvironmentNotification.post(with: viewController.hash)

        for childHash in descendants(of: viewController.hash) {
            if environmentValuesStack[childHash] != nil {
                environmentValuesStack[childHash] = environmentValues
                UIEnvironmentNotification.post(with: childHash)
            }
        }

        makeRelationshipUntilAncestor(viewController)
    }

    private func descendants(of parentHash: Int) -> [Int] {
        if let relationShip = relationships[parentHash] {
            return relationShip.children + relationShip.children.flatMap { descendants(of: $0) }
        }
        return []
    }

    private func makeRelationshipUntilAncestor(_ viewController: UIViewController) {
        guard let parent = viewController.parent else {
            return
        }

        if let relationship = relationships[parent.hash] {
            return
        }

        relationships[parent.hash] = Relationship(children: [viewController.hash])
        makeRelationshipUntilAncestor(viewController)
    }
}
