public struct VehicleCommandContainerResponse: Decodable {
    public let response: VehicleCommandResponse
    
    public init(response: VehicleCommandResponse) {
        self.response = response
    }
}

public struct VehicleCommandResponse: Decodable {
    public let reason: String
    public let result: Bool
    
    public init(reason: String, result: Bool) {
        self.reason = reason
        self.result = result
    }
}
