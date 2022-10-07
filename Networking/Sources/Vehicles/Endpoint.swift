import protocol NetworkRequester.URLProviding

enum Endpoint: URLProviding {
    case vehicles
    
    var url: String {
        switch self {
        case .vehicles:
            return "api/1/vehicles"
        }
    }
}
