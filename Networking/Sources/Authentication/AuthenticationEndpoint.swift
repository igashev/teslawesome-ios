import NetworkRequester

enum Endpoint: URLProviding {
    case authenticationToken, refreshToken
    
    var url: String {
        switch self {
        case .authenticationToken, .refreshToken:
            return "oauth2/v3/token"
        }
    }
}
