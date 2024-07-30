
import SwiftUI

@attached(member, names: named(vm), named(viewWithViewModel_scope), named(body))
@attached(extension, conformances: ViewWithViewModel)
public macro ViewWithViewModel() = #externalMacro(module: "LambdaspireSwiftUIFoundationsMacros", type: "ViewWithViewModelMacro")

@attached(member, names: named(initialise), named(init), named(empty))
@attached(extension, conformances: ViewModel, View)
public macro ViewModel(generateEmpty: Bool = false) = #externalMacro(module: "LambdaspireSwiftUIFoundationsMacros", type: "ViewModelMacro")

@attached(peer, names: arbitrary)
@attached(accessor, names: named(get), named(set))
public macro Resolved() = #externalMacro(module: "LambdaspireSwiftUIFoundationsMacros", type: "ResolvedMacro")

@attached(member, names: arbitrary)
public macro ResolvedScope() = #externalMacro(module: "LambdaspireSwiftUIFoundationsMacros", type: "ResolvedScopeMacro")
