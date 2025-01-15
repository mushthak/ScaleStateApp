import SwiftUI

struct CounterView: View {
    var store: CounterStore
    let onPassCount: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("\(store.state.count)")
                .font(.system(size: 60, weight: .bold))
            
            HStack(spacing: 20) {
                Button("-") {
                    Task {
                        await store.send(.setLoading(true))
                        await store.send(.decrement)
                    }
                }
                .font(.title)
                .disabled(store.state.isLoading)
                
                Button("+") {
                    Task {
                        await store.send(.setLoading(true))
                        await store.send(.increment)
                    }
                }
                .font(.title)
                .disabled(store.state.isLoading)
            }
            
            Button {
                onPassCount(store.state.count)
            } label: {
                if store.state.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Pass count")
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 20)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(store.state.isLoading)
        }
        .padding()
    }
}
