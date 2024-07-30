
import Combine
import LambdaspireAbstractions

public protocol ViewModel : ObservableObject {
    static var empty: Self { get }
    func initialise(scope: DependencyResolutionScope)
    func postInitialise()
}

public extension ViewModel {
    func postInitialise() {
        // No-op by default.
    }
}
