import NetworkRequester
import VehiclesDataModels
import Dependencies

public struct VehiclesDataNetworkClient {
    typealias Vehicles = () async throws -> VehiclesBasicResponse
    typealias VehicleData = (Int) async throws -> VehicleContainerResponse<VehicleFull>
    
    let getVehicles: Vehicles
    let getVehicleData: VehicleData
    
    public func getVehicles() async throws -> VehiclesBasicResponse {
        try await getVehicles()
    }
    
    public func getVehicleData(vehicleId: Int) async throws -> VehicleContainerResponse<VehicleFull> {
        try await getVehicleData(vehicleId)
    }
}

extension VehiclesDataNetworkClient: DependencyKey {
    public static let liveValue: Self = {
        let asyncCaller = AsyncCaller.standard
        return .init(
            getVehicles: { try await asyncCaller.call(using: RequestBuilder.makeGetVehicles()) },
            getVehicleData: { try await asyncCaller.call(using: RequestBuilder.makeGetVehicleData(vehicleId: $0)) }
        )
    }()
    
    #if DEBUG
    public static let previewValue: Self = .init(
        getVehicles: { .stub },
        getVehicleData: { _ in VehicleContainerResponse<VehicleFull>.stub }
    )
    #endif
}

extension DependencyValues {
    public var vehiclesDataNetworkClient: VehiclesDataNetworkClient {
        get { self[VehiclesDataNetworkClient.self] }
        set { self[VehiclesDataNetworkClient.self] = newValue }
    }
}
