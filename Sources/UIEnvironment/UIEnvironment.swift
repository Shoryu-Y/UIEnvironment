import os
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
        set {
            #if DEBUG
                if #available(iOS 14, *) {
                    Logger().warning("""
                    UIEnvironment: 
                        Direct assignment to @UIEnvironment(\\.keyPath) is discouraged.
                        Use environment(_:_:) instead.
                    """)
                } else {
                    print("""
                    UIEnvironment: 
                        Direct assignment to @UIEnvironment(\\.keyPath) is discouraged.
                        Use environment(_:_:) instead.
                    """)
                }
            #endif

            let keyPath = instance[keyPath: storageKeyPath].keyPath
            instance._environmentValues[keyPath: keyPath] = newValue
        }
    }

    @available(*, unavailable, message: "@UIEnvironment can only be applied to classes")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }

    private let keyPath: WritableKeyPath<UIEnvironmentValues, Value>

    public init(_ keyPath: WritableKeyPath<UIEnvironmentValues, Value>) {
        self.keyPath = keyPath
    }
}
