import SwiftUI

struct CountHighlightView: View {
    let count: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Received Count")
                .font(.title)
            
            Text("\(count)")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.blue)
        }
        .padding()
    }
} 