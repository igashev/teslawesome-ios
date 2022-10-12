import NetworkRequester
import VehiclesDataModels
import VehicleCommandsModels
import Dependencies

public struct VehicleCommandsNetworkClient {
    typealias WakeUp = (Int) async throws -> VehicleResponse
    typealias HonkHorn = (Int) async throws -> VehicleCommandContainerResponse
    typealias FlashLights = (Int) async throws -> VehicleCommandContainerResponse
    typealias ActuateTrunk = (Int, WhichTrunk) async throws -> VehicleCommandContainerResponse
    
    let wakeUp: WakeUp
    let honkHorn: HonkHorn
    let flashLights: FlashLights
    let actuateTrunk: ActuateTrunk
    
    init(
        wakeUp: @escaping WakeUp,
        honkHorn: @escaping HonkHorn,
        flashLights: @escaping FlashLights,
        actuateTrunk: @escaping ActuateTrunk
    ) {
        self.wakeUp = wakeUp
        self.honkHorn = honkHorn
        self.flashLights = flashLights
        self.actuateTrunk = actuateTrunk
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
    
    public func actuateTrunk(vehicleId: Int, whichTrunk: WhichTrunk) async throws -> VehicleCommandContainerResponse {
        try await actuateTrunk(vehicleId, whichTrunk)
    }
}

extension VehicleCommandsNetworkClient: DependencyKey {
    public static let liveValue: Self = {
        let asyncCaller = AsyncCaller.standard
        return .init(
            wakeUp: { try await asyncCaller.call(using: RequestBuilder.makeWakeUp(vehicleId: $0))},
            honkHorn: { try await asyncCaller.call(using: RequestBuilder.makeHonkHorn(vehicleId: $0)) },
            flashLights: { try await asyncCaller.call(using: RequestBuilder.makeFlashLights(vehicleId: $0)) },
            actuateTrunk: { try await asyncCaller.call(using: RequestBuilder.makeActuateTrunk(vehicleId: $0, whichTrunk: $1)) }
        )
    }()
    
    #if DEBUG
    public static let previewValue: Self = {
        .init(
            wakeUp: { _ in VehicleResponse.stub },
            honkHorn: { _ in .init(response: .init(reason: "", result: true)) },
            flashLights: { _ in .init(response: .init(reason: "", result: true)) },
            actuateTrunk: { _, _ in .init(response: .init(reason: "", result: true)) }
        )
    }()
    #endif
}

extension DependencyValues {
    public var vehicleCommandsNetworkClient: VehicleCommandsNetworkClient {
        get { self[VehicleCommandsNetworkClient.self] }
        set { self[VehicleCommandsNetworkClient.self] = newValue }
    }
}