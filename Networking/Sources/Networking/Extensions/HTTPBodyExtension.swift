import NetworkRequester

public extension HTTPBody {
    init<T: Encodable>(encodable: T) { self.init(encodable: encodable, jsonEncoder: Networking.jsonEncoder) }
}
