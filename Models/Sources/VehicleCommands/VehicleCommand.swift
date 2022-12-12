public enum VehicleCommand: String, Identifiable, Equatable, CaseIterable, CustomStringConvertible {
    case honkHorn, flashLights
    case actuateFrunk, actuateTrunk
    case unlockDoors, lockDoors
    case ventWindows, closeWindows
    
    public var id: String { rawValue }
    
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
            return "Unlock"
        case .lockDoors:
            return "Lock"
        case .ventWindows:
            return "Vent windows"
        case .closeWindows:
            return "Close windows"
        }
    }
}
