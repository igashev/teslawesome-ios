import Foundation
import AuthenticationNetworking
import AuthenticationModels
import Caching
import Dependencies

public struct AuthenticationFacadeClient {
    #if DEBUG
    var networkClient: AuthenticationNetworkClient
    #else
    let networkClient: AuthenticationNetworkClient
    #endif
    let cachingClient: CachingClient
    
    public var cachedAuthenticationToken: CacheContainer<AuthenticationToken>? {
        cachingClient.getToken()
    }
    
    init(networkClient: AuthenticationNetworkClient, cachingClient: CachingClient) {
        self.networkClient = networkClient
        self.cachingClient = cachingClient
    }
    
    public func getAuthenticationToken(authorizationToken: String, codeVerifier: String) async throws -> AuthenticationToken {
        let authenticationTokens = try await networkClient.getAuthenticationToken(authorizationToken: authorizationToken, codeVerifier: codeVerifier)
        cachingClient.storeToken(authenticationTokens)
        return authenticationTokens
    }
    
    public func refreshAuthenticationToken(refreshToken: String) async throws -> AuthenticationToken {
        let refreshedAuthenticationTokens = try await networkClient.refreshAuthenticationToken(refreshToken: refreshToken)
        cachingClient.storeToken(refreshedAuthenticationTokens)
        return refreshedAuthenticationTokens
    }
    
    /// Refreshes the authorization token if expired.
    /// - Returns: Returns **nil** when there isn't a token stored yet. Returns the **current token** if not yet expired or a **refreshed** one otherwise.
    public func refreshAuthenticationTokenIfNeeded() async throws -> AuthenticationToken? {
        guard let authenticationToken = cachedAuthenticationToken else {
            return nil
        }
        
        if authenticationToken.hasExpired {
            return try await refreshAuthenticationToken(refreshToken: authenticationToken.data.refreshToken)
        } else {
            return authenticationToken.data
        }
    }
    
    public func generateLoginURL(codeVerifier: String) -> URL? {
        let teslaAuthDomain = "https://auth.tesla.com/oauth2/v3/authorize"
        guard var urlComponents = URLComponents(string: teslaAuthDomain) else {
            return nil
        }
        
        let codeChallengeSHA256String = Utils.hashInSHA256(string: codeVerifier)
        let codeChallengeBase64URLEncoded = Utils.encodeBase64URL(string: codeChallengeSHA256String)
        let clientId = "ownerapi"
        let redirectURL = "https://auth.tesla.com/void/callback"
        let responseType = "code"
        let scope = "openid email offline_access"
        let state = Utils.randomlyGeneratedString(length: 10)
        let codeChallengeMethod = "S256"
        
        urlComponents.queryItems = [
            .init(name: "client_id", value: clientId),
            .init(name: "redirect_uri", value: redirectURL),
            .init(name: "response_type", value: responseType),
            .init(name: "scope", value: scope),
            .init(name: "state", value: state),
            .init(name: "code_challenge", value: codeChallengeBase64URLEncoded),
            .init(name: "code_challenge_method", value: codeChallengeMethod)
        ]
        
        return urlComponents.url
    }
    
    public func generateLoginCodeVerifier() -> String {
        Utils.randomlyGeneratedString(length: 86)
    }
    
    public func extractAuthorizationCodeFromURL(_ url: URL) -> String? {
        Utils.extractQueryParameterValue(from: url, queryName: "code")
    }
}

extension AuthenticationFacadeClient: DependencyKey {
    public static let liveValue: Self = .init(networkClient: .liveValue, cachingClient: .live)
    
    #if DEBUG
    public static let previewValue: Self = .init(networkClient: .previewValue, cachingClient: .live)
    #endif
}

extension DependencyValues {
    public var authenticationFacadeClient: AuthenticationFacadeClient {
        get { self[AuthenticationFacadeClient.self] }
        set { self[AuthenticationFacadeClient.self] = newValue }
    }
}
