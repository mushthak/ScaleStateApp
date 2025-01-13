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
protocol CounterAPIService {
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

struct CounterState: Equatable {
    var count: Int = 0
    var isLoading: Bool = false
    var error: String?
}

enum CounterAction: Equatable {
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
struct CounterEnvironment {
    let apiService: CounterAPIService
}

typealias Effect<Action> = () async -> Action?
typealias Reducer<State, Action, Environment> = (inout State, Action, Environment) -> Effect<Action>?

let counterReducer: Reducer<CounterState, CounterAction, CounterEnvironment> = { state, action, environment in
    switch action {
    case .increment:
        state.count += 1
        state.error = nil
        let currentCount = state.count
        return { @MainActor in
            do {
                try await environment.apiService.sendCounterAction(.increment, currentCount: currentCount)
                return .setLoading(false)
            } catch {
                return .setError("Failed to send increment action to server")
            }
        }
        
    case .decrement:
        state.count -= 1
        state.error = nil
        let currentCount = state.count
        return { @MainActor in
            do {
                try await environment.apiService.sendCounterAction(.decrement, currentCount: currentCount)
                return .setLoading(false)
            } catch {
                return .setError("Failed to send decrement action to server")
            }
        }
        
    case .reset:
        state.count = 0
        state.error = nil
        let currentCount = state.count
        return { @MainActor in
            do {
                try await environment.apiService.sendCounterAction(.reset, currentCount: currentCount)
                return .setLoading(false)
            } catch {
                return .setError("Failed to send reset action to server")
            }
        }
        
    case .setLoading(let isLoading):
        state.isLoading = isLoading
        return nil
        
    case .setError(let error):
        state.error = error
        state.isLoading = false
        return nil
    }
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
