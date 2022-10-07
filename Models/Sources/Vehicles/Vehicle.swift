public struct Vehicle: Decodable, Equatable, Identifiable {
    public let id: Int
    public let vehicleId: Int
    public let vin: String
    public let displayName: String
    public let color: String?
    public let tokens: [String]
    public let state: String
    public let inService: Bool
//  public   let ids: String
    public let calendarEnabled: Bool
    public let apiVersion: Int
}
