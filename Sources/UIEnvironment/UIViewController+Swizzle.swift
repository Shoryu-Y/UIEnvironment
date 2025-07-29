import UIKit

@MainActor private var didSwizzled = false

extension UIViewController {
    static func swizzle() {
        if didSwizzled { return }
        defer { didSwizzled = true }

        _swizzle(
            originalSelector: #selector(UIViewController.viewDidLoad),
            swizzledSelector: #selector(UIViewController.uiEnvironment_viewDidLoad)
        )

        _swizzle(
            originalSelector: #selector(UIViewController.viewIsAppearing(_:)),
            swizzledSelector: #selector(UIViewController.uiEnvironment_viewIsAppearing(_:))
        )

        _swizzle(
            originalSelector: #selector(UIViewController.viewWillLayoutSubviews),
            swizzledSelector: #selector(UIViewController.uiEnvironment_viewWillLayoutSubviews)
        )

        _swizzle(
            originalSelector: #selector(UIViewController.viewDidLayoutSubviews),
            swizzledSelector: #selector(UIViewController.uiEnvironment_viewDidLayoutSubviews)
        )

        _swizzle(
            originalSelector:  #selector(UIViewController.addChild(_:)),
            swizzledSelector: #selector(UIViewController.uiEnvironment_addChild(_:))
        )
    }

    private static func _swizzle(originalSelector: Selector, swizzledSelector: Selector) {
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else {
            return
        }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UIViewController {
    @objc func uiEnvironment_viewDidLoad() {
        uiEnvironment_viewDidLoad()

        UIEnvironmentNotification.observe(self)
    }

    @objc func uiEnvironment_viewIsAppearing(_ animated: Bool) {
        uiEnvironment_viewIsAppearing(animated)

        registerViewIsAppearing(uiEnvironment_viewIsAppearing)
    }

    @objc func uiEnvironment_viewWillLayoutSubviews() {
        uiEnvironment_viewWillLayoutSubviews()

        registerViewWillLayoutSubviews(uiEnvironment_viewWillLayoutSubviews)
    }

    @objc func uiEnvironment_viewDidLayoutSubviews() {
        uiEnvironment_viewDidLayoutSubviews()

        registerViewDidLayoutSubviews(uiEnvironment_viewDidLayoutSubviews)
    }

    @objc func uiEnvironment_addChild(_ childController: UIViewController) {
        uiEnvironment_addChild(childController)

        if let navigationController = navigationController as? UIEnvironmentNavigationController {
            navigationController.appendRelationship(viewController: self, with: childController)
        }
    }
}
