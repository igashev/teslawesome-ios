import NetworkRequester

enum Endpoint: URLProviding {
    case authenticationToken
    
    var url: String {
        switch self {
        case .authenticationToken:
            return "oauth2/v3/token"
        }
    }
}
