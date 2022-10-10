import protocol NetworkRequester.URLProviding

enum Endpoint: URLProviding {
    case honkHorn(vehicleId: Int)
    case flashLights(vehicleId: Int)
    
    var url: String {
        switch self {
        case .honkHorn(let vehicleId):
            return "api/1/vehicles/\(vehicleId)/command/honk_horn"
        case .flashLights(let vehicleId):
            return "/api/1/vehicles/\(vehicleId)/command/flash_lights"
        }
    }
}
