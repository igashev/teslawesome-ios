import Foundation
import AuthenticationNetworking
import AuthenticationModels
import Caching
import Dependencies

public struct AuthenticationFacadeClient {
    let networkClient: AuthenticationNetworkClient
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
    ///
    public func refreshAuthenticationTokenIfNeeded() async throws -> AuthenticationToken? {
        guard let authenticationToken = cachedAuthenticationToken else {
            return nil
        }
        
        if authenticationToken.hasExpired {
            return try await refreshAuthenticationToken(refreshToken: authenticationToken.data.refreshToken)
        } else {
            // no auth token stored or
            // hasn't expired yet, then token is valid and can be used
            return authenticationToken.data
        }
    }
}

extension AuthenticationFacadeClient: DependencyKey {
    public static var liveValue: Self = {
        .init(networkClient: .live, cachingClient: .live)
    }()
}

extension DependencyValues {
    public var authenticationFacadeClient: AuthenticationFacadeClient {
        get { self[AuthenticationFacadeClient.self] }
        set { self[AuthenticationFacadeClient.self] = newValue }
    }
}
