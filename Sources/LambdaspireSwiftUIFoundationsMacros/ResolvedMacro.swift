
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
            
            guard let binding = declaration
                .as(VariableDeclSyntax.self)?
                .bindings
                .first else {
                    context.diagnose(.init(node: node, message: ResolvedMacroUsageError.notVar))
                    return []
                }
            
            let name = binding.pattern
            
            guard let type = binding.typeAnnotation?.trimmed else {
                context.diagnose(.init(node: node, message: ResolvedMacroUsageError.unspecifiedType))
                return []
            }
            
            // TODO: This is dirty and will result in multiple initialisations of the @State variable.
            // Need to find a better way.
            // For now, the only decent workarounds currently are:
            // - componentise heavily (i.e. `DumbComponent(dep: resolvedDep)`)
            // - just store the computed value every render cycle (i.e. `let dep = resolvedDep`... `Text(dep.etc) + Text(dep.andSoOn)`)
            return [
                """
                get {
                    guard let resolved_\(raw: name) else {
                        let r\(raw: type) = resolved_scope.resolve()
                        DispatchQueue.main.async {
                            resolved_\(raw: name) = r
                        }
                        return r
                    }
                    return resolved_\(raw: name)
                }
                """
            ]
        }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext) throws -> [DeclSyntax] {
            
            guard let binding = declaration
                .as(VariableDeclSyntax.self)?
                .bindings
                .first else {
                    context.diagnose(.init(node: node, message: ResolvedMacroUsageError.notVar))
                    return []
                }
            
            let name = binding.pattern
            
            guard let type = binding.typeAnnotation?.trimmed else {
                context.diagnose(.init(node: node, message: ResolvedMacroUsageError.unspecifiedType))
                return []
            }
            
            return [
                """
                @State private var resolved_\(raw: name)\(type)? = nil
                """
            ]
        }
}

enum ResolvedMacroUsageError : String, DiagnosticMessage {
    
    case notVar = "@Resolved macro must be used on a variable declaration."
    case unspecifiedType = "@Resolved macro must be used on a variable declaration with a specified type."
    
    var message: String { rawValue }
    
    var diagnosticID: MessageID { .init(domain: "LambdaspireDependencyResolution", id: "\(self)") }
    
    var severity: DiagnosticSeverity { .error }
}
