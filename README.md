# 🚧 Under Construction

This package is still in development / experimentation stages.

Not recommended for applications of significant size or importance.

Subject to breaking changes / complete abandonment.

---

# Lambdaspire SwiftUI Foundations

A package containing lightweight, loosely opinionated SwiftUI componentry to help establish a coherent architecture for SwiftUI applications.

Includes:
- Macros and extensions to support dependency resolution in Views (via `@Environment`).
- Macros to support a View / ViewModel style of managing UI and UI state (`@ViewWithViewModel` and `@ViewModel`).

## Usage

### Environment Resolution

The [Abstractions package](https://github.com/Lambdaspire/Lambdaspire-Swift-Abstractions) defines a `DependencyResolutionScope` protocol which allows for the resolution of registered dependencies.

SwiftUI's preferred method of passing dependencies through your application is via Environment. However, Environment is not accessible outside of Views. This adds complexity and much boilerplate when it comes to sharing dependencies between ViewModels, Services, etc and the Views. This limitation has long been the bane of patterns like MVVM (Model-View-ViewModel) that could otherwise help separate presentation and logic concerns in code.

With the `@ResolvedScope` and `@Resolved` macros, you can resolve dependencies in your SwiftUI Views that are also available to other parts of your application code.

```swift
@main
struct ExampleApp: App {
    
    private let rootScope: DependencyResolutionScope = getAppContainer()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .resolving(from: rootScope)
        }
    }
}

// Example
func getAppContainer() -> Container {
    let b: ContainerBuilder = .init()
    b.singleton(UserContext.self)
    // ...
    return b.build()
}

@ResolvedScope
struct RootView : View {

    @Resolved private var userContext: UserContext

    var body: some View {
        JustAnExampleView(userContext: userContext)
    }
}

struct JustAnExampleView : View {
    
    @ObservedObject var userContext: UserContext
    
    var body: some View {
        Text(user.whenLoaded { $0.name } else: { "???" })
    }
}
``` 

The `@ResolvedScope` macro is required as it creates a property on the View which supports the other properties:

```swift
@Environment(\.scope) private var resolved_scope
```

The `@Resolved` macro turns the declaration into a `get`-only computed property which sources the value from `resolved_scope`:

```swift
@Resolved private var userContext: UserContext

// becomes...

private var userContext: UserContext {
    get {
        resolved_scope.resolve()
    }
}
```

Note that the resolution happens every time the computed property is used. Keep that in mind for any transient registrations.

As you can see, these macros are just syntactic sugar / noise-reduction. They're also not necessarily ideal for every circumstance. If your views need to be reactive to changes in the value of dependencies, it is better to use out-of-the-box SwiftUI state management features.

### View / ViewModel

SwiftUI's evolution has been one of increasing difficulty in the separation of logic and presentation concerns. Frameworks like SwiftData continue to be heavily SwiftUI-centric. This means that whenever there is a deviation from SwiftUI (i.e. in legacy frameworks that have yet to receive a SwiftUI update) we find ourselves ejected from the Environment and wondering how we can pass messages to and fro without resorting to global singletons. We also find our SwiftUI Views laden with non-presentation concerns.

With a couple of macros, we can achieve a basic separation between Views and ViewModels with reduced boilerplate than might otherwise be necessary. Coupled with some basic IoC, we can 

Establish a `DependencyResolutionScope` somewhere early in the application lifecycle / hierarchy:

```swift
@main
struct ExampleApp: App {
    
    private let rootScope: DependencyResolutionScope = getAppContainer()
    
    var body: some Scene {
        WindowGroup {
            HomeScreen()
                .resolving(from: rootScope)
        }
    }
}

// Example
func getAppContainer() -> Container {
    let b: ContainerBuilder = .init()
    b.singleton(UserContext.self)
    // ...
    return b.build()
}

```

The example above uses `Container` from the [Dependency Resolution package](https://github.com/Lambdaspire/Lambdaspire-Swift-DependencyResolution) as the app's root scope and establishes it in the environment via the `resolving(from: DependencyResolutionScope)` extension on `View`.

Define Views like this:

```swift
@ViewWithViewModel
struct HomeScreen {
    var content: some View {
        VStack {
            Title(vm.welcomeMessage)
            Etc()
        }
        .sheet(isPresented: .constant(!vm.signedIn)) {
            AuthenticationScreen()
        }
    }
}
```

Under the hood, the `@ViewWithViewModel` macro:
- Adds conformance to `View`.
- Adds a `vm` property for a ViewModel matching the view's name (e.g. `HomeScreenViewModel`)*.
- Adds an implementation of `var body: some View` which renders `content` and initialises that ViewModel from the environment's `DependencyResolutionScope`.

*\*Note that the compiler will complain until you define a ViewModel named accordingly.*

Define ViewModels like this:

```swift
@ViewModel(generateEmpty: true)
class HomScreenViewModel {
    
    @Published var user: Loadable<User> = .notLoaded
    
    var signedIn: Bool { user.isLoaded }
    
    var welcomeMessage: String {
        user.whenLoaded {
            "Welcome, \($0.name)"
        } else: {
            "Welcome"
        }
    }
    
    private var userContext: UserContext!
    
    func signOut() {
        userContext.signOut()
    }
    
    func postInitialise() {
        // Keep the ViewModel state up to date with global UserContext state.
        userContext
            .$user
            .receive(on: DispatchQueue.main)
            .assign(to: &$user)
    }
}
```

The `@ViewModel` macro:
- Adds an `initialise(scope)` function that is called by the View to:
    - Initialise the ViewModel with dependencies, and
    - Invoke a `postInitialise` function which you can override (by default, a no-op).
- With `generateEmpty: true`, generates an empty initializer and a static `empty` instance using it.

Important notes:
- Dependencies that are resolved exclusively via scope must be declared with `!` (e.g. `private var userContext: UserContext!`), since the dependency resolution occurs after Environment is installed on a View and therefore after the ViewModel's instantiation.
    - This is not true if you omit the `generateEmpty` argument and supply a full `init` implementation. 
- The `postInitialise()` function is where you would wire up your Combine pipelines. It is called after the dependencies are injected, as per the previous note.

## Example Project

Check out an [example project](https://github.com/Lambdaspire/Lambdaspire-SwiftUI-Foundations-Example).

## Caveats

### Not Quite "In The Spirit" of SwiftUI

Though not particularly heavy or invasive, none of the above "goes with the flow" of SwiftUI. This kind of dissent is often perilous with Apple's SDKs as they tend to forge ahead on their determined path, leaving much deprecation in their wake.

The main problems we're attempting to solve here are:
- The lack of support for dependencies shared by SwiftUI Views and disconnected application logic components.
- The tendency for developers to fill SwiftUI Views with way too much logic.

This package aims to allow for separation of presentation and logic concerns in a manner that is hopefully easy to patch if the SDK changes dramatically.

### The Future of Combine

It seems like Combine is on the way out, to be replaced with Observation. This will probably end up being a good thing in the long run, but in the near-term it doesn't appear that Observation covers the full gamut of Combine's capabilities as a familiar functional reactive framework.

Hence, ViewModels as defined in this package conform to ObservableObject and you can take advantage of familiar Publisher/Subscriber patterns illustrated in this readme.

However, as alluded to previously, history suggests it's unwise to resist Apple's velocity. Therefore, as Observation matures (or, perhaps, as we become more familiar with its capabilities as they compare to Combine's) this package will likely be updated to shift more towards Observation in a fashion that is _not_ backwards compatible. Hopefully there will be a simple migration strategy from Combine to Observation in the event that the former is indeed superseded. 

### Opt-In

Don't feel the need to use the View / ViewModel approach everywhere (or even at all). The macros just add some rigidity to what is otherwise idiomatic SwiftUI.

If you don't want to use View / ViewModel at all, you can still make use of `@Resolved` and `@ResolvedScope` to resolve dependencies inline in your SwiftUI views.

### Not a Framework

It doesn't seem ideal to build entire frameworks for the Apple ecosystem as the SDK movements are fast and often unforgiving. Instead, this package offers some convenience on top of SDK offerings to reduce boilerplate and help establish a simple architecture for your codebase.

## FAQs

None yet. Got a question? Reach out.

## Known Issues

None yet. Found a bug? Please create an issue and/or a pull request.

## The End

👋 Happy User Interfacing!
