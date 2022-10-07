import NetworkRequester

public extension URLRequestBuilder {
    init(
        endpoint: URLProviding,
        httpMethod: HTTPMethod,
        httpHeaders: [HTTPHeader] = [],
        httpBody: HTTPBody? = nil,
        queryParameters: URLQueryParameters? = nil
    ) {
        self.init(
            environment: Networking.apiEnvironment,
            endpoint: endpoint,
            httpMethod: httpMethod,
            httpHeaders: [.json] + httpHeaders,
            httpBody: httpBody,
            queryParameters: queryParameters,
            timeoutInterval: Networking.timeoutInterval
        )
    }
}
