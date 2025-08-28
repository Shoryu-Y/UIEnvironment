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
        with environmentValue: UIEnvironmentValues? = nil
    ) {
        UIViewController.swizzle()
        super.init(rootViewController: rootViewController)

        familyTree[rootViewController.hashValue] = .init(
            children: [],
            environmentValues: environmentValue ?? UIEnvironmentValues()
        )
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var familyTree: [Int: FamilyRelationship] = [:]
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

    func environmentValues(of viewController: UIViewController) -> UIEnvironmentValues? {
        if let familyRelationship = familyTree[viewController.hash] {
            familyRelationship.environmentValues
        } else {
            nil
        }
    }

    func setEnvironmentValues(
        _ environmentValues: UIEnvironmentValues,
        to viewController: UIViewController
    ) {
        let hash = viewController.hash

        if var relationship = familyTree[hash] {
            relationship.update(environmentValues)
            familyTree.updateValue(relationship, forKey: hash)
        } else {
            familyTree[hash] = FamilyRelationship(
                children: [],
                environmentValues: environmentValues
            )
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

        let parentRelationship = familyTree[parentHash]
        let childRelationship = familyTree[childHash]

        switch (parentRelationship, childRelationship) {
        case var (.some(parentRelationship), .none):
            parentRelationship.addChild(childHash)
            familyTree.updateValue(parentRelationship, forKey: parentHash)
            familyTree[childHash] = FamilyRelationship(children: [], environmentValues: parentRelationship.environmentValues)

        case var (.some(parentRelationship), .some):
            parentRelationship.addChild(childHash)
            familyTree.updateValue(parentRelationship, forKey: parentHash)
            setEnvironmentValues(parentRelationship.environmentValues, to: viewController)

        case (.none, .some):
            familyTree[parentHash] = FamilyRelationship(children: [childHash], environmentValues: UIEnvironmentValues())

        case (.none, .none):
            familyTree[parentHash] = FamilyRelationship(children: [childHash], environmentValues: UIEnvironmentValues())
            familyTree[childHash] = FamilyRelationship(children: [], environmentValues: UIEnvironmentValues())
        }
    }
}
