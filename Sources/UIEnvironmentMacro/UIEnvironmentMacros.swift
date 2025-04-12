import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct UIEnvironmentMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        UIEnvironment.self,
    ]
}
