import SwiftUI

enum Route: Hashable {
    case counter
    case countHighlight(count: Int)
}

@Observable
class Router {
    var path = NavigationPath()
    
    func navigate(to route: Route) {
        path.append(route)
    }
    
    func navigateBack() {
        path.removeLast()
    }
} 
