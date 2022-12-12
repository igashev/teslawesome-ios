import Foundation
import AuthenticationModels

public struct CacheContainer<C: Codable>: Codable {
    public let data: C
    public let dateCached: Date
}

public extension CacheContainer<AuthenticationToken> {
    var hasExpired: Bool {
        let expiryDate = dateCached.addingTimeInterval(TimeInterval(data.expiresIn))
        return expiryDate <= .now
    }
}
