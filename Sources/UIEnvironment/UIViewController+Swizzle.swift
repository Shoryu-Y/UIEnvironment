import UIKit

@MainActor var didSwizzled = false

extension UIViewController {
    static func swizzle() {
        if didSwizzled { return }

        let originalSelector = #selector(UIViewController.addChild(_:))
        let swizzledSelector = #selector(UIViewController.uiEnvironment_addChild(_:))

        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else {
            return
        }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UIViewController {
    @objc func uiEnvironment_addChild(_ childController: UIViewController) {
        uiEnvironment_addChild(childController)
    }

}
