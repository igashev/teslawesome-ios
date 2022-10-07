import NetworkRequester

public extension URLRequestBuilder {
    static func api(
        endpoint: URLProviding,
        httpMethod: HTTPMethod,
        httpHeaders: [HTTPHeader] = [],
        httpBody: HTTPBody? = nil,
        queryParameters: URLQueryParameters? = nil
    ) -> Self {
        self.init(
            environment: Networking.environment.api,
            endpoint: endpoint,
            httpMethod: httpMethod,
            httpHeaders: [.json] + httpHeaders,
            httpBody: httpBody,
            queryParameters: queryParameters,
            timeoutInterval: Networking.timeoutInterval
        )
    }
    
    static func auth(
        endpoint: URLProviding,
        httpMethod: HTTPMethod,
        httpHeaders: [HTTPHeader] = [],
        httpBody: HTTPBody? = nil,
        queryParameters: URLQueryParameters? = nil
    ) -> Self {
        self.init(
            environment: Networking.environment.auth,
            endpoint: endpoint,
            httpMethod: httpMethod,
            httpHeaders: [.json] + httpHeaders,
            httpBody: httpBody,
            queryParameters: queryParameters,
            timeoutInterval: Networking.timeoutInterval
        )
    }
}
