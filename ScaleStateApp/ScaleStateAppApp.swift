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
    let store = Store(
            initialState: CounterState(),
            reducer: counterReducer,
            environment: ()
        )


    var body: some Scene {
        WindowGroup {
            CounterView(store: store)
        }
    }
}
