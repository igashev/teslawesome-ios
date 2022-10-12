public struct VehicleCommand: Equatable {
    public enum Kind: CaseIterable, CustomStringConvertible {
        case honkHorn, flashLights
        case actuateFrunk, actuateTrunk
        
        public var description: String {
            switch self {
            case .honkHorn:
                return "Honk horn"
            case .flashLights:
                return "Flash lights"
            case .actuateFrunk:
                return "Actuate frunk"
            case .actuateTrunk:
                return "Actuate trunk"
            }
        }
    }
    
    public let kind: Kind
    
    public init(kind: Kind) {
        self.kind = kind
    }
}
