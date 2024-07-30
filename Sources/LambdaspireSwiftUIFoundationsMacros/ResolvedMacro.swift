
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct ResolvedMacro : AccessorMacro, PeerMacro {
    
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
    
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext) throws -> [DeclSyntax] {
            // TODO: Remove MemberMacro definition.
            []
        }
}

enum ResolvedMacroUsageError : String, DiagnosticMessage {
    
    case notVar = "@Resolved macro must be used on a variable declaration."
    
    var message: String { rawValue }
    
    var diagnosticID: MessageID { .init(domain: "LambdaspireDependencyResolution", id: "\(self)") }
    
    var severity: DiagnosticSeverity { .error }
}
