import NetworkRequester

public struct VehicleCommandsNetworkClient {
    public typealias HonkHorn = (Int) async throws -> VehicleCommandContainerResponse
    public typealias FlashLights = (Int) async throws -> VehicleCommandContainerResponse
    
    let honkHorn: HonkHorn
    let flashLights: FlashLights
    
    init(honkHorn: @escaping HonkHorn, flashLights: @escaping FlashLights) {
        self.honkHorn = honkHorn
        self.flashLights = flashLights
    }
    
    public func honkHorn(vehicleId: Int) async throws -> VehicleCommandContainerResponse {
        try await honkHorn(vehicleId)
    }
    
    public func flashLights(vehicleId: Int) async throws -> VehicleCommandContainerResponse {
        try await flashLights(vehicleId)
    }
}

public extension VehicleCommandsNetworkClient {
    static var live: Self {
        let asyncCaller = AsyncCaller.standard
        return .init(
            honkHorn: { try await asyncCaller.call(using: RequestBuilder.makeHonkHorn(vehicleId: $0)) },
            flashLights: { try await asyncCaller.call(using: RequestBuilder.makeFlashLights(vehicleId: $0)) }
        )
    }
}

public struct VehicleCommandContainerResponse: Decodable {
    let response: VehicleCommandResponse
}

public struct VehicleCommandResponse: Decodable {
    public let reason: String
    public let result: Bool
}
