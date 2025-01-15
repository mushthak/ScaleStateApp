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
    
    private let compositionRoot = CompositionRoot()
    
    var body: some Scene {
        WindowGroup {
            compositionRoot.makeRootView()
        }
    }
}
