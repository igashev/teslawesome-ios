public struct VehiclesBasicResponse: Decodable {
    public let response: [VehicleBasic]
    public let count: Int
}

#if DEBUG
import Foundation
public extension VehiclesBasicResponse {
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
#endif
