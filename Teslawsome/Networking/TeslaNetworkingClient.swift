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



struct Vehicle: Decodable, Equatable, Identifiable {
    let id: Int
    let vehicleId: Int
    let vin: String
    let displayName: String
    let color: String?
    let tokens: [String]
    let state: String
    let inService: Bool
//    let ids: String
    let calendarEnabled: Bool
    let apiVersion: Int
}

struct VehiclesResponse: Decodable {
    let response: [Vehicle]
    let count: Int
    
    static var stub: Self {
        let json = """
        {
          "response": [
            {
              "id": 12345678,
              "vehicle_id": 12345678,
              "vin": "LWQRSAFKAOSFSM12314",
              "display_name": "Tesla vehicle name",
              "option_codes": null,
              "color": null,
              "access_type": "OWNER",
              "tokens": [
                "24214214124",
                "213124566"
              ],
              "state": "asleep",
              "in_service": false,
              "id_s": "12345678",
              "calendar_enabled": true,
              "api_version": 44,
              "backseat_token": null,
              "backseat_token_updated_at": null
            }
          ],
          "count": 1
        }
        """
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! jsonDecoder.decode(Self.self, from: json.data(using: .utf8)!)
    }
}

struct VehicleResponse: Decodable {
    let response: Vehicle
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
    
    static func getAllVehicles(token: String) async throws -> VehiclesResponse {
        let host = "https://owner-api.teslamotors.com"
        let path = "api/1/vehicles"
        
        var request = URLRequest(url: URL(string: "\(host)/\(path)")!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        print(request)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try jsonDecoder.decode(VehiclesResponse.self, from: data)
    }
}
