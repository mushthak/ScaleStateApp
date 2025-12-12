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
    //View Actions
    case increment
    case decrement
    
    //Internal Actions
    case _sendCounter(currentCount: Int)
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
        newState.isLoading = true
        return (._sendCounter(currentCount: newState.count), newState)
        
    case .decrement:
        newState.count -= 1
        newState.error = nil
        newState.isLoading = true
        return (._sendCounter(currentCount: newState.count), newState)
        
    case ._sendCounter(currentCount: let count):
        do {
            try await environment.apiService.sendCounter(currentCount: newState.count)
            newState.isLoading = true
            return (nil, newState)
        } catch {
            newState.error = "Failed to send action to server"
            newState.isLoading = false
            return (nil, newState)
        }
    }
}
