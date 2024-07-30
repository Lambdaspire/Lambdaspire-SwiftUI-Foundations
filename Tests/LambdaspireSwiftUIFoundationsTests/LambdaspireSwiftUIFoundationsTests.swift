
import SwiftUI
import Combine
import XCTest
import LambdaspireAbstractions
@testable import LambdaspireSwiftUIFoundations

final class LambdaspireSwiftUIFoundationsTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
}

@ViewWithViewModel
struct HomeScreen {
    var content: some View {
        Text(vm.text)
    }
}

@ViewModel
final class HomeScreenViewModel : ObservableObject {
    
    @Published var text: String = "Initial"
    
    private var dependency: Dependency
    
    init(dependency: Dependency) {
        self.dependency = dependency
        
        dependency.$text.assign(to: &$text)
    }
}

extension HomeScreenViewModel {
    static let empty: HomeScreenViewModel = .init(dependency: .init())
}

class Dependency : ObservableObject {
    @Published var text: String = ""
}
