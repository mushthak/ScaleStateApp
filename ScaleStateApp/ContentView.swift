//
//  ContentView.swift
//  ScaleStateApp
//
//  Created by Mushthak Ebrahim on 13/01/25.
//

import SwiftUI
import SwiftData
import Observation

struct CounterState: Equatable {
    var count: Int = 0
}

enum CounterAction: Equatable {
    case increment
    case decrement
    case reset
}

typealias Effect<Action> = () async -> Action?
typealias Reducer<State, Action, Environment> = (inout State, Action, Environment) -> Effect<Action>?

let counterReducer: Reducer<CounterState, CounterAction, Void> = { state, action, _ in
    switch action {
    case .increment:
        state.count += 1
    case .decrement:
        state.count -= 1
    case .reset:
        state.count = 0
    }
    return nil
}

@Observable
@MainActor
final class Store<State, Action, Environment> {
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
        if let effect = reducer(&state, action, environment) {
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if let nextAction = await effect() {
                    await self.send(nextAction)
                }
            }
        }
    }
}

struct CounterView: View {
    let store: Store<CounterState, CounterAction, Void>
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Count: \(store.state.count)")
                .font(.largeTitle)
            
            HStack {
                Button("Decrement") {
                    Task {
                        await store.send(.decrement)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.2))
                .cornerRadius(8)
                
                Button("Increment") {
                    Task {
                        await store.send(.increment)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.2))
                .cornerRadius(8)
            }
            
            Button("Reset") {
                Task {
                    await store.send(.reset)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.2))
            .cornerRadius(8)
        }
        .padding()
    }
}
