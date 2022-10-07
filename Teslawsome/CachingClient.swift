//
//  CachingClient.swift
//  Teslawsome
//
//  Created by Ivaylo Gashev on 6.10.22.
//

import Foundation

struct CachingClient {
    let storeToken: (TokenResponse) -> ()
    let getToken: () -> (TokenResponse?)
}

extension CachingClient {
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
                
                return try? decoder.decode(TokenResponse.self, from: tokenData)
            }
        )
    }
}
