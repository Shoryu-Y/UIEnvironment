# UIEnvironment
 
UIEnvironment brings SwiftUI-style @Environment functionality to UIKit.

## Quick Start
To register an environmental variable inside UIEnvironmentValues, you first create a type to conform to the UIEnvironmentKey protocol.
```swift
struct Theme {
    var titleFont: UIFont
    var backgroundColor: UIColor
}

extension Theme: UIEnvironmentKey {
    static let defaultValue = Theme(
        titleFont: .systemFont(ofSize: 12),
        backgroundColor: .systemBackground
    )
}
```

And then extend UIEnvironmentValues with a computed property that uses the key to read and write to UIEnvironmentValues:
```swift
extension UIEnvironmentValues {
    var theme: Theme {
        get { self[Theme.self] }
        set { self[Theme.self] = newValue }
    }
}
```

Next, push the UIViewController that needs access to environment values onto an EnvironmentNavigationController, or a custom navigation controller that inherits from it.
```swift
final class MyNavigationController: UIEnvironmentNavigationController {
    init() {
        super.init(rootViewController: RootViewController())
    }

    // ...
}
```
Finally, Access values inside your view controller.
```swift
final class RootViewController: UIViewController {
    @UIEnvironment(\.theme) var theme

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme.backgroundColor

        // ...
    }
}
```
