import Foundation
import UIKit

@attached(accessor)
public macro UIEnvironment<Value: Sendable>(_ keyPath: KeyPath<UIEnvironmentValues, Value>) = #externalMacro(module: "UIEnvironmentMacro", type: "UIEnvironment")
