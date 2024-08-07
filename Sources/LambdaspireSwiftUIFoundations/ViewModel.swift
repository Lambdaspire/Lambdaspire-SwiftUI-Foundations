
import Combine
import LambdaspireAbstractions

public protocol ViewModel : ObservableObject {
    static func empty() -> Self
    func initialise(scope: DependencyResolutionScope)
    func postInitialise()
}

public extension ViewModel {
    func postInitialise() {
        // No-op by default.
    }
}
