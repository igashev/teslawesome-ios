import NetworkRequester

public extension URLQueryParameters {
    init<E: Encodable>(encodable: E) { self.init(encodable: encodable, encoder: Networking.queryParametersJSONEncoder) }
}
