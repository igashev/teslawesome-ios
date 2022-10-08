import Networking
import NetworkRequester

enum RequestBuilder {
    static func makeGetVehicles() -> URLRequestBuilder {
        .api(endpoint: Endpoint.vehicles, httpMethod: .get)
    }
}
