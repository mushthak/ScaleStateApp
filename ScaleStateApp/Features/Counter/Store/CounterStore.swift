//
//  CounterStore.swift
//  ScaleStateApp
//
//  Created by Mushthak Ebrahim on 14/01/25.
//

typealias CounterStore = Store<CounterState, CounterAction, CounterEnvironment>

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
}

struct CounterEnvironment {
    let apiService: CounterAPIService
}


let counterReducer: Reducer<CounterState, CounterAction, CounterEnvironment> = { state, action, environment in
    var newState = state
    switch action {
    case .increment:
        newState.count += 1
        newState.error = nil
        do {
            try await environment.apiService.sendCounter(currentCount: newState.count)
            return (.setLoading(false), newState)
        } catch {
            return (.setError("Failed to send increment action to server"), newState)
        }
        
    case .decrement:
        newState.count -= 1
        newState.error = nil
        do {
            try await environment.apiService.sendCounter(currentCount: newState.count)
            return (.setLoading(false), newState)
        } catch {
            return (.setError("Failed to send decrement action to server"), newState)
        }
        
    case .reset:
        newState.count = 0
        newState.error = nil
        do {
            try await environment.apiService.sendCounter(currentCount: newState.count)
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
