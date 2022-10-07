import NetworkRequester

public extension AsyncCaller {
    static var standard: Self {
        .init(decoder: Networking.jsonDecoder)
    }
    
    /// Performs a call where the error of `NetworkingError` `case networking` is decoded to `FacadeError`
    func call(using builder: URLRequestBuilder) async throws {
        try await call(using: builder, errorType: TeslaError.self)
    }

    /// Performs a call where the error of `NetworkingError` `case networking` is decoded to `FacadeError`
    func call<D: Decodable>(using builder: URLRequestBuilder) async throws -> D {
        try await call(using: builder, errorType: TeslaError.self)
    }
}

struct TeslaError: DecodableError {
    let error: String
}
