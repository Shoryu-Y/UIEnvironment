import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct UIEnvironment: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        guard let variableDeclSyntax = declaration.as(VariableDeclSyntax.self) else {
            context.addDiagnostics(
                from: MessageError(description: "@UIEnvironment supports only variable."),
                node: declaration
            )
            return []
        }

        guard let binding = variableDeclSyntax.bindings.first else {
            context.addDiagnostics(
                from: MessageError(description: "@UIEnvironment requires a binding"),
                node: variableDeclSyntax
            )
            return []
        }

        guard variableDeclSyntax.bindings.count == 1 else {
            context.addDiagnostics(
                from: MessageError(description: "@UIEnvironment doesn't support multiple binding"),
                node: variableDeclSyntax.bindings
            )
            return []
        }

        guard let type = binding.typeAnnotation?.type else {
            context.addDiagnostics(
                from: MessageError(description: "@UIEnvironment requires type annotation."),
                node: binding
            )
            return []
        }

        guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            context.addDiagnostics(
                from: MessageError(description: "No name information."),
                node: binding
            )
            return []
        }

        guard let argument = node.arguments?.as(LabeledExprListSyntax.self)?.first,
              let expression = argument.expression.as(KeyPathExprSyntax.self)
        else {
            context.addDiagnostics(
                from: MessageError(description: "UIEnvironment requires a KeyPath argument"),
                node: declaration
            )
            return []
        }

        return [
            """
            get {
                @_UIEnvironment<\(type)>(self, keyPath: \(expression)) var \(name)
                return \(name)
            }
            set {
                @_UIEnvironment<\(type)>(self, keyPath: \(expression)) var \(name)
                \(name) = newValue
            }
            """,
        ]
    }
}

struct MessageError: Error, CustomStringConvertible {
    var description: String
}
