
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(LambdaspireSwiftUIFoundationsMacros)
import LambdaspireSwiftUIFoundationsMacros

let testMacros: [String: Macro.Type] = [
    "ViewWithViewModel": ViewWithViewModelMacro.self,
    "ViewModel": ViewModelMacro.self,
    "Resolved": ResolvedMacro.self,
    "ResolvedScope": ResolvedScopeMacro.self
]
#endif

final class LambdaspireSwiftUIFoundationsMacrosTests: XCTestCase {
    
    func test_ViewWithViewModelAndViewModel() {
        #if canImport(LambdaspireSwiftUIFoundationsMacros)
        assertMacroExpansion(
            #"""
            @ViewWithViewModel
            struct TestView {
                var content: some View {
                    Text("\(vm.text)")
                }
            }
            
            @ViewModel(generateEmpty: true)
            class ViewModel : ObservableObject {
                @Published private(set) var text: String = "Initial"
            
                private(set) var dependency: Dependency
            
                init(dependency: Dependency) {
                    self.dependency = dependency
            
                    dependency.$text.assign(to: &$text)
                }
            }
            """#,
            expandedSource: #"""
            struct TestView {
                var content: some View {
                    Text("\(vm.text)")
                }

                @StateObject private var vm: TestViewViewModel = .empty

                @Environment(\.scope) private var viewWithViewModel_scope

                var body: some View {
                    content.task {
                        vm.initialise(scope: viewWithViewModel_scope)
                    }
                }
            }
            class ViewModel : ObservableObject {
                @Published private(set) var text: String = "Initial"

                private(set) var dependency: Dependency

                init(dependency: Dependency) {
                    self.dependency = dependency

                    dependency.$text.assign(to: &$text)
                }
            
                func initialise(scope: any DependencyResolutionScope) {
                    self.dependency = scope.resolve()
                    postInitialise()
                }
            
                init() {
                }
            
                static let empty: ViewModel  = .init()
            }

            extension TestView : ViewWithViewModel {
            }

            extension ViewModel : ViewModel {
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_ResolvedAndResolvedScope() {
        #if canImport(LambdaspireSwiftUIFoundationsMacros)
        assertMacroExpansion(
            #"""
            @ResolvedScope
            struct TestView : View {
                @Resolved var a: Int
                @Resolved private var b: Bool
            
                var body: some View {
                    Text("Test")
                }
            }
            """#,
            expandedSource: #"""
            struct TestView : View {
                var a: Int {
                    get {
                        resolved_scope.resolve()
                    }
                }
                private var b: Bool {
                    get {
                        resolved_scope.resolve()
                    }
                }
            
                var body: some View {
                    Text("Test")
                }
            
                @Environment(\.scope) private var resolved_scope
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
