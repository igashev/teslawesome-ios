public struct VehicleCommand: Equatable {
    public enum Kind: CaseIterable, CustomStringConvertible {
        case honkHorn, flashLights
        case actuateFrunk, actuateTrunk
        case unlockDoors, lockDoors
        case ventWindows, closeWindows
        
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
            case .unlockDoors:
                return "Unlock doors"
            case .lockDoors:
                return "Lock doors"
            case .ventWindows:
                return "Vent windows"
            case .closeWindows:
                return "Close windows"
            }
        }
    }
    
    public let kind: Kind
    
    public init(kind: Kind) {
        self.kind = kind
    }
}
