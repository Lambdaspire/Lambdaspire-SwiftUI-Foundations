
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct ViewWithViewModelMacro : ExtensionMacro, MemberMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext) throws -> [DeclSyntax] {
            
            guard let structDecl = declaration.as(StructDeclSyntax.self) else {
                // TODO: Error
                return []
            }
            
            let type = structDecl.name
            
            return [
                """
                @StateObject private var vm: \(raw: type.trimmed)ViewModel = .empty
                """,
                #"""
                @Environment(\.scope) private var viewWithViewModel_scope
                """#,
                #"""
                var body: some View {
                    content.task { vm.initialise(scope: viewWithViewModel_scope) }
                }
                """#
            ]
        }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
            [
                try? ExtensionDeclSyntax("extension \(type.trimmed) : ViewWithViewModel { }")
            ]
            .compactMap { $0 }
        }
}
