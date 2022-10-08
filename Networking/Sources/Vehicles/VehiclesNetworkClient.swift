import Foundation
import NetworkRequester
import VehiclesModels

public struct VehiclesNetworkClient {
    public typealias GetVehicles = () async throws -> VehiclesResponse
    
    let getVehicles: GetVehicles
    
    init(getVehicles: @escaping GetVehicles) {
        self.getVehicles = getVehicles
    }
    
    public func getVehicles() async throws -> VehiclesResponse {
        try await getVehicles()
    }
}

public extension VehiclesNetworkClient {
    static var live: Self {
        let asyncCaller = AsyncCaller.standard
        return .init(
            getVehicles: { try await asyncCaller.call(using: RequestBuilder.makeGetVehicles()) }
        )
    }
}
