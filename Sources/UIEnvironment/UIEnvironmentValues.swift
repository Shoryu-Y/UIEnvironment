import Foundation

/// A key for accessing a value in the `UIEnvironmentValues` container.
///
/// To define a custom environment value, declare a type that conforms to
/// `UIEnvironmentKey`, and implement a static `defaultValue` property.
/// Then extend `UIEnvironmentValues` to expose the value through a computed property.
///
/// Example:
/// ```swift
/// struct Theme: UIEnvironmentKey {
///     static let defaultValue = Theme(...)
/// }
///
/// extension UIEnvironmentValues {
///     var theme: Theme {
///         get { self[Theme.self] }
///         set { self[Theme.self] = newValue }
///     }
/// }
/// ```
///
/// - SeeAlso: ``UIEnvironmentValues``
public protocol UIEnvironmentKey<Value>: Sendable {
    associatedtype Value: Sendable = Self

    static var defaultValue: Value { get }
}

/// A container for storing values that can be propagated throughout
/// a view controller hierarchy, similar to SwiftUI’s `EnvironmentValues`.
///
/// Values are accessed via custom keys conforming to `UIEnvironmentKey`.
/// Each key maps to a specific value type. You can extend this container
/// to define new values used across your app.
///
/// Example:
/// ```swift
/// struct Theme: UIEnvironmentKey {
///     static let defaultValue = Theme(...)
/// }
///
/// extension UIEnvironmentValues {
///     var theme: Theme {
///         get { self[Theme.self] }
///         set { self[Theme.self] = newValue }
///     }
/// }
/// ```
///
/// - Note: This container is designed for use within `UIEnvironmentNavigationController`.
/// - SeeAlso: ``UIEnvironmentKey``, ``UIEnvironment``, ``UIEnvironmentNavigationController``
public struct UIEnvironmentValues: Sendable {
    private var storage: [ObjectIdentifier: Sendable] = [:]

    public init() {}

    /// Accesses the environment value associated with the given key type.
    ///
    /// If no custom value has been set, the key's `defaultValue` is returned.
    ///
    /// - Parameter key: The type of key conforming to `UIEnvironmentKey`.
    /// - Returns: The associated value, or the key’s default value if unset.
    public subscript<Key: UIEnvironmentKey>(type: Key.Type) -> Key.Value {
        get { (storage[ObjectIdentifier(type)] as? Key.Value) ?? Key.defaultValue }
        set { storage[ObjectIdentifier(type)] = newValue }
    }
}
