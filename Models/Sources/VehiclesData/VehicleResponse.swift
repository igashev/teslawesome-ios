public struct VehicleResponse: Decodable {
    public let response: Vehicle
}

#if DEBUG
import Foundation
public extension VehicleResponse {
    static var stub: Self {
        let json = """
        {
          "response" : {
            "id" : 929754369671265,
            "state" : "online",
            "backseat_token" : null,
            "in_service" : false,
            "vin" : "LRWYGCEK0NC350113",
            "access_type" : "OWNER",
            "user_id" : 1689144554356726,
            "api_version" : 45,
            "color" : null,
            "vehicle_id" : 1689172695767904,
            "display_name" : "Mika",
            "backseat_token_updated_at" : null,
            "tokens" : [
              "c34bf465ae4ae9bc",
              "ab04c3fba8ea1d4e"
            ],
            "id_s" : "929754369671265",
            "calendar_enabled" : true,
            "option_codes" : null
          }
        }
        """.data(using: .utf8)!
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! jsonDecoder.decode(Self.self, from: json)
    }
}
#endif
