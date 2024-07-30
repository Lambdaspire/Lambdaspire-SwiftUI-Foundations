
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct ViewModelMacro : ExtensionMacro, MemberMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext) throws -> [DeclSyntax] {
            
            guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
                // TODO: Error
                return []
            }
            
            let assignments = classDecl
                .memberBlock
                .members
                .compactMap { m in m.decl.as(VariableDeclSyntax.self) }
                .compactMap { v in v.bindings.first }
                .filter { b in
                    // Must have no accessor ( get or set ) at all, for now.
                    b.accessorBlock == nil &&
                    // Must not be initialized inline.
                    b.initializer == nil
                }
                .map { b in
                    b.pattern
                }
                .map { name in
                    "self.\(name) = scope.resolve()"
                }
            
            return [
                """
                func initialise(scope: any DependencyResolutionScope) {
                    \(raw: assignments.joined(separator: "\n"))
                }
                """
            ]
        }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
            [
                try? ExtensionDeclSyntax("extension \(type.trimmed) : ViewModel { }")
            ]
            .compactMap { $0 }
        }
}
