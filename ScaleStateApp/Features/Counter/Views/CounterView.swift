import SwiftUI

struct CounterView: View {
    let store: CounterStore
    
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
