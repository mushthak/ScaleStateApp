import Foundation
import SwiftUI

struct CompositionRoot {
    
    // MARK: - Services
    private let apiService: CounterAPIService
    
    // MARK: - Initialization
    init() {
        self.apiService = LiveCounterAPIService()
    }
    
    // MARK: - View Factories
    @MainActor func makeCounterView() -> some View {
        let environment = CounterEnvironment(apiService: apiService)
        let store = Store(
            initialState: CounterState(),
            reducer: counterReducer,
            environment: environment
        )
        return CounterView(store: store)
    }
    
    // MARK: - Root View
    @MainActor func makeRootView() -> some View {
        makeCounterView()
    }
} 
