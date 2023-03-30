import NetworkRequester

public extension AsyncCaller {
    static var standard: Self {
        .init(middleware: Networking.middlewares, decoder: Networking.jsonDecoder)
    }
    
    /// Performs a call where the error of `NetworkingError` `case networking` is decoded to `FacadeError`.
    /// This function does not expect a return type.
    func call(using builder: URLRequestBuilder) async throws {
        try await call(using: builder, errorType: TeslaError.self)
    }

    /// Performs a call where the error of `NetworkingError` `case networking` is decoded to `FacadeError`.
    /// This function expects to return a Decodable value.
    func call<D: Decodable>(using builder: URLRequestBuilder) async throws -> D {
        try await call(using: builder, errorType: TeslaError.self)
    }
}

struct TeslaError: DecodableError {
    let error: String
}
