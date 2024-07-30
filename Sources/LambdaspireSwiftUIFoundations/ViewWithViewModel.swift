
import LambdaspireAbstractions
import SwiftUI

public protocol ViewWithViewModel : View {
    associatedtype Content : View
    @ViewBuilder @MainActor var content: Self.Content { get }
}
