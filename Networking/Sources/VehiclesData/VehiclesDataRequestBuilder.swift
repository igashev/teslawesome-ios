import Networking
import NetworkRequester

enum RequestBuilder {
    static func makeGetVehicles() -> URLRequestBuilder {
        .api(endpoint: Endpoint.vehicles, httpMethod: .get)
    }
    
    static func makeGetVehicleData(vehicleId: Int) -> URLRequestBuilder {
        .api(endpoint: Endpoint.vehicleData(vehicleId: vehicleId), httpMethod: .get)
    }
}
