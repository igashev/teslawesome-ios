import Foundation
import NetworkRequester
import AuthenticationFacade
import AuthenticationModels

struct AuthenticationTokenMiddleware: Middleware {
    let authenticationFacadeClient: AuthenticationFacadeClient
    
    func onRequest(_ request: inout URLRequest) {
        guard let cachedToken = authenticationFacadeClient.cachedAuthenticationToken else {
            // No need to add a bearer token if there is not a cached one.
            return
        }
        
        if !cachedToken.hasExpired {
            request.addHeader(.authorization(bearerToken: cachedToken.data.accessToken))
        } else {
            let semaphore = DispatchSemaphore(value: 0)
            
            var authenticationTokenResponse: AuthenticationTokensResponse?
            authenticationFacadeClient.refreshAuthenticationTokenIfNeeded { tokenResponse in
                authenticationTokenResponse = tokenResponse
                semaphore.signal()
            }
            
            _ = semaphore.wait(timeout: .now() + 5)
            
            if let authenticationTokenResponse {
                request.addHeader(.authorization(bearerToken: authenticationTokenResponse.accessToken))
            }
        }
    }
}
