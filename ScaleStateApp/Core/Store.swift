import Foundation
import Observation

@Observable
@MainActor
final class Store<State: Sendable, Action: Sendable, Environment: Sendable> {
    private(set) var state: State
    private let reducer: Reducer<State, Action, Environment>
    private let environment: Environment
    
    init(
        initialState: State,
        reducer: @escaping Reducer<State, Action, Environment>,
        environment: Environment
    ) {
        self.state = initialState
        self.reducer = reducer
        self.environment = environment
    }
    
    func send(_ action: Action) async {
        let (nextAction, newState) = await reducer(state, action, environment)
        self.state = newState
        if nextAction != nil {
            await send(nextAction!)
        }
    }
}
