import Foundation

struct Networking {
    static let timeoutInterval: TimeInterval = 30
    static let apiEnvironment: Environment.API = .production
    
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
}
