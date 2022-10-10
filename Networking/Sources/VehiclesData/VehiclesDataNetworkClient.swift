import NetworkRequester
import VehiclesDataModels

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

public extension VehiclesDataNetworkClient {
    static var live: Self {
        let asyncCaller = AsyncCaller.standard
        return .init(
            getVehicles: { try await asyncCaller.call(using: RequestBuilder.makeGetVehicles()) }
        )
    }
}
