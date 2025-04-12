import UIEnvironment
import UIKit

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

extension UIEnvironmentValues {
    var theme: Theme {
        get { self[Theme.self] }
        set { self[Theme.self] = newValue }
    }
}
