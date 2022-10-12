public struct VehicleCommandContainerResponse: Decodable {
    let response: VehicleCommandResponse
}

public struct VehicleCommandResponse: Decodable {
    public let reason: String
    public let result: Bool
}
