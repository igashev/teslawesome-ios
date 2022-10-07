import Foundation
import AuthenticationModels

// TODO: - Migrate this to keychain later
public struct CachingClient {
    public let storeToken: (AuthenticationTokensResponse) -> ()
    public let getToken: () -> (AuthenticationTokensResponse?)
}

public extension CachingClient {
    static var live: Self {
        let userDefaults = UserDefaults.standard
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        return .init(
            storeToken: { tokenToStore in
                let encodedToken = try? encoder.encode(tokenToStore)
                userDefaults.set(encodedToken, forKey: "authentication_token")
            },
            getToken: {
                guard let tokenData = userDefaults.data(forKey: "authentication_token") else {
                    return nil
                }
                
                return try? decoder.decode(AuthenticationTokensResponse.self, from: tokenData)
            }
        )
    }
}
