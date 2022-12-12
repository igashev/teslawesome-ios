import Foundation
import AuthenticationModels
import KeychainAccess

public struct CachingClient {
    public let storeToken: (AuthenticationToken) -> ()
    public let getToken: () -> (CacheContainer<AuthenticationToken>?)
}

public extension CachingClient {
    static var live: Self {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let keychain = Keychain(service: "com.ivaylogashev.Teslawesome")
            .synchronizable(true)
            .accessibility(.afterFirstUnlock)
        
        let tokenKey = "authentication_token"
        
        return .init(
            storeToken: { tokenToStore in
                let container = CacheContainer(data: tokenToStore, dateCached: .now)
                let encodedToken = try? encoder.encode(container)
                keychain[data: tokenKey] = encodedToken
            },
            getToken: {
                guard let tokenData = keychain[data: tokenKey] else {
                    return nil
                }
                
                return try? decoder.decode(CacheContainer<AuthenticationToken>.self, from: tokenData)
            }
        )
    }
}
