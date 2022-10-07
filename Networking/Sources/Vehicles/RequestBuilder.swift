import Networking
import NetworkRequester

struct RequestBuilder {
    static func makeGetVehicles(accessToken: String) -> URLRequestBuilder {
        .init(endpoint: Endpoint.vehicles, httpMethod: .get, httpHeaders: [.authorization(bearerToken: accessToken)])
    }
}
