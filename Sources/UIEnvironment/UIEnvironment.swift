import UIKit

/// A property wrapper that provides access to values stored in the `UIEnvironmentValues`
/// of a `UIViewController`, inspired by SwiftUI's `@Environment`.
///
/// Apply this wrapper to properties in a `UIViewController` subclass to access values
/// propagated via `UIEnvironmentValues`. This helps reduce boilerplate code required
/// to pass environment-like values through view controller hierarchies.
///
/// Example:
/// ```swift
/// final class ViewController: UIViewController {
///     @UIEnvironment(\.theme) var theme
///     // ...
/// }
/// ```
///
/// The values are resolved dynamically by walking up the view controller hierarchy and
/// retrieving the associated `UIEnvironmentNavigationController`, a subclass of `UINavigationController`
/// that maintains a stack-based storage of `UIEnvironmentValues` for each
/// pushed `UIViewController`.
///
/// - Note: When accessing the property, the system uses the nearest
///         enclosing `UIEnvironmentNavigationController`
///         to retrieve the appropriate value for the current view controller.
///         If no such navigation controller is found, a default `UIEnvironmentValues` is returned.
///
/// - SeeAlso: ``UIEnvironmentNavigationController``, ``UIEnvironmentValues``, ``environment(_:_:)``
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
            if let environmentValues = instance._environmentValues?[keyPath: keyPath] {
                return environmentValues
            } else {
                #if DEBUG
                    let environment = instance[keyPath: storageKeyPath]
                    Logger.warning("""
                    \(environment.fileID):\(environment.line):\(environment.column):
                    ⚠️ Warning: No UIEnvironmentNavigationController found in \(environment.function).

                    A new default UIEnvironmentValues instance was returned instead.

                    This may indicate that your view controller is not embedded in a UIEnvironmentNavigationController, or that the navigationController property has not been set yet (e.g. during viewDidLoad).

                    Make sure to embed your view controller in a UIEnvironmentNavigationController (or its subclass), and access environment values only after the navigationController becomes available.
                    """)
                #endif

                return UIEnvironmentValues()[keyPath: keyPath]
            }
        }

        set {
            #if DEBUG
                Logger.warning("""
                UIEnvironment: 
                    Direct assignment to @UIEnvironment(\\.keyPath) is discouraged.
                    Use environment(_:_:) instead.
                """)
            #endif

            let keyPath = instance[keyPath: storageKeyPath].keyPath
            instance._environmentValues?[keyPath: keyPath] = newValue
        }
    }

    /// Unavailable accessor. `@UIEnvironment` must only be used within `UIViewController` subclasses
    /// and cannot be directly assigned or accessed like a regular property wrapper.
    @available(*, unavailable, message: "`@UIEnvironment` must only be used within `UIViewController` subclasses")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }

    private let keyPath: WritableKeyPath<UIEnvironmentValues, Value>

    private let filePath: StaticString
    private let fileID: StaticString
    private let line: UInt
    private let column: UInt
    private let function: StaticString

    public init(
        _ keyPath: WritableKeyPath<UIEnvironmentValues, Value>,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column,
        function: StaticString = #function
    ) {
        self.keyPath = keyPath

        self.filePath = filePath
        self.fileID = fileID
        self.line = line
        self.column = column
        self.function = function
    }
}
