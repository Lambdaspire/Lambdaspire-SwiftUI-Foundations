
import LambdaspireAbstractions

public protocol ViewModel {
    static var empty: Self { get }
    func initialise(scope: DependencyResolutionScope)
}
