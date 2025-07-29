import UIEnvironment
import UIKit

struct Theme {
    var title: String
    var titleFont: UIFont
    var backgroundColor: UIColor
}

extension Theme: UIEnvironmentKey {
    static let defaultValue = Theme(
        title: "Title",
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
