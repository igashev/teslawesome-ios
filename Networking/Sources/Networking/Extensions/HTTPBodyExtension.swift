import NetworkRequester

public extension HTTPBody {
    init<E: Encodable>(encodable: E) { self.init(encodable: encodable, jsonEncoder: Networking.jsonEncoder) }
}
