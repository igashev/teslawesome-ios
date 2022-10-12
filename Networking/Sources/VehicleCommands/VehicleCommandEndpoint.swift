import protocol NetworkRequester.URLProviding

enum Endpoint: URLProviding {
    case wakeUp(vehicleId: Int)
    case honkHorn(vehicleId: Int)
    case flashLights(vehicleId: Int)
    case actuateTrunk(vehicleId: Int)
    case doorUnlock(vehicleId: Int), doorLock(vehicleId: Int)
    
    var url: String {
        switch self {
        case .wakeUp(let vehicleId):
            return "/api/1/vehicles/\(vehicleId)/wake_up"
        case .honkHorn(let vehicleId):
            return "api/1/vehicles/\(vehicleId)/command/honk_horn"
        case .flashLights(let vehicleId):
            return "/api/1/vehicles/\(vehicleId)/command/flash_lights"
        case .actuateTrunk(let vehicleId):
            return "/api/1/vehicles/\(vehicleId)/command/actuate_trunk"
        case .doorUnlock(let vehicleId):
            return "/api/1/vehicles/\(vehicleId)/command/door_unlock"
        case .doorLock(let vehicleId):
            return "/api/1/vehicles/\(vehicleId)/command/door_lock"
        }
    }
}
