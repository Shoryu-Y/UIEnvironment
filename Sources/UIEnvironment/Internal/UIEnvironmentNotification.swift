import UIKit

@MainActor
enum UIEnvironmentNotification {
    static func makeNotificationName(hash: Int) -> Notification.Name {
        Notification.Name("UIEnvironmentNotification.UIEnvironmentValuesDidChange.\(hash)")
    }

    static func post(with hash: Int) {
        NotificationCenter.default.post(name: makeNotificationName(hash: hash), object: nil)
    }

    static func observe(_ observer: UIViewController) {
        NotificationCenter.default.addObserver(
            observer,
            selector: #selector(UIViewController.didReceiveEnvironmentValuesNotification(_:)),
            name: makeNotificationName(hash: observer.hash),
            object: nil
        )
    }
}

public extension UIViewController {
    func registerViewIsAppearing(_ viewIsAppearing: @escaping (Bool) -> Void) {
        if let navigationController = navigationController as? UIEnvironmentNavigationController {
            navigationController.makeRelationshipUntilAncestor(self)
        }
        viewIsAppearing(true)
        viewIsAppearingRegistered = viewIsAppearing
    }

    func registerViewWillLayoutSubviews(_ viewWillLayoutSubviews: @escaping () -> Void) {
        if let navigationController = navigationController as? UIEnvironmentNavigationController {
            navigationController.makeRelationshipUntilAncestor(self)
        }
        viewWillLayoutSubviews()
        viewWillLayoutSubviewsRegistered = viewWillLayoutSubviews
    }

    func registerViewDidLayoutSubviews(_ viewDidLayoutSubviews: @escaping () -> Void) {
        if let navigationController = navigationController as? UIEnvironmentNavigationController {
            navigationController.makeRelationshipUntilAncestor(self)
        }
        viewDidLayoutSubviews()
        viewDidLayoutSubviewsRegistered = viewDidLayoutSubviews
    }
}

private extension UIViewController {
    private static let key_viewIsAppearingRegistered = malloc(1)!
    private static let key_viewWillLayoutSubviewsRegistered = malloc(1)!
    private static let key_viewDidLayoutSubviewsRegistered = malloc(1)!

    var viewIsAppearingRegistered: ((Bool) -> Void)? {
        get { objc_getAssociatedObject(self, Self.key_viewIsAppearingRegistered) as? (Bool) -> Void }
        set { objc_setAssociatedObject(self, Self.key_viewIsAppearingRegistered, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    var viewWillLayoutSubviewsRegistered: (() -> Void)? {
        get { objc_getAssociatedObject(self, Self.key_viewWillLayoutSubviewsRegistered) as? () -> Void }
        set { objc_setAssociatedObject(self, Self.key_viewWillLayoutSubviewsRegistered, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    var viewDidLayoutSubviewsRegistered: (() -> Void)? {
        get { objc_getAssociatedObject(self, Self.key_viewDidLayoutSubviewsRegistered) as? () -> Void }
        set { objc_setAssociatedObject(self, Self.key_viewDidLayoutSubviewsRegistered, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    @objc func didReceiveEnvironmentValuesNotification(_ notification: Notification) {
        viewIsAppearingRegistered?(true)
        viewWillLayoutSubviewsRegistered?()
        viewDidLayoutSubviewsRegistered?()
    }
}
