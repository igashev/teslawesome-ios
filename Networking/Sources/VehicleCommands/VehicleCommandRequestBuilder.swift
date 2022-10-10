import Networking
import NetworkRequester

enum RequestBuilder {
    static func makeHonkHorn(vehicleId: Int) -> URLRequestBuilder {
        .api(endpoint: Endpoint.honkHorn(vehicleId: vehicleId), httpMethod: .post)
    }
    
    static func makeFlashLights(vehicleId: Int) -> URLRequestBuilder {
        .api(endpoint: Endpoint.flashLights(vehicleId: vehicleId), httpMethod: .post)
    }
}
