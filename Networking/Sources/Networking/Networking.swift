import Foundation
import NetworkRequester

public enum Networking {
    public static let timeoutInterval: TimeInterval = 30
    public static let environment: Environment = .production
    
    public static var jsonDecoder: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }
    
    public static var jsonEncoder: JSONEncoder {
        let jsonDecoder = JSONEncoder()
        jsonDecoder.keyEncodingStrategy = .convertToSnakeCase
        return jsonDecoder
    }
    
    public static var queryParametersJSONEncoder: JSONEncoder {
        let jsonDecoder = JSONEncoder()
        jsonDecoder.keyEncodingStrategy = .convertToSnakeCase
        return jsonDecoder
    }
    
    private(set) static var middlewares: [Middleware] = []
    
    public static func appendMiddleware(_ middlewares: Middleware...) {
        self.middlewares.append(contentsOf: middlewares)
    }
}
