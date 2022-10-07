import AuthenticationModels
import NetworkRequester
import Networking

public struct AuthenticationNetworkClient {
    public typealias GetAuthenticationToken = (String, String) async throws -> AuthenticationTokensResponse
    
    let getAuthenticationToken: GetAuthenticationToken
    
    init(getAuthenticationToken: @escaping GetAuthenticationToken) {
        self.getAuthenticationToken = getAuthenticationToken
    }
    
    public func getAuthenticationToken(authorizationToken: String, codeVerifier: String) async throws -> AuthenticationTokensResponse {
        try await getAuthenticationToken(authorizationToken, codeVerifier)
    }
}

public extension AuthenticationNetworkClient {
    static var live: Self {
        let asyncCaller = AsyncCaller.standard
        return .init(
            getAuthenticationToken: { authorizationToken, codeVerifier in
                let request = RequestBuilder.makeGetAuthenticationToken(authorizationToken: authorizationToken, codeVerifier: codeVerifier)
                return try await asyncCaller.call(using: request)
            }
        )
    }
}
