import Networking
import NetworkRequester

enum RequestBuilder {
    static func makeGetVehicles(accessToken: String) -> URLRequestBuilder {
        .api(endpoint: Endpoint.vehicles, httpMethod: .get, httpHeaders: [.authorization(bearerToken: accessToken)])
    }
}
