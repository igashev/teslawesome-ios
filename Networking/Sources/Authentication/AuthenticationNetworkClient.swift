import AuthenticationModels
import NetworkRequester
import Networking

public struct AuthenticationNetworkClient {
    typealias GetAuthenticationToken = (String, String) async throws -> AuthenticationToken
    typealias RefreshAuthenticationToken = (String) async throws -> AuthenticationToken
    
    let getAuthenticationToken: GetAuthenticationToken
    let refreshAuthenticationToken: RefreshAuthenticationToken
    
    init(
        getAuthenticationToken: @escaping GetAuthenticationToken,
        refreshAuthenticationToken: @escaping RefreshAuthenticationToken
    ) {
        self.getAuthenticationToken = getAuthenticationToken
        self.refreshAuthenticationToken = refreshAuthenticationToken
    }
    
    public func getAuthenticationToken(authorizationToken: String, codeVerifier: String) async throws -> AuthenticationToken {
        try await getAuthenticationToken(authorizationToken, codeVerifier)
    }
    
    public func refreshAuthenticationToken(refreshToken: String) async throws -> AuthenticationToken {
        try await refreshAuthenticationToken(refreshToken)
    }
}

public extension AuthenticationNetworkClient {
    static var live: Self {
        let asyncCaller = AsyncCaller(decoder: Networking.jsonDecoder, middleware: [LoggingMiddleware.live])
        return .init(
            getAuthenticationToken: { authorizationToken, codeVerifier in
                let request = RequestBuilder.makeGetAuthenticationToken(authorizationToken: authorizationToken, codeVerifier: codeVerifier)
                return try await asyncCaller.call(using: request)
            },
            refreshAuthenticationToken: { refreshToken in
                let request = RequestBuilder.makeRefreshAuthenticationToken(refreshToken: refreshToken)
                return try await asyncCaller.call(using: request)
            }
        )
    }
}
