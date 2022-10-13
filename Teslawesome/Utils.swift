//
//  Utils.swift
//  Teslawsome
//
//  Created by Ivaylo Gashev on 22.08.22.
//

import Foundation
import CryptoKit

enum Utils {
    static func randomlyGeneratedString(lenght: Int = 86) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return .init(allowedChars.shuffled())
    }
    
    static func hashInSHA256(string: String) -> String {
        let data = Data(string.utf8)
        let hashedData = SHA256.hash(data: data)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    static func encodeBase64URL(string: String) -> String {
        Data(string.utf8).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    static func extractQueryParameterValue(from url: URL, queryName: String) -> String? {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return urlComponents?.queryItems?
            .first(where: { $0.name == queryName })?
            .value
    }
}
