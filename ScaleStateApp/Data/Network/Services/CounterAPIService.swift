import Foundation

protocol CounterAPIService: Sendable {
    func sendCounter(currentCount: Int) async throws
}

struct LiveCounterAPIService: CounterAPIService {
    private let baseURL = "https://673c84c396b8dcd5f3fa6702.mockapi.io/api/v1/Counter"
    
    func sendCounter(currentCount: Int) async throws {
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = CounterPayload(
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
