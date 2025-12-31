import UIKit

extension UIViewController {
    private static let associatedObjectKey = malloc(1)!

    private(set) var environmentValuesForPresented: UIEnvironmentValues? {
        get { objc_getAssociatedObject(self, Self.associatedObjectKey) as? UIEnvironmentValues }
        set { objc_setAssociatedObject(self, Self.associatedObjectKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    public func presentWithEnvironment(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        viewController.environmentValuesForPresented = self._environmentValues
        present(viewController, animated: animated) { [weak self] in
            self?.environmentValuesForPresented = nil
            completion?()
        }
    }
}
