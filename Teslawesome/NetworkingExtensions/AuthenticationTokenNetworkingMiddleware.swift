import Foundation
import NetworkRequester
import AuthenticationFacade
import AuthenticationModels

struct AuthenticationTokenMiddleware: Middleware {
    let authenticationFacadeClient: AuthenticationFacadeClient
    
    func onRequest(_ request: inout URLRequest) async throws {
        guard let cachedToken = authenticationFacadeClient.cachedAuthenticationToken else {
            // No need to add a bearer token if there is not a cached one.
            return
        }
        
        if !cachedToken.hasExpired {
            request.addHeader(.authorization(bearerToken: cachedToken.data.accessToken))
        } else {
            if let authenticationTokenResponse = try await authenticationFacadeClient.refreshAuthenticationTokenIfNeeded() {
                request.addHeader(.authorization(bearerToken: authenticationTokenResponse.accessToken))
            }
        }
    }
}
