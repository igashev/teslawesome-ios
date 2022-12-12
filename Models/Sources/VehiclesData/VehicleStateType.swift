public enum VehicleStateType: String, Decodable {
    case online, asleep
}

extension VehicleStateType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .online:
            return "Online"
        case .asleep:
            return "Asleep"
        }
    }
}
