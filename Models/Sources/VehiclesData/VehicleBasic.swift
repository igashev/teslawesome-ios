public struct VehicleBasic: Decodable, Equatable, Hashable, Identifiable {    
    public let id: Int
    public let vehicleId: Int
    public let vin: String
    public let displayName: String
    public let color: String?
    public let tokens: [String]
    public let state: VehicleStateType
    public let inService: Bool
    public let calendarEnabled: Bool
    public let apiVersion: Int
}

#if DEBUG
import Foundation
public extension VehicleBasic {
    static var stub: Self {
        let json = """
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
          "state": "online",
          "in_service": false,
          "id_s": "12345678",
          "calendar_enabled": true,
          "api_version": 44,
          "backseat_token": null,
          "backseat_token_updated_at": null
        }
        """
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! jsonDecoder.decode(Self.self, from: json.data(using: .utf8)!)
    }
}
#endif
