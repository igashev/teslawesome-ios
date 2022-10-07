import Foundation
import NetworkRequester
import VehiclesModels

public struct VehiclesNetworkClient {
    typealias GetVehicles = (String) async throws -> VehiclesResponse
    
    let getVehicles: GetVehicles
    
    init(getVehicles: @escaping GetVehicles) {
        self.getVehicles = getVehicles
    }
    
    public func getVehicles(token: String) async throws -> VehiclesResponse {
        try await getVehicles(token)
    }
}

public extension VehiclesNetworkClient {
    static var live: Self {
        let asyncCaller = AsyncCaller.standard
        return .init(
            getVehicles: { token in
                try await asyncCaller.call(using: RequestBuilder.makeGetVehicles(accessToken: token))
            }
        )
    }
}
