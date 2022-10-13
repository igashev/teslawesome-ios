import Networking
import NetworkRequester

enum RequestBuilder {
    static func makeGetAuthenticationToken(authorizationToken: String, codeVerifier: String) -> URLRequestBuilder {
        .auth(
            endpoint: Endpoint.authenticationToken,
            httpMethod: .post,
            httpBody: .init(encodable: AuthenticationTokenRequest(code: authorizationToken, codeVerifier: codeVerifier))
        )
    }
    
    static func makeRefreshAuthenticationToken(refreshToken: String) -> URLRequestBuilder {
        .auth(
            endpoint: Endpoint.refreshToken,
            httpMethod: .post,
            httpBody: .init(encodable: RefreshAuthenticationTokenRequest(refreshToken: refreshToken))
        )
    }
}
