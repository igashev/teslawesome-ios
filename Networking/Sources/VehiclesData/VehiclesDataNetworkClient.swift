import NetworkRequester
import VehiclesDataModels
import Dependencies

public struct VehiclesDataNetworkClient {
    typealias GetVehicles = () async throws -> VehiclesResponse
    
    let getVehicles: GetVehicles
    
    init(getVehicles: @escaping GetVehicles) {
        self.getVehicles = getVehicles
    }
    
    public func getVehicles() async throws -> VehiclesResponse {
        try await getVehicles()
    }
}

extension VehiclesDataNetworkClient: DependencyKey {
    public static var liveValue: Self = {
        let asyncCaller = AsyncCaller.standard
        return .init(
            getVehicles: { try await asyncCaller.call(using: RequestBuilder.makeGetVehicles()) }
        )
    }()
    
    #if DEBUG
    public static let previewValue: Self = .init { .stub }
    #endif
}

extension DependencyValues {
    public var vehiclesDataNetworkClient: VehiclesDataNetworkClient {
        get { self[VehiclesDataNetworkClient.self] }
        set { self[VehiclesDataNetworkClient.self] = newValue }
    }
}
