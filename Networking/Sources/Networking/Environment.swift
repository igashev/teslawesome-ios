import NetworkRequester

public enum Environment {
    public enum API: URLProviding {
        case production
        
        public var url: String {
            switch self {
            case .production:
                return "https://owner-api.teslamotors.com"
            }
        }
    }
    
    public enum Auth: URLProviding {
        case production
        
        public var url: String {
            switch self {
            case .production:
                return "https://auth.tesla.com"
            }
        }
    }
    
    case production
    
    public var api: API {
        switch self {
        case .production:
            return .production
        }
    }
    
    public var auth: Auth {
        switch self {
        case .production:
            return .production
        }
    }
}
