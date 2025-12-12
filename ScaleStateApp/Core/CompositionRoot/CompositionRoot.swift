import Foundation
import SwiftUI

struct CompositionRoot {
    
    // MARK: - Services
    private let apiService: CounterAPIService
    private let router: Router

    // MARK: - States
    private let counterStore: Store<CounterState, CounterAction, CounterEnvironment>
    
    // MARK: - Initialization
    init() {
        self.apiService = LiveCounterAPIService()
        self.router = Router()
        
        let environment = CounterEnvironment(apiService: apiService)
        self.counterStore = Store(
            initialState: CounterState(),
            reducer: counterReducer,
            environment: environment
        )
    }
    
    // MARK: - View Factories
    func makeCounterView() -> some View {
        return CounterView(store: counterStore) { count in
            router.navigate(to: .countHighlight(count: count))
        }
    }
    
    func makeCountHighlightView(count: Int) -> some View {
        CountHighlightView(count: count)
    }
    
    // MARK: - Root View
    @ViewBuilder
    func makeRootView() -> some View {
        NavigationStack(path: .init(get: { router.path }, set: { router.path = $0 })) {
            makeCounterView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .counter:
                        makeCounterView()
                    case .countHighlight(let count):
                        makeCountHighlightView(count: count)
                    }
                }
        }
    }
} 
