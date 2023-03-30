import AuthenticationModels
import NetworkRequester
import Networking
import Dependencies

public struct AuthenticationNetworkClient {
    typealias GetAuthenticationToken = (String, String) async throws -> AuthenticationToken
    typealias RefreshAuthenticationToken = (String) async throws -> AuthenticationToken
    
    let getAuthenticationToken: GetAuthenticationToken
    var refreshAuthenticationToken: RefreshAuthenticationToken
    
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

extension AuthenticationNetworkClient: DependencyKey {
    public static let liveValue: Self = {
        let asyncCaller = AsyncCaller(middleware: [LoggingMiddleware.live], decoder: Networking.jsonDecoder)
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
    }()
    
    #if DEBUG
    public static let previewValue: Self = {
        .init(
            getAuthenticationToken: { _, _ in .stub },
            refreshAuthenticationToken: { _ in .stub }
        )
    }()
    #endif
}

extension DependencyValues {
    public var authenticationNetworkClient: AuthenticationNetworkClient {
        get { self[AuthenticationNetworkClient.self] }
        set { self[AuthenticationNetworkClient.self] = newValue }
    }
}
