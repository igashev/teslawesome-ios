import Foundation
import os.log
import NetworkRequester

public struct LoggingMiddleware: Middleware {
    private let logger: os.Logger

    public init(logger: os.Logger) {
        self.logger = logger
    }
    
    /// Logs a request data like HTTP method, URL path, HTTP headers and HTTP body  when a subscription is attached.
    public func onRequest(_ request: inout URLRequest) async throws {
        let rows = [
            request.url.flatMap { "➡️ Requesting \(request.httpMethod ?? "") @ \($0)" },
            request.allHTTPHeaderFields.flatMap { $0.isEmpty ? nil : "Headers: \($0)" },
            request.httpBody.flatMap(prettifiedJSONData)
        ]
        
        logger.log("\(rows.compactMap { $0 }.joined(separator: "\n"), privacy: .public)")
    }
    
    /// Logs a resposne data like status code, URL path and JSON response data when received.
    public func onResponse(data: Data, response: URLResponse) {
        guard let url = response.url else {
            return
        }
        
        var statusString: String {
            guard let response = response as? HTTPURLResponse else {
                return "Unknown Response"
            }
            
            return "\(response.statusCode)"
        }
        
        logger.log(
            """
            ⬅️ Received \(statusString, privacy: .public) from \(url, privacy: .public)
            \(prettifiedJSONData(data), privacy: .public)
            """
        )

    }
    
    public func onError(_ error: NetworkingError, request: URLRequest?) {
        logger.log(
            """
            \(request?.url?.path ?? "Request", privacy: .public) failed with \
            \(error.localizedDescription, privacy: .public)
            
            Underlying: \(String(describing: error), privacy: .public)
            """
        )
    }
    
    /// Converts JSON data into a pretty JSON string 💄.
    /// - Parameter jsonData: JSON data to be converted.
    /// - Returns: Prettified JSON string or *No data.* when data is nil or when serialization was not successful.
    private func prettifiedJSONData(_ jsonData: Data?) -> String {
        guard let jsonData = jsonData,
              let object = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: .utf8)
        else {
            return "No data."
        }
        
        return prettyPrintedString
    }
}

public extension LoggingMiddleware {
    static var live: Self {
        .init(logger: .init(subsystem: "com.igashev.Teslawsome", category: "🌍 Networking"))
    }
}

private extension URL {
    var prettified: String {
        [path, query]
            .compactMap { $0 }
            .joined(separator: "?")
    }
}
