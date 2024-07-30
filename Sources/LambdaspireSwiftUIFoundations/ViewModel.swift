
import LambdaspireAbstractions

public protocol ViewModel {
    static var empty: Self { get }
    func initialise(scope: DependencyResolutionScope)
    func postInitialise()
}

extension ViewModel {
    func postInitialise() {
        // No-op by default.
    }
}
