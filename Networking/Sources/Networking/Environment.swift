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
    
    public enum Auth {
        
    }
}
