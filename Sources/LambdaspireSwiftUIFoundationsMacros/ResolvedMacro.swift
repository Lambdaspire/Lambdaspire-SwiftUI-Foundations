
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct ResolvedMacro : AccessorMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext) throws -> [AccessorDeclSyntax] {
            [
                """
                get {
                    resolved_scope.resolve()
                }
                """
            ]
        }
}

enum ResolvedMacroUsageError : String, DiagnosticMessage {
    
    case notVar = "@Resolved macro must be used on a variable declaration."
    
    var message: String { rawValue }
    
    var diagnosticID: MessageID { .init(domain: "LambdaspireSwiftUIFoundations", id: "\(self)") }
    
    var severity: DiagnosticSeverity { .error }
}
