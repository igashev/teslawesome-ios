import Foundation
import NetworkRequester

public enum Networking {
    static let timeoutInterval: TimeInterval = 30
    static let environment: Environment = .production
    
    static var jsonDecoder: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }
    
    static var jsonEncoder: JSONEncoder {
        let jsonDecoder = JSONEncoder()
        jsonDecoder.keyEncodingStrategy = .convertToSnakeCase
        return jsonDecoder
    }
    
    static var queryParametersJSONEncoder: JSONEncoder {
        let jsonDecoder = JSONEncoder()
        jsonDecoder.keyEncodingStrategy = .convertToSnakeCase
        return jsonDecoder
    }
    
    private(set) static var middlewares: [Middleware] = []
    
    public static func appendMiddleware(_ middlewares: Middleware...) {
        self.middlewares.append(contentsOf: middlewares)
    }
}
