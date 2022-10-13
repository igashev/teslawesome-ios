import Foundation
import CryptoKit

enum Utils {
    static func randomlyGeneratedString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in allowedChars.randomElement() })
    }
    
    static func hashInSHA256(string: String) -> String {
        let data = Data(string.utf8)
        let hashedData = SHA256.hash(data: data)
        return hashedData
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
    
    static func encodeBase64URL(string: String) -> String {
        Data(string.utf8)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    static func extractQueryParameterValue(from url: URL, queryName: String) -> String? {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == queryName })?
            .value
    }
}
