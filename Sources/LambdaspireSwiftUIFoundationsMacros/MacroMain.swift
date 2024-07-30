
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

@main
struct LambdaspireDependencyResolutionMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ViewWithViewModelMacro.self,
        ViewModelMacro.self,
        ResolvedMacro.self,
        ResolvedScopeMacro.self
    ]
}
