public struct VehicleCommand: Equatable {
    public enum Kind: CaseIterable, CustomStringConvertible {
        case honkHorn, flashLights
        
        public var description: String {
            switch self {
            case .honkHorn:
                return "Honk horn"
            case .flashLights:
                return "Flash lights"
            }
        }
    }
    
    public let kind: Kind
    
    public init(kind: Kind) {
        self.kind = kind
    }
}
