import Foundation

public protocol UIEnvironmentKey<Value>: Sendable {
    associatedtype Value: Sendable = Self

    static var defaultValue: Value { get }
}

public struct UIEnvironmentValues: Sendable {
    private var storage: [ObjectIdentifier: Sendable] = [:]

    public init() {}

    public subscript<Key: UIEnvironmentKey>(type: Key.Type) -> Key.Value {
        get { (storage[ObjectIdentifier(type)] as? Key.Value) ?? Key.defaultValue }
        set { storage[ObjectIdentifier(type)] = newValue }
    }
}
