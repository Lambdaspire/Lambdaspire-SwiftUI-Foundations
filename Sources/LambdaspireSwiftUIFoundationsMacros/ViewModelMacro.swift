
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
                context.diagnose(.init(node: node, message: ViewModelMacroUsageError.notClass))
                return []
            }
            
            let type = classDecl.name
            
            // TODO: Consider inverting this. Also, it doesn't actually check the value here. 🤦‍♀️
            let shouldGenerateEmpty = node
                .arguments?
                .as(LabeledExprListSyntax.self)?
                .compactMap { l in l.as(LabeledExprSyntax.self) }
                .contains { l in
                    l.expression.is(BooleanLiteralExprSyntax.self) &&
                    l.label?.trimmed.text == "generateEmpty"
                } ?? false
            
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
            
            let emptyGeneration: [DeclSyntax] = shouldGenerateEmpty
                ? [
                    """
                    init() { }
                    """,
                    """
                    static func empty() -> \(raw: type.trimmed) { .init() }
                    """
                ]
                : []
            
            return [
                """
                func initialise(scope: any DependencyResolutionScope) {
                    \(raw: assignments.joined(separator: "\n"))
                    postInitialise()
                }
                """,
            ] +
            emptyGeneration
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

enum ViewModelMacroUsageError : String, DiagnosticMessage {
    
    case notClass = "@ViewModel macro must be used on a class."
    
    var message: String { rawValue }
    
    var diagnosticID: MessageID { .init(domain: "LambdaspireSwiftUIFoundations", id: "\(self)") }
    
    var severity: DiagnosticSeverity { .error }
}
