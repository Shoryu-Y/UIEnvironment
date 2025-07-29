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
        var environmentValues = navigationController?.environmentValuesStack.values.last ?? UIEnvironmentValues()
        modify?(&environmentValues)
        environmentValuesStack = [rootViewController.hash: environmentValues]
        super.init(rootViewController: rootViewController)

        UIViewController.swizzle()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var environmentValuesStack: OrderedDictionary<Int, UIEnvironmentValues>

    private var familyTree: [Int: FamilyRelationship] = [:]

    override open func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        environmentValuesStack[viewController.hash] = environmentValuesStack.values.last ?? UIEnvironmentValues()
        super.pushViewController(viewController, animated: animated)
    }
}

extension UIEnvironmentNavigationController {
    struct FamilyRelationship {
        var children: Set<Int>
        var environmentValues: UIEnvironmentValues

        mutating func addChild(_ child: Int) {
            children.insert(child)
        }

        mutating func removeChild(_ child: Int) {
            if let index = children.firstIndex(of: child) {
                children.remove(at: index)
            }
        }

        mutating func update(_ newValue: UIEnvironmentValues) {
            environmentValues = newValue
        }
    }

    private func descendants(of parentHash: Int) -> [Int] {
        if let relationShip = familyTree[parentHash] {
            return relationShip.children + relationShip.children.flatMap { descendants(of: $0) }
        }
        return []
    }

    func environmentValues(of viewController: UIViewController) -> UIEnvironmentValues {
        if let environmentValues = environmentValuesStack[viewController.hash] {
            environmentValues
        } else if let familyRelationship = familyTree[viewController.hash] {
            familyRelationship.environmentValues
        } else {
            UIEnvironmentValues()
        }
    }

    func setEnvironmentValues(
        _ environmentValues: UIEnvironmentValues,
        to viewController: UIViewController
    ) {
        let hash = viewController.hash

        switch (environmentValuesStack[hash], familyTree[hash]) {
        case (.none, .none):
            // pushによって初めてUIViewControllerがnavigationStackに積まれるパターン。
            environmentValuesStack[hash] = environmentValues
            familyTree[hash] = FamilyRelationship(
                children: [],
                environmentValues: environmentValues
            )

        case (.some, .none):
            // おそらくあり得ないパターン。
            // 念の為に`environmentValuesStack`と`familyTree`どちらも更新する。
            environmentValuesStack[hash] = environmentValues
            familyTree[hash] = FamilyRelationship(
                children: [],
                environmentValues: environmentValues
            )

        case var (.none, .some(relationship)):
            // childViewControllerに対してenvironmentValueを設定するパターン。
            relationship.update(environmentValues)
            familyTree.updateValue(relationship, forKey: hash)

        case var (.some, .some(relationship)):
            // navigationStackに既に積まれているUIViewControllerのenvironmentValueを設定するパターン。
            environmentValuesStack[hash] = environmentValues
            relationship.update(environmentValues)
            familyTree.updateValue(relationship, forKey: hash)
        }

        for child in descendants(of: hash) {
            if var familyRelationship = familyTree[child] {
                familyRelationship.update(environmentValues)
                familyTree.updateValue(familyRelationship, forKey: child)
            }
        }
    }

    func appendRelationship(
        viewController: UIViewController,
        with childViewController: UIViewController
    ) {
        let parentHash = viewController.hash
        let childHash = childViewController.hash

        familyTree[childHash] = FamilyRelationship(
            children: [],
            environmentValues: environmentValues(of: viewController)
        )

        if var relationship = familyTree[parentHash] {
            relationship.addChild(childHash)
            familyTree.updateValue(relationship, forKey: parentHash)
        } else {
            familyTree[parentHash] = FamilyRelationship(
                children: [childHash],
                environmentValues: environmentValues(of: viewController)
            )
        }
    }
}

extension UIEnvironmentNavigationController: UINavigationControllerDelegate {
    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated _: Bool) {
        guard let index = environmentValuesStack.index(forKey: viewController.hash) else {
            return
        }

        for key in environmentValuesStack.keys.suffix(from: index + 1) {
            environmentValuesStack.removeValue(forKey: key)
            for child in descendants(of: key) {
                familyTree.removeValue(forKey: child)
            }
        }
    }
}
