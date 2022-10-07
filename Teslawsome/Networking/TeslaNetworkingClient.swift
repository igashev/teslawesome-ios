//
//  TeslaNetworkingClient.swift
//  Teslawsome
//
//  Created by Ivaylo Gashev on 22.08.22.
//

import Foundation

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let idToken: String
    let expiresIn: Int
    let tokenType: String
}

enum TokenGrantType: String, Encodable {
    case authorizationCode = "authorization_code"
    case refreshToken = "refresh_token"
}

struct TokenRequest: Encodable {
    let grantType = TokenGrantType.authorizationCode
    let clientID = "ownerapi"
    let code: String
    let codeVerifier: String
    let redirectURI = "https://auth.tesla.com/void/callback"
}

struct RefreshTokenRequest: Encodable {
    let grantType = TokenGrantType.refreshToken
    let clientID = "ownerapi"
    let refreshToken: String
    let scope = "openid email offline_access"
}

enum TeslaNetworkingClient {
    static func getBearerToken(authorizationToken: String, codeVerifier: String) async throws -> TokenResponse {
        let host = "https://auth.tesla.com"
        let path = "oauth2/v3/token"
        
        var request = URLRequest(url: URL(string: "\(host)/\(path)")!)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        
        let tokenRequest = TokenRequest(code: authorizationToken, codeVerifier: codeVerifier)
        request.httpBody = try jsonEncoder.encode(tokenRequest)
        print(String(data: request.httpBody!, encoding: .utf8)!)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try jsonDecoder.decode(TokenResponse.self, from: data)
    }
}
