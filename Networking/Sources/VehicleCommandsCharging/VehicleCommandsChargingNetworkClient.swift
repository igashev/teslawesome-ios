import VehicleCommandsModels

struct VehicleCommandsChargingNetworkClient {
    typealias OpenChargePort = (String) async throws -> VehicleCommandContainerResponse
    typealias CloseChargePort = (String) async throws -> VehicleCommandContainerResponse
    
    typealias StartCharge = (String) async throws -> VehicleCommandContainerResponse
    typealias StopCharge = (String) async throws -> VehicleCommandContainerResponse
    
    typealias ChargeStandard = (String) async throws -> VehicleCommandContainerResponse
    typealias ChargeMaxRange = (String) async throws -> VehicleCommandContainerResponse
    typealias SetChargeLimit = (String) async throws -> VehicleCommandContainerResponse
    typealias SetChargeAmps = (String) async throws -> VehicleCommandContainerResponse
    
    typealias SetScheduledCharging = (String) async throws -> VehicleCommandContainerResponse
    typealias SetScheduledDeparture = (String) async throws -> VehicleCommandContainerResponse
    
    let openChargePort: OpenChargePort
    let closeChargePort: CloseChargePort
    
    let startCharge: StartCharge
    let stopCharge: StopCharge
    
    let chargeStandard: ChargeStandard
    let chargeMaxRange: ChargeMaxRange
    let setChargeLimit: SetChargeLimit
    let setChargeAmps: SetChargeAmps
    
    let setScheduledCharging: SetScheduledCharging
    let setScheduledDeparture: SetScheduledDeparture
    
    public func openChargePort(vehicleId: String) async throws -> VehicleCommandContainerResponse {
        try await openChargePort(vehicleId)
    }
    
    public func closeChargePort(vehicleId: String) async throws -> VehicleCommandContainerResponse {
        try await closeChargePort(vehicleId)
    }
    
    public func startCharging(vehicleId: String) async throws -> VehicleCommandContainerResponse {
        try await startCharge(vehicleId)
    }
    
    public func stopCharging(vehicleId: String) async throws -> VehicleCommandContainerResponse {
        try await stopCharge(vehicleId)
    }
    
    public func setChargeStandard(vehicleId: String) async throws -> VehicleCommandContainerResponse {
        try await chargeStandard(vehicleId)
    }
    
    public func setChargeMaxRange(vehicleId: String) async throws -> VehicleCommandContainerResponse {
        try await chargeMaxRange(vehicleId)
    }
    
    public func setChargeLimit(vehicleId: String) async throws -> VehicleCommandContainerResponse {
        try await setChargeLimit(vehicleId)
    }
    
    public func setChargeAmps(vehicleId: String) async throws -> VehicleCommandContainerResponse {
        try await setChargeLimit(vehicleId)
    }
    
    public func setScheduledCharging(vehicleId: String) async throws -> VehicleCommandContainerResponse {
        try await setScheduledCharging(vehicleId)
    }
    
    public func setScheduledDeparture(vehicleId: String) async throws -> VehicleCommandContainerResponse {
        try await setScheduledCharging(vehicleId)
    }
}
