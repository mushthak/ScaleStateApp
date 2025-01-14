//
//  ContentView.swift
//  ScaleStateApp
//
//  Created by Mushthak Ebrahim on 13/01/25.
//

import SwiftUI
import SwiftData
import Observation

// API Service
protocol CounterAPIService: Sendable {
    func sendCounterAction(_ action: CounterAction, currentCount: Int) async throws
}

struct LiveCounterAPIService: CounterAPIService {
    private let baseURL = "https://api.example.com/counter"
    
    func sendCounterAction(_ action: CounterAction, currentCount: Int) async throws {
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = CounterPayload(
            action: action.rawValue,
            count: currentCount,
            timestamp: Date()
        )
        
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw CounterError.apiError
        }
    }
}

// Models and Helpers
struct CounterPayload: Codable {
    let action: String
    let count: Int
    let timestamp: Date
}

enum CounterError: Error {
    case apiError
}

@MainActor
struct CounterState: Equatable {
    var count: Int = 0
    var isLoading: Bool = false
    var error: String?
}

enum CounterAction: Equatable, Sendable {
    case increment
    case decrement
    case reset
    case setLoading(Bool)
    case setError(String?)
    
    var rawValue: String {
        switch self {
        case .increment: return "increment"
        case .decrement: return "decrement"
        case .reset: return "reset"
        case .setLoading: return "setLoading"
        case .setError: return "setError"
        }
    }
}

// Environment to hold dependencies
struct CounterEnvironment : Sendable{
    let apiService: CounterAPIService
}

//typealias Effect<Action> = () async -> Action?
typealias Reducer<State, Action, Environment> = (State, Action, Environment) async -> (Action?, State)

@MainActor let counterReducer: Reducer<CounterState, CounterAction, CounterEnvironment> = { state, action, environment in
    var newState = state
    switch action {
    case .increment:
        newState.count += 1
        newState.error = nil
        let currentCount = state.count
        do {
            try await environment.apiService.sendCounterAction(.increment, currentCount: currentCount)
            return (.setLoading(false), newState)
        } catch {
            return (.setError("Failed to send increment action to server"), newState)
        }
        
    case .decrement:
        newState.count -= 1
        newState.error = nil
        let currentCount = state.count
        do {
            try await environment.apiService.sendCounterAction(.decrement, currentCount: currentCount)
            return (.setLoading(false), newState)
        } catch {
            return (.setError("Failed to send decrement action to server"), newState)
        }
        
    case .reset:
        newState.count = 0
        newState.error = nil
        let currentCount = state.count
        do {
            try await environment.apiService.sendCounterAction(.reset, currentCount: currentCount)
            return (.setLoading(false), newState)
        } catch {
            return (.setError("Failed to send reset action to server"), newState)
        }
        
    case .setLoading(let isLoading):
        newState.isLoading = isLoading
        return (nil, newState)
        
    case .setError(let error):
        newState.error = error
        newState.isLoading = false
        return (nil, newState)
    }
}

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

struct CounterView: View {
    let store: Store<CounterState, CounterAction, CounterEnvironment>
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Count: \(store.state.count)")
                .font(.largeTitle)
            
            if store.state.isLoading {
                ProgressView()
            }
            
            if let error = store.state.error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            HStack {
                Button("Decrement") {
                    Task {
                        await store.send(.setLoading(true))
                        await store.send(.decrement)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.2))
                .cornerRadius(8)
                .disabled(store.state.isLoading)
                
                Button("Increment") {
                    Task {
                        await store.send(.setLoading(true))
                        await store.send(.increment)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.2))
                .cornerRadius(8)
                .disabled(store.state.isLoading)
            }
            
            Button("Reset") {
                Task {
                    await store.send(.setLoading(true))
                    await store.send(.reset)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.2))
            .cornerRadius(8)
            .disabled(store.state.isLoading)
        }
        .padding()
    }
}
