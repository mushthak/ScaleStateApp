//
//  ScaleStateAppApp.swift
//  ScaleStateApp
//
//  Created by Mushthak Ebrahim on 13/01/25.
//

import SwiftUI
import SwiftData

@main
struct ScaleStateAppApp: App {

    let apiService = LiveCounterAPIService()
    
    var body: some Scene {
        
        let environment = CounterEnvironment(apiService: apiService)
        
        let store = Store(
            initialState: CounterState(),
            reducer: counterReducer,
            environment: environment
        )
        
        WindowGroup {
            CounterView(store: store)
        }
    }
}
