import UIKit

@MainActor
@propertyWrapper
public struct UIEnvironment<Value> {
    public static subscript<EnclosingSelf: UIViewController>(
        _enclosingInstance instance: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
    ) -> Value {
        get {
            let keyPath = instance[keyPath: storageKeyPath].keyPath
            return instance._environmentValues[keyPath: keyPath]
        }
        set {}
    }

    @available(*, unavailable, message: "@UIEnvironment can only be applied to classes")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }

    private let keyPath: KeyPath<UIEnvironmentValues, Value>

    public init(_ keyPath: KeyPath<UIEnvironmentValues, Value>) {
        self.keyPath = keyPath
    }
}
