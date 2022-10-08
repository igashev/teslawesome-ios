import Foundation
import AuthenticationModels

// TODO: - Migrate this to keychain later
public struct CachingClient {
    public let storeToken: (AuthenticationTokensResponse) -> ()
    public let getToken: () -> (CacheContainer<AuthenticationTokensResponse>?)
}

public extension CachingClient {
    static var live: Self {
        let userDefaults = UserDefaults.standard
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        return .init(
            storeToken: { tokenToStore in
                let container = CacheContainer(data: tokenToStore, dateCached: .now)
                let encodedToken = try? encoder.encode(container)
                userDefaults.set(encodedToken, forKey: "authentication_token")
            },
            getToken: {
                guard let tokenData = userDefaults.data(forKey: "authentication_token") else {
                    return nil
                }
                
                return try? decoder.decode(CacheContainer<AuthenticationTokensResponse>.self, from: tokenData)
            }
        )
    }
}

public struct CacheContainer<C: Codable>: Codable {
    public let data: C
    public let dateCached: Date
}

public extension CacheContainer<AuthenticationTokensResponse> {
    var hasExpired: Bool {
        let expiryDate = dateCached.addingTimeInterval(TimeInterval(data.expiresIn))
        return expiryDate <= .now
    }
}
