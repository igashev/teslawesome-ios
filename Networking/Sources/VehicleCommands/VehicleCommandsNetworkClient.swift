import NetworkRequester
import VehiclesDataModels

public struct VehicleCommandsNetworkClient {
    public typealias WakeUp = (Int) async throws -> VehicleResponse
    public typealias HonkHorn = (Int) async throws -> VehicleCommandContainerResponse
    public typealias FlashLights = (Int) async throws -> VehicleCommandContainerResponse
    
    let wakeUp: WakeUp
    let honkHorn: HonkHorn
    let flashLights: FlashLights
    
    init(wakeUp: @escaping WakeUp, honkHorn: @escaping HonkHorn, flashLights: @escaping FlashLights) {
        self.wakeUp = wakeUp
        self.honkHorn = honkHorn
        self.flashLights = flashLights
    }
    
    public func wakeUp(vehicleId: Int) async throws -> VehicleResponse {
        try await wakeUp(vehicleId)
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
            wakeUp: { try await asyncCaller.call(using: RequestBuilder.makeWakeUp(vehicleId: $0))},
            honkHorn: { try await asyncCaller.call(using: RequestBuilder.makeHonkHorn(vehicleId: $0)) },
            flashLights: { try await asyncCaller.call(using: RequestBuilder.makeFlashLights(vehicleId: $0)) }
        )
    }
}

#if DEBUG
import Foundation
public extension VehicleCommandsNetworkClient {
    static var stub: Self {
        .init(
            wakeUp: { _ in VehicleResponse.stub },
            honkHorn: { _ in .init(response: .init(reason: "", result: true)) },
            flashLights: { _ in .init(response: .init(reason: "", result: true)) }
        )
    }
}
#endif

public struct VehicleCommandContainerResponse: Decodable {
    let response: VehicleCommandResponse
}

public struct VehicleCommandResponse: Decodable {
    public let reason: String
    public let result: Bool
}
